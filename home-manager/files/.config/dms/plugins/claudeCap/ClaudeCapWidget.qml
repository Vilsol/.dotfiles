import QtQuick
import Quickshell
import Quickshell.Io

import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.DCommon.Widgets as DC

PluginComponent {
    id: root

    // Index order must match the args passed to claude-cap.
    readonly property var modes: [
        { text: "Normal", arg: "normal" },
        { text: "Game", arg: "game" },
        { text: "Off", arg: "off" },
        { text: "2", arg: "2" },
        { text: "4", arg: "4" },
        { text: "6", arg: "6" }
    ]

    property bool running: false
    property int weight: 0
    property real cores: -1 // -1 = no quota
    property real memGiB: 0

    readonly property int modeIndex: {
        if (!running) return -1
        if (weight === 5 && cores === 6) return 1
        if (cores < 0) return weight === 20 ? 0 : 2
        return [2, 4, 6].indexOf(cores) >= 0 ? [2, 4, 6].indexOf(cores) + 3 : -1
    }
    readonly property string modeLabel: {
        if (!running) return "idle"
        if (modeIndex >= 0) return modes[modeIndex].text.toLowerCase() + (modeIndex >= 3 ? "c" : "")
        return cores < 0 ? `w${weight}` : `${cores}c`
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "d=/sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/claude.slice; cat $d/cpu.weight $d/cpu.max $d/memory.current 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                if (lines.length < 3) {
                    root.running = false
                    return
                }
                const [quota, period] = lines[1].split(" ")
                root.weight = parseInt(lines[0])
                root.cores = quota === "max" ? -1 : parseInt(quota) / parseInt(period)
                root.memGiB = parseInt(lines[2]) / 1073741824
                root.running = true
            }
        }
    }

    Process {
        id: setProc
        onExited: statusProc.running = true
    }

    function setMode(index) {
        setProc.command = ["claude-cap", modes[index].arg]
        setProc.running = true
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS
            opacity: root.running ? 1 : 0.5

            DankIcon {
                name: "speed"
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.running ? `${root.modeLabel} | ${root.memGiB.toFixed(1)}G` : root.modeLabel
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: "Claude CPU cap"
            detailsText: root.running
                ? `weight ${root.weight} · cap ${root.cores < 0 ? "none" : root.cores + " cores"} · mem ${root.memGiB.toFixed(1)}G`
                : "claude.slice is not running"
            showCloseButton: true

            DC.DButtonGroup {
                width: parent.width
                fillWidth: true
                checkEnabled: false
                enabled: root.running
                model: root.modes.map(m => ({ text: m.text }))
                currentIndex: root.modeIndex
                onSelectionChanged: (index, selected) => {
                    if (selected)
                        root.setMode(index)
                }
            }
        }
    }
}
