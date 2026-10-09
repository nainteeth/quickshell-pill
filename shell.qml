//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Wayland

ShellRoot {
    id: root

    property string requestedWidget: ""
    // Keep the tray host registered even while its view is unloaded.
    readonly property var trayItems: SystemTray.items

    function present(outputName) {
        if (!requestedWidget)
            return;
        const activeScreens = ToplevelManager.activeToplevel?.screens ?? [];
        pill.screen = Quickshell.screens.find(s => s.name === outputName) ?? activeScreens[0] ?? Quickshell.screens[0];
        pill.widget = requestedWidget;
        pill.open = true;
    }

    function toggle(widget) {
        if (!["clock", "network", "tray", "volume"].includes(widget))
            return;
        if (requestedWidget === widget) {
            hide();
            return;
        }
        requestedWidget = widget;
        if (Quickshell.env("NIRI_SOCKET")) {
            if (!focusedOutput.running)
                focusedOutput.running = true;
        } else {
            present("");
        }
    }

    function hide() {
        requestedWidget = "";
        pill.open = false;
    }

    Process {
        id: focusedOutput
        command: ["niri", "msg", "--json", "focused-output"]
        property string outputName: ""
        onStarted: outputName = ""
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    focusedOutput.outputName = JSON.parse(text)?.name ?? "";
                } catch (error) {
                    focusedOutput.outputName = "";
                }
            }
        }
        onExited: root.present(outputName)
    }

    IpcHandler {
        target: "pill"
        function toggle(widget: string): void {
            root.toggle(widget);
        }
        function hide(): void {
            root.hide();
        }
        function status(): string {
            return root.requestedWidget || "hidden";
        }
    }

    PillWindow {
        id: pill
        onDismissed: root.hide()
    }
}
