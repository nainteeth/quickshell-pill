# Pill

A small, on-demand Quickshell panel for Niri. It starts hidden and opens at the top center of the focused monitor, over windows and fullscreen applications. It reserves no desktop space and only its visible shape accepts pointer input.

| Shortcut | Widget |
| --- | --- |
| Super + Alt + C | Clock and date |
| Super + Alt + N | Networking |
| Super + Alt + T | System tray |
| Super + Alt + V | Volume and app mixer |

Press the same shortcut again to hide the pill. A different shortcut switches widgets. There is no timeout or outside-click dismissal. Escape also closes it when the pill has keyboard focus; simply viewing the clock does not take focus from your application.

## Run

Requires Quickshell **0.3.1 or newer**, Qt Quick Controls, PipeWire/WirePlumber, and NetworkManager. `nm-connection-editor` provides the network Settings button. These dependencies are already installed on this machine. Icons are bundled SVGs; no icon font is required.

```sh
quickshell --no-duplicate --path ~/.config/quickshell
```

Niri loads the startup command and keybinds from `integration/niri.kdl` through this line in `~/.config/niri/config.kdl`:

```kdl
include "/home/nainteeth/.config/quickshell/integration/niri.kdl"
```

Niri applies bindings on reload. Startup commands take effect on the next login; the shell can also be started with the command above. The integration uses this machine's absolute path, so change it if moving the config. Waybar is configured separately in Niri.

## Controls

- **Network:** toggle Wi-Fi, connect to nearby or saved networks, enter WPA/WPA2/WPA3 personal passwords, and click the connected network to disconnect. Scanning stops when the panel is hidden. Enterprise, hidden networks, and VPN profiles can be configured through Settings.
- **Volume:** drag a slider, use its scroll wheel, or click its speaker to mute. App playback streams appear and disappear automatically; apps with multiple streams can have multiple rows. Sliders run from 0–100%, and raising a slider unmutes that stream.
- **Tray:** left click activates an app, right click opens its menu, middle click sends its secondary action, and scrolling is forwarded to it. Menu-only items open their menu on left click.
- **Clock:** local 24-hour time, weekday, and date, updated every minute.

## Customize

`Theme.qml` contains colors, font, animation duration, and top spacing. The default is charcoal with a mint accent and Cantarell text. `integration/niri.kdl` contains the shortcuts.

`shell.qml` handles IPC and monitor selection. `PillWindow.qml` handles the overlay, input mask, and animations. Each view lives in `widgets/`, and reusable controls live in `components/`. Quickshell automatically reloads QML changes.

The IPC interface can also be called from another compositor:

```sh
quickshell ipc --path ~/.config/quickshell call pill toggle clock
quickshell ipc --path ~/.config/quickshell call pill toggle network
quickshell ipc --path ~/.config/quickshell call pill toggle tray
quickshell ipc --path ~/.config/quickshell call pill toggle volume
quickshell ipc --path ~/.config/quickshell call pill hide
quickshell ipc --path ~/.config/quickshell call pill status
```

On Niri, each opening uses its focused output. Other Wayland compositors use the active toplevel's screen when available, otherwise the first screen.

Native API references: [Networking](https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/), [PipeWire](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/), and [System tray](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.SystemTray/).
# quickshell-pill
