# Hypnos

Hypnos is a minimal, sleep/recovery-oriented Garmin watch face for the **Garmin Forerunner 965**.

The first version is intentionally small: get a clean watch face building in Garmin's simulator and running on the physical watch before adding customization or extra features.

See [MVP_PLAN.md](./MVP_PLAN.md) for the implementation specification and acceptance criteria.

## MVP

The planned first version displays:

- large digital time;
- date;
- Body Battery;
- heart rate;
- daily steps;
- watch battery percentage.

The design targets the Forerunner 965's **454 x 454 round AMOLED display** and uses a black background with a reduced low-power display.

### Why Sleep Score is not in the MVP

Hypnos is intended to be sleep/recovery focused, but Garmin currently lists the Forerunner 965 at **Connect IQ API level 5.2**.

Garmin's built-in Sleep Score complication, `COMPLICATION_TYPE_SLEEP_SCORE`, was introduced at **API level 6.0.2**.

Body Battery and heart rate are available through the older Complications API supported by the Forerunner 965, so Body Battery is the primary recovery metric for the MVP.

Do not work around this with phone networking or unofficial data scraping. If Garmin exposes Sleep Score to the 965 through a compatible API later, it can be added in a later version.

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

Install a current Connect IQ SDK that supports the Forerunner 965.

When the project has been implemented, the Forerunner 965 should appear as a valid build/simulator target.

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

The implementation should add a `.gitignore` covering at least:

```gitignore
bin/
*.prg
*.iq
*.debug.xml
*.der
*.pem
```

Before pushing changes, always check:

```powershell
git status
```

There should be no developer-key file staged for commit.

## Open the project

When you are home and have cloned/opened the repository:

```powershell
git clone https://github.com/DonalGeraghty/hypnos.git
cd hypnos
code .
```

Once the implementation pass has created the Connect IQ project files, the repository root should contain files such as:

```text
monkey.jungle
manifest.xml
source/
resources/
```

## Run Hypnos in the Garmin simulator

After the MVP implementation exists:

1. Open the repository in VS Code.
2. Open any `.mc` file under `source/`.
3. Use **Run -> Run Without Debugging**, or press `Ctrl+F5`.
4. Select **Forerunner 965** when prompted.
5. Garmin's simulator should launch with the watch face.

Check:

- the display is round and 454 x 454;
- the time is centered and readable;
- nothing is clipped at the screen edges;
- date is visible;
- Body Battery / HR can safely display `--` when simulator data is unavailable;
- steps and battery render correctly;
- there are no runtime errors.

## Build a signed PRG for the real watch

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

## Expected MVP appearance

The exact pixel spacing may change during simulator testing, but the intended hierarchy is roughly:

```text
              BB 72

             12:36
           FRI 02 OCT

       HR 58   8.4k   82%
```

The active face should be clean and readable. In low-power/always-on mode, the MVP should reduce the display significantly, ideally to the time only.

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

### The watch face builds but a metric is blank

Body Battery and heart-rate complications can legitimately return no current value.

The MVP implementation should render:

```text
--
```

instead of throwing an error.

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
