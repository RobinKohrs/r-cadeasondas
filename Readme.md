# Was soll das?

- automatisiert, aktuelle Wellen-, Wetter-, Wasserdaten für alle Surfspots (alle von Surfline) herunterladen und über die Zeit eine historische "Datenbank" aufbauen
- Immer wenn mein Computer an ist, lade ich jede Stunde die Daten von Surfline herunter

# Todos

- [ ] Look at [Buoy data from NOA](https://www.ndbc.noaa.gov/faq/rt_data_access.shtml). With explanations on the [variables here](https://www.ndbc.noaa.gov/faq/measdes.shtml)

# Dashboards

- [Marine Copernicus](https://data.marine.copernicus.eu/viewer/expert?view=catalogue)

- [Ocean Ops all global Buoys](https://www.ocean-ops.org/board#)

### Forecast API Endpoints

- **Conditions**: `https://services.surfline.com/kbyg/regions/forecasts/conditions?subregionId=58581a836630e24c44879163&days=5`
  - Returns a daily forecast summary for a whole subregion, including a general rating, min/max wave heights, and a text observation for the morning and afternoon.
- **Rating**: `https://services.surfline.com/kbyg/spots/forecasts/rating?spotId=584204214e65fad6a7709c58&days=5&intervalHours=1&cacheEnabled=true`
  - Provides an hourly surf rating for a specific spot with a descriptive key (e.g., "VERY_POOR") and a numerical value.
- **Surf**: `https://services.surfline.com/kbyg/spots/forecasts/surf?cacheEnabled=true&days=5&intervalHours=1&spotId=584204214e65fad6a7709c58&units%5BwaveHeight%5D=M`
  - Provides a detailed hourly forecast of wave heights for a specific spot, including min/max heights and a human-readable description.
- **Swells**: `https://services.surfline.com/kbyg/spots/forecasts/swells?cacheEnabled=true&days=5&intervalHours=1&spotId=584204214e65fad6a7709c58&units%5BswellHeight%5D=M`
  - Returns highly detailed hourly data on individual swells, each with its own height, period, power, and direction.
- **Wind**: `https://services.surfline.com/kbyg/spots/forecasts/wind?spotId=584204214e65fad6a7709c58&days=5&intervalHours=1&corrected=false&cacheEnabled=true&units%5BwindSpeed%5D=KTS`
  - Provides an hourly wind forecast, including speed, gust, direction, and an "optimal score."
- **Sunlight**: `https://services.surfline.com/kbyg/spots/forecasts/sunlight?spotId=584204214e65fad6a7709c58&days=16&intervalHours=1`
  - Provides daily data on sunlight times, including dawn, sunrise, sunset, and dusk.
- **Tides**: `https://services.surfline.com/kbyg/spots/forecasts/tides?spotId=584204214e65fad6a7709c58&days=6&cacheEnabled=true&units%5BtideHeight%5D=M`
  - Provides a detailed hourly tide forecast with the height and type of the tide (e.g., "HIGH," "LOW").
- **Weather**: `https://services.surfline.com/kbyg/spots/forecasts/weather?spotId=584204214e65fad6a7709c58&days=16&intervalHours=1&cacheEnabled=true&units%5Btemperature%5D=C`
  - Returns a comprehensive hourly weather forecast, including temperature, condition, and pressure.
- **Consistency**: `https://services.surfline.com/kbyg/spots/forecasts/consistency?days=5&intervalHours=1&spotId=584204214e65fad6a7709c58`
  - Provides an hourly `waveCount`, indicating the expected number of rideable waves.
