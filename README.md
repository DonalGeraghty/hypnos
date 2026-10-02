# Hypnos

Hypnos is an analog Garmin watch face for the **Garmin Forerunner 965**, inspired by the Samsung Gear Sport. Two activity rings, for steps and intensity minutes, grow out of the hour and minute hands.

The project started from [MVP_PLAN.md](./MVP_PLAN.md), the original sleep-focused plan. The face has since moved to the design described below.

## The face

- **Outer ring (cyan): steps today**, against your daily step goal. It starts at the **minute hand**.
- **Inner ring (blue): intensity minutes this week**, against your weekly goal. It starts at the **hour hand**.
- **Analog time:** white hour and minute hands with a centre pivot, drawn on top of the rings.
- **Values on the rings:** each ring's current value is printed along the ring, curving through the unfilled track just past the end of the fill. Text in the bottom half runs the other way so it's never upside down. When a ring is nearly full, the value moves just inside the fill in dark text.
- **Icons at 6 o'clock:** footprints for steps, in the gap between the rings, and a lightning bolt for intensity minutes, just inside the inner ring.
- **Always-on mode:** only thin, dim hands, with no rings, to protect the AMOLED screen.

### How the rings work

Each hand is the moving zero point of its ring. The hand reaches the outer edge of its ring, and the coloured arc grows out of it clockwise. As the hand moves, the ring's starting point moves with it. Both ends of the arc are flat. Each ring sits on a full 360° dim track, and fills completely once its goal is reached.

If the watch reports no goal, the face uses 10,000 steps and 150 intensity minutes.

### Settings in the code

All in `source/HypnosView.mc`:

| Setting | Purpose |
| --- | --- |
| `USE_TEST_DATA` | `true` shows sample values (6,400 steps, 95 intensity minutes) for previewing in the simulator. **Set it to `false` before building for the watch.** |
| `RING_TRAILS_HAND` | `false` (default) fills each ring clockwise, ahead of its hand. `true` makes the arc trail behind the hand instead. |
| `COLOR_*` constants | Ring, track, hand and label colours. |
| `onLayout` | Ring radii and thickness, hand widths and icon size, all as fractions of the screen width. |

The design targets the Forerunner 965's **454 x 454 round AMOLED display**.

### Why Sleep Score is not available

Hypnos started as a sleep/recovery face, but Garmin currently lists the Forerunner 965 at **Connect IQ API level 5.2**.

Garmin's built-in Sleep Score complication, `COMPLICATION_TYPE_SLEEP_SCORE`, was introduced at **API level 6.0.2**.

Body Battery and heart rate are available through the older Complications API supported by the Forerunner 965 if a recovery-focused design is wanted later.

Do not work around this with phone networking or unofficial data scraping. If Garmin exposes Sleep Score to the 965 through a compatible API later, it can be added in a later version.

## Data available on the Forerunner 965

This section lists everything a Connect IQ watch face can read on the Forerunner 965 (Connect IQ API 5.2). The lists come from the fr965 device profile and the API docs in Connect IQ SDK 9.2.0.

✅ marks a value Hypnos currently shows.

Any value can be `null`, for example when the watch hasn't measured it yet, the user hasn't set it up, or the simulator doesn't provide it, so always check before using it.

### Complications (`Toybox.Complications`)

These are the same values Garmin's own watch faces use. They need the `ComplicationSubscriber` permission, which Hypnos doesn't currently request. Read a value with `Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_...)).value`.

#### Health and recovery

| Complication | Value | Description |
| --- | --- | --- |
| `BODY_BATTERY` | Number, 0–100 | Garmin's estimate of your energy reserve. Charges during rest and sleep, drains with activity and stress. |
| `HEART_RATE` | Number, bpm | Current heart rate from the wrist sensor. |
| `STRESS` | Number, 0–100 | Current stress level, based on heart rate variability. 0–25 is rest, 76–100 is high stress. |
| `PULSE_OX` | Number, % | Most recent blood oxygen (SpO2) reading. Only available if Pulse Ox is enabled on the watch. |
| `RESPIRATION_RATE` | Number, breaths/min | Current breathing rate. |
| `RECOVERY_TIME` | Number, minutes | Time left until you're recovered from your last workout. |
| `TRAINING_STATUS` | String | Garmin's training status label, for example "Productive", "Maintaining" or "Recovery". |
| `VO2MAX_RUN` | Number | Estimated running VO2 max, a measure of aerobic fitness. |
| `VO2MAX_BIKE` | Number | Estimated cycling VO2 max. Needs a power meter. |

#### Daily activity

| Complication | Value | Description |
| --- | --- | --- |
| `STEPS` | Number | Steps taken today. Not available in wheelchair mode. |
| `CALORIES` | Number, kcal | Calories burned today, including resting calories. |
| `FLOORS_CLIMBED` | Number | Floors climbed today. Not available in wheelchair mode. |
| `INTENSITY_MINUTES` | Number | Moderate/vigorous activity minutes this week. Resets weekly. |
| `WHEELCHAIR_PUSHES` | Number | Wheelchair pushes today. Only available in wheelchair mode. |
| `WEEKLY_RUN_DISTANCE` | Float, metres | Total running distance this week. |
| `WEEKLY_BIKE_DISTANCE` | Float, metres | Total cycling distance this week. |

#### Race predictions

| Complication | Value | Description |
| --- | --- | --- |
| `RACE_PREDICTOR_5K` | Number, seconds | Predicted 5K finish time. |
| `RACE_PREDICTOR_10K` | Number, seconds | Predicted 10K finish time. |
| `RACE_PREDICTOR_HALF_MARATHON` | Number, seconds | Predicted half marathon finish time. |
| `RACE_PREDICTOR_MARATHON` | Number, seconds | Predicted marathon finish time. |
| `RACE_PACE_PREDICTOR_5K` | Float, m/s | Predicted 5K race pace. |
| `RACE_PACE_PREDICTOR_10K` | Float, m/s | Predicted 10K race pace. |
| `RACE_PACE_PREDICTOR_HALF_MARATHON` | Float, m/s | Predicted half marathon race pace. |
| `RACE_PACE_PREDICTOR_MARATHON` | Float, m/s | Predicted marathon race pace. |

#### Device, time and environment

| Complication | Value | Description |
| --- | --- | --- |
| `BATTERY` | Number, 0–100 | Watch battery charge. Also available through `System.getSystemStats()`. |
| `DATE` | String | Day of the month and month, for example "28 Mar". |
| `WEEKDAY_MONTHDAY` | String | Day of the week and day of the month, for example "Mon 28". |
| `NOTIFICATION_COUNT` | Number | Number of unread phone notifications. |
| `CALENDAR_EVENTS` | String | Time of your next calendar event, synced from the phone. |
| `SUNRISE` | Number, seconds | Today's sunrise, as seconds since local midnight. |
| `SUNSET` | Number, seconds | Today's sunset, as seconds since local midnight. |
| `ALTITUDE` | Float, metres | Current altitude from the barometric altimeter. |
| `SEA_LEVEL_PRESSURE` | Float, pascals | Current barometric pressure adjusted to sea level. |
| `SOLAR_INPUT` | Number, 0–100 | Solar charging intensity. The Forerunner 965 has no solar panel, so expect `null`. |
| `LAST_GOLF_ROUND_SCORE` | String | Score of your last golf round, for example "82(+10)". |

#### Weather

Weather is synced from the phone.

| Complication | Value | Description |
| --- | --- | --- |
| `CURRENT_WEATHER` | `Weather.CONDITION_*` | Current conditions, such as clear, rain or snow. |
| `CURRENT_TEMPERATURE` | Float, °C | Current temperature. |
| `HIGH_LOW_TEMPERATURE` | String | Today's high and low, formatted like "H 18 / L 9". |
| `FORECAST_WEATHER_1DAY` | `Weather.CONDITION_*` | Forecast conditions for tomorrow. |
| `FORECAST_WEATHER_2DAY` | `Weather.CONDITION_*` | Forecast conditions in two days. |
| `FORECAST_WEATHER_3DAY` | `Weather.CONDITION_*` | Forecast conditions in three days. |

#### Not available on the Forerunner 965

| Complication | Needs | Description |
| --- | --- | --- |
| `SLEEP_SCORE` | API 6.0.2 | Last night's sleep score, 0–100. See [Why Sleep Score is not available](#why-sleep-score-is-not-available). |

### Activity monitor (`ActivityMonitor.getInfo()`)

Today's activity totals and goals. No extra permission is needed.

| Field | Value | Description |
| --- | --- | --- |
| ✅ `steps` | Number | Steps since midnight. |
| ✅ `stepGoal` | Number | Today's step goal. |
| `distance` | Number, cm | Distance travelled today. |
| `calories` | Number, kcal | Calories burned today. |
| `floorsClimbed` | Number | Floors climbed today. |
| `floorsDescended` | Number | Floors descended today. |
| `floorsClimbedGoal` | Number | Daily floors goal. |
| `metersClimbed` | Float, m | Height climbed today. |
| `metersDescended` | Float, m | Height descended today. |
| `activeMinutesDay` | Object | Intensity minutes today (moderate, vigorous and total). |
| ✅ `activeMinutesWeek` | Object | Intensity minutes this week. |
| ✅ `activeMinutesWeekGoal` | Number | Weekly intensity minutes goal. |
| `moveBarLevel` | Number | Inactivity "Move!" bar level. Rises the longer you sit still. |
| `stressScore` | Number, 0–100 | Current stress, averaged over the last 30 seconds. |
| `respirationRate` | Number, breaths/min | Current breathing rate. |
| `timeToRecovery` | Number, hours | Recovery time left after your last workout. |

### Sensor history (`Toybox.SensorHistory`)

Recent readings over time, useful for small trend graphs such as Body Battery over the last few hours. This needs the `SensorHistory` permission, which Hypnos doesn't request yet.

| Function | Description |
| --- | --- |
| `getBodyBatteryHistory()` | Body Battery samples over a recent period. |
| `getHeartRateHistory()` | Heart rate samples. |
| `getStressHistory()` | Stress level samples. |
| `getOxygenSaturationHistory()` | Blood oxygen (SpO2) samples. |
| `getElevationHistory()` | Altitude samples. |
| `getPressureHistory()` | Barometric pressure samples. |
| `getTemperatureHistory()` | Temperature samples from the watch's sensor. Body heat affects these readings. |

### System (`System.getSystemStats()`, `System.getDeviceSettings()`)

| Field | Value | Description |
| --- | --- | --- |
| `battery` | Float, % | Watch battery charge. |
| `batteryInDays` | Float | Estimated days of battery left. |
| `charging` | Boolean | Whether the watch is charging. |
| `solarIntensity` | Number | Solar charge efficiency. Expect `null` on the 965. |
| `is24Hour` | Boolean | The user's 12/24-hour setting. |
| `notificationCount` | Number | Unread notifications. |
| `phoneConnected` | Boolean | Whether the phone is connected over Bluetooth. |
| `alarmCount` | Number | Number of alarms set. |
| `doNotDisturb` | Boolean | Whether Do Not Disturb is on. |

The hands use `System.getClockTime()` ✅. The date is available from `Time.Gregorian.info()`.

### Weather (`Weather.getCurrentConditions()`)

A more detailed version of the weather complications. Weather is synced from the phone.

| Field | Value | Description |
| --- | --- | --- |
| `temperature` | Number, °C | Current temperature. |
| `feelsLikeTemperature` | Float, °C | Wind chill or heat index. |
| `highTemperature` / `lowTemperature` | Number, °C | Today's forecast high and low. |
| `condition` | `CONDITION_*` | Current conditions, such as clear, rain or snow. |
| `precipitationChance` | Number, % | Chance of rain or snow. |
| `relativeHumidity` | Number, % | Relative humidity. |
| `dewPoint` | Float, °C | Dew point. |
| `windSpeed` | Float, m/s | Wind speed. |
| `windBearing` | Number, degrees | Wind direction. |
| `uvIndex` | Float | UV index. |
| `cloudCover` | Number, % | Cloud cover. |
| `visibility` | Number, m | Visibility distance. |
| `pressure` | Float, Pa | Air pressure. |
| `observationTime` | Moment | When the conditions were observed. |
| `observationLocationPosition` | Location | Where the conditions were observed. |

`Weather.getDailyForecast()` and `Weather.getHourlyForecast()` return forecasts as well.

### User profile (`UserProfile.getProfile()`)

Settings from the user's Garmin profile. This needs the `UserProfile` permission, which Hypnos doesn't currently request.

| Field | Value | Description |
| --- | --- | --- |
| `restingHeartRate` | Number, bpm | Resting heart rate. |
| `averageRestingHeartRate` | Number, bpm | Resting heart rate averaged over recent days. |
| `sleepTime` | Duration | Usual bedtime, as time since midnight. Useful for a "time until bed" reminder. |
| `wakeTime` | Duration | Usual wake-up time, as time since midnight. |
| `vo2maxRunning` | Number | Running VO2 max. |
| `vo2maxCycling` | Number | Cycling VO2 max. |
| `weight` | Number, g | Body weight. |
| `height` | Number, cm | Height. |
| `birthYear` | Number | Year of birth. |
| `gender` | `GENDER_*` | Gender as set in the profile. |
| `activityClass` | Number | Activity level as set in the profile. |
| `walkingStepLength` | Number, mm | Walking step length. |
| `runningStepLength` | Number, mm | Running step length. |

`upcomingSleepTime` and `upcomingWakeTime` need a newer API level than the Forerunner 965 supports.

## Development environment

This project is intended to be developed on Windows using:

- Visual Studio Code
- Garmin Monkey C extension
- Garmin Connect IQ SDK
- Java Runtime Environment 11 or newer
- Garmin Forerunner 965

Official Garmin documentation:

- Connect IQ getting started: https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/
- VS Code Monkey C extension: https://developer.garmin.com/connect-iq/reference-guides/visual-studio-code-extension/
- First Connect IQ app and sideloading: https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/
- Connect IQ API docs: https://developer.garmin.com/connect-iq/api-docs/
- Compatible devices: https://developer.garmin.com/connect-iq/compatible-devices/

## First-time setup

### 1. Install VS Code

Install Visual Studio Code if it is not already installed.

### 2. Install Java

Garmin's Monkey C extension requires Java 11 or newer.

Install a suitable Java runtime and make sure it is available to VS Code.

### 3. Install the Monkey C extension

In VS Code:

1. Open **Extensions**.
2. Search for **Monkey C**.
3. Install the extension published by Garmin.
4. Restart VS Code if prompted.
5. Open the Command Palette with `Ctrl+Shift+P`.
6. Run:

```text
Monkey C: Verify Installation
```

The verification should complete successfully before working on the project.

### 4. Install/configure the Connect IQ SDK

Open the Command Palette and run:

```text
Monkey C: Open SDK Manager
```

Install a current Connect IQ SDK and set it as the current SDK. On the **Devices** tab, download **Forerunner 965**.

## Developer signing key

Garmin Connect IQ apps must be signed when they are compiled for a physical device.

### Generate the key

In VS Code:

1. Press `Ctrl+Shift+P`.
2. Run:

```text
Monkey C: Generate a Developer Key
```

3. Choose a safe location **outside this Git repository**.

A sensible Windows location would be somewhere under your user profile, for example:

```text
C:\Users\<your-user>\.garmin\
```

The exact file name is not important. What matters is that the key is kept safe and not committed.

### Configure the key

Open VS Code settings and search for:

```text
Monkey C: Developer Key Path
```

Point it at the generated developer key.

Garmin requires a developer key to sign Connect IQ builds. Keep this key backed up: the same signing key is required to publish updates to an existing Connect IQ Store app.

### Never commit the key

The repository's `.gitignore` excludes build output (`bin/`, `*.prg`, `*.iq`, `*.debug.xml`) and key files (`*.der`, `*.pem`). Before pushing changes, always check:

```powershell
git status
```

There should be no developer-key file staged for commit.

## Open the project

```powershell
git clone https://github.com/DonalGeraghty/hypnos.git
cd hypnos
code .
```

## Run Hypnos in the Garmin simulator

1. Open the repository in VS Code.
2. Open any `.mc` file under `source/`.
3. Press `F5`, or use **Run -> Run Without Debugging** (`Ctrl+F5`).
4. Select **Forerunner 965** when prompted.
5. Garmin's simulator should launch with the watch face.

If the simulator stays blank, VS Code may have run a unit-test build instead of the app. `.vscode/` is not committed, so create `.vscode/launch.json` with an app launch configuration:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "monkeyc",
            "request": "launch",
            "name": "Run App",
            "stopAtLaunch": false,
            "device": "${command:GetTargetDevice}"
        }
    ]
}
```

Check:

- both rings are drawn, with each arc starting at its hand;
- the step and intensity values are readable along the rings;
- nothing is clipped at the screen edges;
- the rings show as empty tracks when simulator data is unavailable (with `USE_TEST_DATA` set to `false`);
- **Settings -> Low Power Mode** shows only dim hands;
- there are no runtime errors.

## Build a signed PRG for the real watch

First set `USE_TEST_DATA` to `false` in `source/HypnosView.mc`, otherwise the watch shows the sample values.

The easiest route is the Monkey C extension.

1. Connect the Forerunner 965 to the PC using its USB cable.
2. In VS Code press `Ctrl+Shift+P`.
3. Run:

```text
Monkey C: Build for Device
```

4. Select **Forerunner 965**.
5. Choose an output folder.
6. The extension should produce a signed `.prg` file.

If **Forerunner 965** is not offered as a build target, check that:

- the manifest includes the Forerunner 965;
- the correct Connect IQ SDK is active;
- the project API level is compatible with the device.

## Sideload Hypnos onto the Forerunner 965

Garmin's documented sideloading flow is simple:

1. Connect the watch to the PC.
2. Build the project using **Monkey C: Build for Device**.
3. Open the generated output folder.
4. Open the Garmin device in Windows File Explorer.
5. Browse to:

```text
GARMIN\APPS
```

6. Copy the generated Hypnos `.prg` file into that folder.
7. Safely disconnect/eject the watch.
8. Allow the watch a moment to reload the installed apps/watch faces.

You do **not** need to publish Hypnos to the Connect IQ Store just to test it on your own watch.

## Activate Hypnos on the watch

On the Forerunner 965:

1. Start from the normal watch face.
2. Hold **UP / MENU**.
3. Select **Watch Face**.
4. Use **UP** or **DOWN** to browse installed faces.
5. Find **Hypnos**.
6. Press **START**.
7. Select **Apply**.

Hypnos should now be the active watch face.

## Expected appearance

```text
          .-~~~~~~~~~~~-.          outer ring: steps (cyan), starts at the minute hand
        /  .-~~~~~~~~~-. 6400      inner ring: intensity minutes (blue), starts at the hour hand
       |  /             \ 95|
       | |       |       | |       values curve along each ring, past the end of its fill
       | |       o       | |
       | |        \      | |
       |  \       ⚡    /  |       icons at 6 o'clock
        \  '-._____\_.-'  /
          '-.__ 👣 ___.-'
```

In low-power/always-on mode, the face shows only thin, dim hands.

## Troubleshooting

### Monkey C commands do not appear

Make sure the Garmin Monkey C extension is installed and then run:

```text
Monkey C: Verify Installation
```

### Forerunner 965 is not listed

Use:

```text
Monkey C: Edit Products
```

and make sure the Forerunner 965 is selected in the project manifest.

Also confirm the current Connect IQ SDK supports the device.

### Build complains about a developer key

Generate/configure one using:

```text
Monkey C: Generate a Developer Key
```

Then set **Monkey C: Developer Key Path** in VS Code settings.

### A ring is empty or has no value

Activity values can legitimately be empty, especially in the simulator or before the user has set goals. The face then shows that ring as an empty track with no value, instead of throwing an error.

To preview filled rings in the simulator, set `USE_TEST_DATA` to `true`.

### The face works in the simulator but not on the watch

Check:

1. the build target is specifically Forerunner 965;
2. the `.prg` was generated by **Build for Device** rather than merely running a simulator build;
3. the file was copied into `GARMIN/APPS`;
4. the developer signing key is configured;
5. the watch has been safely disconnected from the PC before looking for the face.

## Development rule for the first version

Do not turn this into a full-featured watch face before the basic version has been worn on the physical Forerunner 965.

The first milestone is:

> Clone -> build -> simulator -> signed PRG -> sideload -> select Hypnos -> wear it.

After that, iterate.
