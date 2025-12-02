# BLE-M3 Android Interceptor

## Project Overview

BLE-M3 is a C-based input event interceptor designed for Android devices. It translates BLE (Bluetooth Low Energy) clicker device movements into Android keypresses, effectively repurposing mouse-like input devices for keyboard functionality.

### Origin
This project is a fork of [Beauty-R1](https://github.com/olivluca/bluetooth-tiktok-remote), adapted for BLE-M3 clicker devices.

### Purpose
The program intercepts input events from BLE clicker devices and translates them into Android keypress events, enabling BLE clickers to control Android applications through keypress events.

## Technical Architecture

### Core Functionality

The program operates at a low level, directly interfacing with Linux input device nodes (`/dev/input/eventX`) on Android.

**Key Components:**

1. **Device Detection** (BLE-M3.c:58-161)
   - Scans `/dev/input/` directory for devices named "BLE-M3"
   - Uses `inotify` to monitor for device connection events
   - Grabs exclusive access to the device using `EVIOCGRAB`

2. **Event Processing** (BLE-M3.c:380-427)
   - Reads `input_event` structures from the device file descriptor
   - Processes `EV_ABS` (absolute positioning) and `EV_KEY` (button) events
   - Translates device coordinates into directional input

3. **Input Translation**
   - **Directional Input:** X/Y coordinate changes mapped to UP/DOWN/LEFT/RIGHT
   - **Button Input:** Center button press at coordinates (300, 456) mapped to ENTER
   - **Photo Button:** Specific coordinate pattern triggers camera key
   - **Long Press:** Volume key events with timing logic for extended presses

### Input Mapping

The program defines two output modes:

#### Default Mode (keyevent)
Uses Android's `input keyevent` command:
- UP: AKEYCODE_DPAD_UP (19)
- DOWN: AKEYCODE_DPAD_DOWN (20)
- LEFT: AKEYCODE_DPAD_LEFT (21)
- RIGHT: AKEYCODE_DPAD_RIGHT (22)
- ENTER: AKEYCODE_ENTER (66)
- PHOTO: AKEYCODE_CAMERA (27)
- LONG_UP: AKEYCODE_CALL (5)
- LONG_DOWN: AKEYCODE_MUTE (91)
- LONG_LEFT: AKEYCODE_MEDIA_PREVIOUS (88)
- LONG_RIGHT: AKEYCODE_MEDIA_NEXT (87)

#### Event Mode (am broadcast)
Uses Android's Activity Manager to broadcast intents:
- Sends broadcast actions like `com.BLE-M3.UP`, `com.BLE-M3.DOWN`, etc.
- Allows custom application integration

### Coordinate System Logic

The device uses a coordinate-based input system:

- **Center Position:** (1904, 1904)
- **Photo Button:** (1536, 608)
- **Enter Button:** (300, 456)
- **Long Press Indicator:** X=2048 with Y=784 (long up) or Y=2912 (long down)

Direction detection:
- Movement from center coordinates determines direction
- Edge case handling for left movement (Y coordinate adjustment to 390)
- Photo button has special coordinates (X=213)

## Build System

### Toolchain
- **Compiler:** ARM GNU Toolchain 14.2.rel1
- **Target:** arm-none-linux-gnueabihf
- **Flags:** `--static` (statically linked binary)

### Compilation

Local compilation:
```bash
arm-none-linux-gnueabihf-gcc --static BLE-M3.c -o BLE-M3
```

### CI/CD
GitHub Actions workflow (`.github/workflows/main.yaml`):
- Triggers on pushes to master and version tags
- Downloads ARM toolchain
- Builds static binary
- Creates GitHub releases on version tags
- Uploads artifacts for all builds

## Deployment

### Requirements
- Android device with root/adb access
- BLE-M3 clicker device paired via Bluetooth
- Access to `/dev/input/` devices

### Installation
```bash
adb push BLE-M3 /data/local/tmp/
adb shell chmod +x /data/local/tmp/BLE-M3
```

### Usage Modes

1. **Default Mode** (input keyevent):
   ```bash
   adb shell /data/local/tmp/BLE-M3
   ```

2. **Event Mode** (am broadcast):
   ```bash
   adb shell /data/local/tmp/BLE-M3 am
   ```

3. **Debug Mode** (print all events):
   ```bash
   adb shell /data/local/tmp/BLE-M3 debug
   ```

### Automation
Can be automated using Tasker or Automate:
- Detect BLE-M3 connection event
- Execute binary via ADB shell command
- Eliminates need for persistent adb connection

## Key Implementation Details

### Process Management
- Uses `fork()` to execute keypress injection commands asynchronously (BLE-M3.c:167-193)
- `signal(SIGCHLD, SIG_IGN)` prevents zombie processes (BLE-M3.c:393)

### Timing Logic
- Long press detection uses `timersub()` for precise timing comparisons (BLE-M3.c:288-297)
- 1.3-second threshold to distinguish long presses from repeated events
- Debouncing logic prevents event repetition

### Device Lifecycle
- Continuous reconnection loop (BLE-M3.c:395)
- Automatically reopens device on disconnection
- Uses `inotify` for hot-plug detection

## File Structure

```
.
├── BLE-M3.c              # Main program source
├── keycodes.h            # Android keycode definitions (from AOSP)
├── compile               # Legacy compilation script
├── README.md             # User documentation
├── LICENSE               # GPL v3 license
├── BLE-M3.jpg            # Device image
└── .github/
    └── workflows/
        └── main.yaml     # CI/CD workflow
```

## Dependencies

### System Headers
- `linux/input.h` - Linux input subsystem structures
- `sys/inotify.h` - File system event monitoring
- Standard C library (statically linked)

### Android Components
- `input` binary - For keyevent injection
- `am` (Activity Manager) - For broadcast events

## Security Considerations

1. **Root/ADB Access Required:** Program needs elevated privileges to access `/dev/input/`
2. **Exclusive Device Grab:** Uses `EVIOCGRAB` to prevent other apps from receiving events
3. **Command Injection Risk:** Uses `system()` calls with formatted strings (limited risk as input is controlled)

## Known Limitations

1. Requires persistent process or automation setup
2. Hardcoded coordinate values specific to BLE-M3 device
3. No configuration file support
4. Single device support at a time

## Development Notes

### Code Style
- C99 standard
- Minimal dependencies
- Static compilation for portability
- GPL v3 licensed

### Future Considerations
- Configuration file support for coordinate customization
- Multiple device support
- udev rules for automatic startup
- Native Android app wrapper

## Testing

Manual testing workflow:
1. Connect BLE-M3 device to Android
2. Start program via adb
3. Test directional inputs
4. Test button presses
5. Test long press functionality
6. Verify keypress injection in target app

## Contributing

When modifying this project:
- Maintain GPL v3 license compatibility
- Test on actual Android hardware
- Document coordinate changes if device specifications differ
- Sign commits with DCO sign-off
- Update README.md with functional changes

## References

- Original project: https://github.com/olivluca/bluetooth-tiktok-remote
- Android keycodes: AOSP frameworks/base/include/android/keycodes.h
- Linux input subsystem: kernel.org/doc/html/latest/input/
