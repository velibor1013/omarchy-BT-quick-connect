import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.Ui
import qs.Commons

Panel {
    id: root

    moduleName: "velibor1013.bluetooth-quick-connect"
    manageIpc: false

    property var anchorItem: null
    property var hostWidget: null
    property var settings: ({})

    readonly property var devices:
        Bluetooth.devices ? Bluetooth.devices.values : []

    readonly property string selectedAddress:
        String(setting("deviceAddress", ""))

    readonly property string selectedName:
        String(setting("deviceName", ""))

    readonly property string selectedIcon:
    String(
        root.settings &&
        root.settings.iconStyle !== undefined
        ? root.settings.iconStyle
        : "Bluetooth"
    )

    readonly property color foreground:
        root.bar ? root.bar.barForeground : Color.foreground

    readonly property string fontFamily:
        root.bar ? root.bar.fontFamily : Style.font.family

    function availableDevices() {
        var result = []

        for (var i = 0; i < devices.length; i++) {
            var device = devices[i]

            if (!device)
                continue

            if (!device.address)
                continue

            var name = String(
                device.deviceName ||
                device.name ||
                ""
            )

            if (name.length === 0)
                continue

            /*
             * Show devices that BlueZ already knows about.
             */
            if (device.paired ||
                device.bonded ||
                device.trusted ||
                device.connected) {

                result.push(device)
            }
        }

        /*
         * Connected devices first.
         */
        result.sort(function(a, b) {
            if (a.connected && !b.connected)
                return -1

            if (!a.connected && b.connected)
                return 1

            var aName = String(
                a.deviceName ||
                a.name ||
                ""
            )

            var bName = String(
                b.deviceName ||
                b.name ||
                ""
            )

            return aName.localeCompare(bName)
        })

        return result
    }

    function persistSetting(name, value) {
        var entry = {
            id: root.moduleName
        }

        for (var key in root.settings) {
            if (key !== "id")
                entry[key] = root.settings[key]
        }

        entry[name] = value

        root.settings = entry

        if (root.hostWidget)
            root.hostWidget.settings = entry

        if (root.bar &&
            root.bar.shell &&
            typeof root.bar.shell.updateEntryInline === "function") {

            root.bar.shell.updateEntryInline(
                root.moduleName,
                entry
            )
        }
    }

    function selectDevice(device) {
        if (!device || !device.address)
            return

        persistSetting(
            "deviceAddress",
            String(device.address)
        )

        persistSetting(
            "deviceName",
            String(
                device.deviceName ||
                device.name ||
                device.address
            )
        )
    }

    function selectIcon(iconName) {
    /*
     * Update the panel immediately so the selected icon
     * gets highlighted without waiting for a plugin reload.
     */
    var entry = {
        id: root.moduleName
    }

    for (var key in root.settings) {
        if (key !== "id")
            entry[key] = root.settings[key]
    }

    entry.iconStyle = iconName

    root.settings = entry

    if (root.hostWidget)
        root.hostWidget.settings = entry

    if (root.bar &&
        root.bar.shell &&
        typeof root.bar.shell.updateEntryInline === "function") {

        root.bar.shell.updateEntryInline(
            root.moduleName,
            entry
        )
    }
}

    function open() {
        root.controller.show()
    }

    function close() {
        root.controller.hide()
    }

    function toggle() {
        if (root.opened)
            close()
        else
            open()
    }

    function closeForPopoutSwitch() {
        close()
    }

    KeyboardPanel {
        id: panel

        anchorItem: root.anchorItem
        owner: root.hostWidget || root
        bar: root.bar

        open: root.opened

        focusTarget: keyCatcher

        contentWidth:
            panel.fittedContentWidth(
                Style.space(400)
            )

        contentHeight:
            panel.fittedContentHeight(
                content.implicitHeight
            )

        PanelKeyCatcher {
            id: keyCatcher

            anchors.fill: parent

            onCloseRequested: root.close()

            onTabRequested: function(direction) {
                if (root.bar &&
                    typeof root.bar.switchPanelFrom === "function") {

                    root.bar.switchPanelFrom(
                        root.hostWidget || root,
                        direction
                    )
                }
            }

            Flickable {
                anchors.fill: parent

                contentWidth: width
                contentHeight: content.implicitHeight

                clip: true

                boundsBehavior:
                    Flickable.StopAtBounds

                Column {
                    id: content

                    width: parent.width

                    spacing: Style.space(10)

                    /*
                     * Header
                     */
                    Column {
                        width: parent.width

                        spacing: Style.space(2)

                        Text {
                            text: "Bluetooth Quick Connect"

                            color: root.foreground

                            font.family: root.fontFamily
                            font.pixelSize: Style.font.title
                            font.bold: true
                        }

                        Text {
                            width: parent.width

                            text:
                                root.selectedName !== ""
                                ? "Quick-connect target: " +
                                  root.selectedName
                                : "Choose a Bluetooth device."

                            color:
                                Qt.darker(
                                    root.foreground,
                                    1.35
                                )

                            font.family: root.fontFamily
                            font.pixelSize: Style.font.bodySmall

                            wrapMode:
                                Text.WordWrap
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: Style.space(1)

                        color:
                            Qt.darker(
                                root.foreground,
                                2.5
                            )
                    }

                    /*
                     * Device section
                     */
                    Text {
                        text: "Bluetooth device"

                        color: root.foreground

                        font.family: root.fontFamily
                        font.pixelSize: Style.font.body
                        font.bold: true
                    }

                    Text {
                        visible: availableDevices().length === 0

                        width: parent.width

                        text:
                            "No paired Bluetooth devices found."

                        color:
                            Qt.darker(
                                root.foreground,
                                1.35
                            )

                        font.family: root.fontFamily
                        font.pixelSize: Style.font.bodySmall

                        wrapMode:
                            Text.WordWrap
                    }

                    Repeater {
                        model: root.availableDevices()

                        delegate: Rectangle {
                            required property var modelData

                            width: content.width
                            height: Style.space(62)

                            radius:
                                Style.radius.small

                            color:
                                mouse.containsMouse
                                ? Style.hoverFillFor(
                                    root.foreground,
                                    Color.accent
                                )
                                : "transparent"

                            RowLayout {
                                anchors.fill: parent

                                anchors.leftMargin:
                                    Style.space(10)

                                anchors.rightMargin:
                                    Style.space(10)

                                spacing:
                                    Style.space(10)

                                /*
                                 * Bluetooth status icon
                                 */
                                Text {
                                    Layout.preferredWidth:
                                        Style.space(34)

                                    text:
                                        modelData.connected
                                        ? "󰂱"
                                        : "󰂯"

                                    color:
                                        modelData.connected
                                        ? "#98c379"
                                        : root.foreground

                                    font.family:
                                        root.fontFamily

                                    font.pixelSize:
                                        Style.font.title

                                    horizontalAlignment:
                                        Text.AlignHCenter
                                }

                                /*
                                 * Name and state
                                 */
                                ColumnLayout {
                                    Layout.fillWidth: true

                                    spacing: 0

                                    Text {
                                        Layout.fillWidth: true

                                        text:
                                            String(
                                                modelData.deviceName ||
                                                modelData.name ||
                                                modelData.address
                                            )

                                        color:
                                            root.foreground

                                        font.family:
                                            root.fontFamily

                                        font.pixelSize:
                                            Style.font.body

                                        font.bold: true

                                        elide:
                                            Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true

                                        text:
                                            modelData.connected
                                            ? "Connected"
                                            : "Paired"

                                        color:
                                            modelData.connected
                                            ? "#98c379"
                                            : Qt.darker(
                                                root.foreground,
                                                1.4
                                            )

                                        font.family:
                                            root.fontFamily

                                        font.pixelSize:
                                            Style.font.bodySmall
                                    }
                                }

                                /*
                                 * Selected indicator
                                 */
                                Text {
                                    visible:
                                        String(
                                            modelData.address
                                        ) === root.selectedAddress

                                    text: "✓"

                                    color: Color.accent

                                    font.family:
                                        root.fontFamily

                                    font.pixelSize:
                                        Style.font.title
                                }
                            }

                            MouseArea {
                                id: mouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    root.selectDevice(
                                        modelData
                                    )
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: Style.space(1)

                        color:
                            Qt.darker(
                                root.foreground,
                                2.5
                            )
                    }

                    /*
                     * Icon selection
                     */
                    Text {
                        text: "Widget icon"

                        color: root.foreground

                        font.family: root.fontFamily
                        font.pixelSize: Style.font.body
                        font.bold: true
                    }

                    Row {
                        width: parent.width

                        spacing: Style.space(8)

                        Repeater {
                            model: [
                                {
                                    name: "Bluetooth",
                                    icon: "󰂯"
                                },
                                {
                                    name: "Bluetooth Connected",
                                    icon: "󰂱"
                                },
                                {
                                    name: "Headphones",
                                    icon: "󰋋"
                                },
                                {
                                    name: "Speaker",
                                    icon: "󰓃"
                                }
                            ]

                            delegate: Rectangle {
                                required property var modelData

                                width:
                                    Style.space(52)

                                height:
                                    Style.space(48)

                                radius:
                                    Style.radius.small

                                color:
                                    modelData.name ===
                                    root.selectedIcon
                                    ? Style.hoverFillFor(
                                        root.foreground,
                                        Color.accent
                                    )
                                    : "transparent"

                                border.width:
                                    modelData.name ===
                                    root.selectedIcon
                                    ? 1
                                    : 0

                                border.color:
                                    Color.accent

                                Text {
                                    anchors.centerIn: parent

                                    text:
                                        modelData.icon

                                    color:
                                        root.foreground

                                    font.family:
                                        root.fontFamily

                                    font.pixelSize:
                                        Style.font.title
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    hoverEnabled: true

                                    cursorShape:
                                        Qt.PointingHandCursor

                                    onClicked: {
                                        root.selectIcon(
                                            modelData.name
                                        )
                                    }
                                }
                            }
                        }
                    }

                    /*
                     * Explanation
                     */
                    Text {
                        visible:
                            root.selectedAddress !== ""

                        width: parent.width

                        text:
                            "Left click connects or disconnects " +
                            "the selected device. Right click " +
                            "opens this panel."

                        color:
                            Qt.darker(
                                root.foreground,
                                1.45
                            )

                        font.family:
                            root.fontFamily

                        font.pixelSize:
                            Style.font.bodySmall

                        wrapMode:
                            Text.WordWrap
                    }
                }
            }
        }
    }
}