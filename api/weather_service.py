import os
import json
import requests
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from google.genai import types

from db.models import User, WeatherCache 

# --- 1. The Updated Gemini Tool Schema ---
weather_tool = types.Tool(
    function_declarations=[
        types.FunctionDeclaration(
            name="get_weather_forecast",
            description="Get the 5-day weather forecast for the user's current location.",
            parameters=types.Schema(
                type=types.Type.OBJECT,
                properties={} 
            )
        )
    ]
)

# --- 2. Main Service Function ---
def get_user_weather_for_gemini(user_id: int, db: Session) -> str:
    """
    Checks DB for user coordinates, checks cache for weather, 
    fetches fresh data if needed, and returns a Gemini-friendly string.
    """
    # 1. Verify User Location
    user = db.query(User).filter(User.id == user_id).first()
    if not user or not user.latitude or not user.longitude:
        return "Cannot check weather: GPS coordinates are missing from the profile. Please ask the user to update their location in the app."

    # 2. Check 3-hour cache
    three_hours_ago = datetime.utcnow() - timedelta(hours=3)
    cached_weather = db.query(WeatherCache).filter(
        WeatherCache.user_id == user_id,
        WeatherCache.fetched_at >= three_hours_ago
    ).first()

    if cached_weather:
        print("--- Loaded Weather from 3-Hour Database Cache ---")
        forecast_data = json.loads(cached_weather.forecast_data)
        return _format_weather_for_gemini(forecast_data)

    # 3. Cache Expired/Empty -> Fetch from OpenWeatherMap
    print("--- Cache expired/missing. Fetching fresh Weather from OpenWeatherMap ---")
    api_key = os.getenv("OPENWEATHERMAP_API_KEY")
    if not api_key:
        return "Error: Server API Key missing."

    url = f"https://api.openweathermap.org/data/2.5/forecast?lat={user.latitude}&lon={user.longitude}&appid={api_key}&units=metric"
    
    try:
        response = requests.get(url, timeout=10)
        if response.status_code != 200:
            return f"Weather data unavailable. API returned status: {response.status_code}"
            
        data = response.json()
        forecast_data = _process_and_cache_owm_data(user_id, data, db)
        
        return _format_weather_for_gemini(forecast_data)

    except Exception as e:
        print(f"Weather Fetch Error: {e}")
        return "Error: Could not connect to the weather service."

# --- 3. Helper: Process and Cache ---
def _process_and_cache_owm_data(user_id: int, data: dict, db: Session) -> list:
    daily_forecast = {}
    
    # Group 3-hour chunks into Daily Summaries
    for item in data['list']:
        date_str = item['dt_txt'].split(' ')[0]
        rain_mm = item.get('rain', {}).get('3h', 0.0)
        condition = item['weather'][0]['main']

        if date_str not in daily_forecast:
            daily_forecast[date_str] = {
                'temp_max': item['main']['temp_max'],
                'temp_min': item['main']['temp_min'],
                'rain_mm': rain_mm,
                'conditions': [condition]
            }
        else:
            daily_forecast[date_str]['temp_max'] = max(daily_forecast[date_str]['temp_max'], item['main']['temp_max'])
            daily_forecast[date_str]['temp_min'] = min(daily_forecast[date_str]['temp_min'], item['main']['temp_min'])
            daily_forecast[date_str]['rain_mm'] += rain_mm
            daily_forecast[date_str]['conditions'].append(condition)

    # Format cleanly
    final_forecast = []
    for date_str, info in list(daily_forecast.items())[:5]:
        conds = info['conditions']
        if 'Rain' in conds or 'Thunderstorm' in conds or 'Drizzle' in conds:
            main_cond = 'Rainy'
        elif 'Clear' in conds:
            main_cond = 'Sunny'
        else:
            main_cond = 'Cloudy'

        final_forecast.append({
            "date": date_str,
            "temp_max": round(info['temp_max'], 1),
            "temp_min": round(info['temp_min'], 1),
            "rain_mm": round(info['rain_mm'], 1),
            "condition": main_cond
        })

    # Save to Database Cache
    db.query(WeatherCache).filter(WeatherCache.user_id == user_id).delete()
    new_cache = WeatherCache(
        user_id=user_id,
        forecast_data=json.dumps(final_forecast)
    )
    db.add(new_cache)
    db.commit()

    return final_forecast

# --- 4. Helper: Format string for Gemini ---
def _format_weather_for_gemini(forecast_json: list) -> str:
    result_str = "5-Day Weather Forecast:\n"
    for day in forecast_json:
        result_str += f"- {day['date']}: {day['condition']}, High {day['temp_max']}°C, Low {day['temp_min']}°C, Rain: {day['rain_mm']}mm\n"
    return result_str