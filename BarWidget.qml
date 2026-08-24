import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.Ui
import qs.Commons

BarWidget {
    id: root

    moduleName: "velibor1013.bluetooth-quick-connect"

    readonly property string selectedAddress:
        String(setting("deviceAddress", ""))

    readonly property string selectedName:
        String(setting("deviceName", ""))

    readonly property string iconStyle:
        String(
            root.settings &&
            root.settings.iconStyle !== undefined
            ? root.settings.iconStyle
            : "Bluetooth"
        )

    /*
     * Same Bluetooth model used by Omarchy's native Bluetooth panel.
     */
    readonly property var devices:
        Bluetooth.devices ? Bluetooth.devices.values : []

    /*
     * Find the selected device in the live Bluetooth device model.
     */
    function findSelectedDevice() {
        var list = devices

        for (var i = 0; i < list.length; i++) {
            var device = list[i]

            if (device &&
                String(device.address || "") === selectedAddress) {
                return device
            }
        }

        return null
    }

    /*
     * Read the live connection state.
     */
    function isSelectedConnected() {
        var device = findSelectedDevice()

        return device !== null &&
               device.connected === true
    }

    readonly property bool selectedConnected:
        isSelectedConnected()

    /*
     * The icon is determined ONLY by the user's selection.
     *
     * Connection state changes the color, not the glyph.
     */
    readonly property string iconGlyph: {
        switch (iconStyle) {
        case "Mouse":
            return "󰍽"

        case "Headphones":
            return "󰋋"

        case "Speaker":
            return "󰓃"

        default:
            return "󰂯"
        }
    }

    /*
     * Green connected state.
     */
    readonly property color connectedColor: "#98c379"

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

        if (root.bar &&
            root.bar.shell &&
            typeof root.bar.shell.updateEntryInline === "function") {

            root.bar.shell.updateEntryInline(
                root.moduleName,
                entry
            )
        }

        if (panelLoader.item)
            panelLoader.item.settings = entry
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

    /*
     * Left click toggles the selected device:
     *
     * disconnected -> connect
     * connected    -> disconnect
     */
    function toggleSelectedConnection() {
        if (!selectedAddress) {
            open()
            return
        }

        if (isSelectedConnected()) {
            Quickshell.execDetached([
                "omarchy-bluetooth-device",
                "disconnect",
                selectedAddress
            ])
        } else {
            Quickshell.execDetached([
                "omarchy-bluetooth-device",
                "connect",
                selectedAddress
            ])
        }
    }

    function open() {
        if (panelLoader.item)
            panelLoader.item.open()
    }

    function close() {
        if (panelLoader.item)
            panelLoader.item.close()
    }

    function toggle() {
        if (panelLoader.item)
            panelLoader.item.toggle()
    }

    function closeForPopoutSwitch() {
        if (panelLoader.item &&
            typeof panelLoader.item.closeForPopoutSwitch === "function") {

            panelLoader.item.closeForPopoutSwitch()
        } else {
            close()
        }
    }

    function injectPanel() {
        if (!panelLoader.item)
            return

        panelLoader.item.bar = root.bar
        panelLoader.item.anchorItem = button
        panelLoader.item.hostWidget = root
        panelLoader.item.settings = root.settings
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    onBarChanged: injectPanel()
    onSettingsChanged: injectPanel()

    Loader {
        id: panelLoader

        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false

        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }

    WidgetButton {
        id: button

        anchors.fill: parent

        bar: root.bar

        text: root.iconGlyph

        /*
         * Connection state controls the active color.
         * The selected glyph remains unchanged.
         */
        active: root.selectedConnected
        activeColor: root.connectedColor
        useActiveColor: true

        tooltipText: {
            if (!root.selectedAddress)
                return "Right-click to choose a Bluetooth device"

            if (root.selectedConnected)
                return "Disconnect " + root.selectedName

            return "Connect " + root.selectedName
        }

        onPressed: function(buttonCode) {
            if (buttonCode === Qt.RightButton) {
                root.open()
            } else if (buttonCode === Qt.LeftButton) {
                root.toggleSelectedConnection()
            }
        }
    }
}
