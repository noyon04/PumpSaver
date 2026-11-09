# PumpSaver

Find the cheapest petrol and diesel near you in the UK, using the government's live **Fuel Finder** open data
(every UK forecourt must report price changes within 30 minutes).

Built with Flutter 3.47 and Riverpod 3.

<p>
  <img src="docs/screenshots/home.jpg" width="280" alt="Cheapest unleaded near you, sorted by price">
  <img src="docs/screenshots/details.jpg" width="280" alt="Station details with all prices and opening hours">
</p>

*Screenshots use the bundled sample data.*

## Features

- Nearest stations within 10 miles that sell your fuel (unleaded E10, super unleaded E5, diesel, premium diesel)
- Sort by cheapest or nearest; the cheapest station is highlighted
- How fresh each price is ("updated 25 min ago")
- Station details: every fuel price, opening hours, facilities, one-tap directions
- Remembers your fuel type and sort order
- Works without location permission (falls back to central London and says so)

## Architecture

```
Fuel Finder API ──(OAuth client credentials, rate-limited, paged)──┐
                                                                   │  GitHub Action, every 30 min
                                                     tool/fetch_fuel_data.dart
                                                                   │  merges stations + prices
                                                     GitHub Pages: stations.json
                                                                   │  one GET
                                                            Flutter app
```

The API needs a client secret and allows about one request every 2 seconds, so phones can't call it directly.
A scheduled job fetches it with the secret held in GitHub, and the app downloads a single static file.
No server to run, and no secret in the app.

App code follows a feature-first controller / state / view layout:

```
lib/
  constants/     asset paths, shared-preference keys
  controller/    one folder per feature: <name>_controller.dart + state/<name>_state.dart
    stations/    load stations; nearby_stations_controller.dart filters + sorts (pure, unit-tested)
    location/    device location with permission handling and fallback
    search_filter/  fuel type + sort order, persisted
    startup/     what the splash screen loads
  models/        StationModel, FuelPriceModel, FuelType (Fuel Finder field names)
  network/       API endpoints, Network GET + response handling
  services/      app mode (sample vs live), navigation, time formatting
  views/
    global_components/  reusable K-prefixed widgets
    screens/     startup, home (+ components), station_details
    styles/      KColor, KTextStyle, KSize
```

State: each controller is a Riverpod `Notifier` exposing a `sealed` state class (Initial / Loading / Success / Error),
which screens handle with an exhaustive `switch`/`is` check.

## Run it

```bash
flutter pub get
flutter run            # Android / iOS
flutter run -d chrome  # web
```

Out of the box the app uses **bundled sample data** (fictional stations around London, clearly labelled in the app).

## Use live data

1. Get API credentials: sign in with GOV.UK One Login at the
   [Fuel Finder developer portal](https://www.developer.fuel-finder.service.gov.uk/access-latest-fuelprices).
2. Push this repo to GitHub. Add `FUEL_FINDER_CLIENT_ID` and `FUEL_FINDER_CLIENT_SECRET` as Actions secrets,
   and set Settings > Pages > Source to **GitHub Actions**.
3. Run the **Fetch fuel data** workflow once (Actions tab > Run workflow).
4. In `lib/network/api.dart` set `LIVE` to `https://<your-user>.github.io/<repo>/` (already set for this repo), and in
   `lib/services/app_mode.dart` set `PRODUCTION_MODE = true`.

Test the fetch locally:

```bash
FUEL_FINDER_CLIENT_ID=... FUEL_FINDER_CLIENT_SECRET=... dart run tool/fetch_fuel_data.dart
```

## Tests

```bash
flutter test
```

Covers the nearby-station filter and sort (closed stations, radius, missing fuel, price and distance order),
parsing of the API field names, time formatting, and the station card widget.

## Data

Contains public sector information licensed under the
[Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) (Fuel Finder).
PumpSaver is an independent app, not affiliated with the UK government.
