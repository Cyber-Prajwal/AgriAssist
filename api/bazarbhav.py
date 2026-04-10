import os
import json
import asyncio
import aiohttp
import requests
import traceback
from datetime import datetime, timedelta
import time

API_KEY = os.getenv("DATA_GOV_API_KEY")
RESOURCE_ID = "35985678-0d79-46b4-9ed6-6f13308a1d24"
BASE_URL = f"https://api.data.gov.in/resource/{RESOURCE_ID}"

# Global headers to mimic a real browser and avoid firewall blocks
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "application/json"
}

# --- HELPER: GET RECENT BUSINESS DAYS ---
def get_recent_business_days(num_days=8):
    today = datetime.now()
    dates = []
    days_back = 0

    while len(dates) < num_days:
        check_date = today - timedelta(days=days_back)
        if check_date.weekday() < 5:
            dates.append(check_date.strftime("%d/%m/%Y"))
        days_back += 1
        
        
        if days_back > 30: 
            break

    return dates


# --- FETCH MARKET DATA FOR FRONTEND (JSON RESPONSE) ---
async def get_market_data(state: str, district: str):
    target_district = district.title() if district and district.lower() != "all districts" else None
    
    dates_to_check = get_recent_business_days(8) 
    results = []

    
    custom_timeout = aiohttp.ClientTimeout(total=45)

    async with aiohttp.ClientSession(timeout=custom_timeout, headers=HEADERS) as session:
        for date_str in dates_to_check:
            params = {
                "api-key": API_KEY,
                "format": "json",
                "limit": 500,
                "offset": 0,
                "filters[State]": state.title(),
                "filters[Arrival_Date]": date_str
            }

            if target_district:
                params["filters[District]"] = target_district

            try:
                print(f"📡 Fetching state data for {date_str}...")
                async with session.get(BASE_URL, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        records = data.get("records", [])

                        if records:
                            for r in records:
                                results.append({
                                    "commodity": r.get("Commodity"),
                                    "district": r.get("District"),
                                    "market": r.get("Market"),
                                    "price_latest": str(r.get("Modal_Price", "N/A")),
                                    "msp": str(r.get("Min_Price", "N/A")),
                                    "date": r.get("Arrival_Date"),
                                    "source": "live"
                                })
                    elif response.status == 429:
                        print(f"⚠️ [FRONTEND] Rate Limited (429) on {date_str}.")
                        await asyncio.sleep(2)

                    else:
                        error_text = await response.text()
                        print(f"⚠️ [FRONTEND] HTTP {response.status}: {error_text}")

            except asyncio.TimeoutError:
                print(f"⏳ [FRONTEND] Timeout on {date_str}. Server is slow, skipping...")
            except Exception as e:
                print(f"🚨 [FRONTEND] Error: {repr(e)}")

            await asyncio.sleep(1)

    return {"data": results}

# --- HELPER FOR GEMINI TOOL (STATE-WIDE FETCH & FILTER) ---
def get_baazar_bhav_for_ai(state: str, district: str, commodity: str):
    """Fetches whole state data for 3 days and filters in memory for the specific commodity."""
    if not API_KEY:
        return "Error: Government API key is missing."

    target_district = district.title() if district and district.lower() != "all districts" else None
    target_commodity = commodity.title()
    
    # 1. Get ONLY the last 3 business days
    dates_to_check = get_recent_business_days(3)
    
    district_records = []
    other_district_records = []

    for date_str in dates_to_check:
        params = {
            "api-key": API_KEY,
            "format": "json",
            "limit": 1500,  # High limit to grab all commodities in the state for this day
            "filters[State]": state.title(),
            "filters[Arrival_Date]": date_str
        }

        try:
            # Synchronous fetch for the AI tool
            response = requests.get(BASE_URL, params=params, headers=HEADERS, timeout=15)
            
            if response.status_code == 200:
                records = response.json().get("records", [])
                
                # 2. IN-MEMORY FILTERING
                for r in records:
                    rec_commodity = r.get("Commodity", "").title()
                    
                    # If we find the requested crop
                    if rec_commodity == target_commodity:
                        rec_district = r.get("District", "").title()
                        
                        # 3. Categorize: Is it in the user's district or another district?
                        if target_district and rec_district == target_district:
                            district_records.append(r)
                        else:
                            other_district_records.append(r)
                            
            elif response.status_code == 429:
                print(f"⚠️ [AI TOOL] Rate Limit (429) on {date_str}")
                time.sleep(1)

        except requests.exceptions.Timeout:
            print(f"⏳ [AI TOOL] Timeout for state {state} on {date_str}")
        except Exception as e:
            print(f"🚨 [AI TOOL] Error: {repr(e)}")

    # 4. If nothing was found anywhere in the state
    if not district_records and not other_district_records:
        return f"Politely inform the user that no market data was found for {commodity} anywhere in {state} over the past 3 days."

    return format_ai_response(district_records, other_district_records, commodity, state, target_district)


def format_ai_response(district_records: list, other_records: list, commodity: str, state: str, district: str):
    """Formats the grouped records so Gemini prioritizes the local district."""
    
    response_str = f"3-Day Market Report for {commodity.title()} in {state}:\n\n"

    # --- Local District Data First ---
    if district_records:
        response_str += f"📍 **Your District ({district}):**\n"
        for r in district_records:
            response_str += f"- {r.get('Arrival_Date')}: ₹{r.get('Modal_Price')}/Quintal (Mandi: {r.get('Market')})\n"
        response_str += "\n"
    else:
        response_str += f"📍 **Your District ({district}):** No data arrived in the past 3 days.\n\n"

    # --- State-wide Fallback Data ---
    if other_records:
        response_str += f"🌐 **Other Districts in {state} (Recent Arrivals):**\n"
        
        # We limit to the first 8 to avoid overloading Gemini's context window
        for r in other_records[:8]: 
            response_str += f"- {r.get('District')} ({r.get('Arrival_Date')}): ₹{r.get('Modal_Price')}/Quintal (Mandi: {r.get('Market')})\n"
    
    response_str += """
INSTRUCTIONS FOR AI:
1. If there is data for the user's specific district, tell them that price immediately.
2. If their district has no data, politely mention that, and then provide 2-3 prices from other nearby districts in the state as an alternative.
3. Keep the explanation natural, conversational, and strictly based on the data above.
"""
    return response_str