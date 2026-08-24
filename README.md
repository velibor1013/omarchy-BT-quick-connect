# Bluetooth Quick Connect

A small [Omarchy](https://omarchy.org/) bar-widget plugin for quickly connecting to and disconnecting from a selected Bluetooth device.

## Features

* Adds a Bluetooth widget to the Omarchy bar.
* Left-click to connect or disconnect the selected device.
* Right-click to open the device selection panel.
* Lists paired/known Bluetooth devices, with connected devices shown first.
* Remembers your selected Bluetooth device.
* Lets you choose the widget icon: Bluetooth, Bluetooth Connected, Headphones, or Speaker.
* Uses Omarchy's existing Bluetooth/Quickshell integration and the `omarchy-bluetooth-device` command for connection changes.

## Requirements

* [Omarchy](https://omarchy.org/) with plugin support.
* A working Bluetooth adapter and Bluetooth service.
* A paired Bluetooth device to select.

This plugin is written in QML and uses Quickshell APIs provided by Omarchy.

## Installation

The recommended installation method is through the Omarchy plugin marketplace.

If you are installing manually, clone or copy this repository into the location used by your Omarchy installation for local plugins, then enable **Bluetooth Quick Connect** from Omarchy's plugin settings.

> The exact local-plugin installation path can vary with Omarchy versions, so the marketplace is preferred when available.

## Usage

After enabling the plugin:

1. Find the **Bluetooth Quick Connect** widget in the Omarchy bar.
2. **Right-click** the widget to open its settings panel.
3. Choose a paired Bluetooth device.
4. Optionally choose the icon you want displayed in the bar.
5. **Left-click** the widget to connect to the selected device, or disconnect it when it is already connected.

If no device has been selected, left-clicking the widget opens the selection panel instead.

## How it works

The widget reads the live Bluetooth device model exposed by Quickshell and stores the selected device's Bluetooth address and name in the plugin settings. Connection and disconnection are performed through Omarchy's `omarchy-bluetooth-device` helper.

The widget changes its active colour when the selected device is connected while keeping the chosen icon glyph.

## Configuration

Configuration is available directly from the widget's right-click panel:

* **Bluetooth device** — select the device used by left-click connect/disconnect.
* **Widget icon** — choose the icon displayed in the bar.

Settings are persisted by the Omarchy plugin system.

## Troubleshooting

### No devices are shown

Make sure your Bluetooth adapter and Bluetooth service are working and that the device has already been paired. The plugin lists devices that Omarchy/BlueZ knows about and that are paired, bonded, trusted, or currently connected.

### Clicking does nothing

Verify that the selected device still exists and that Omarchy's `omarchy-bluetooth-device` command is available. You can also reopen the panel and select the device again.

### The widget is not visible

Confirm that the plugin is enabled and that the **Bluetooth Quick Connect** bar widget is placed in your active bar configuration.

## Compatibility

The plugin targets Omarchy's current plugin/bar-widget APIs and Quickshell Bluetooth integration. Compatibility may depend on the Omarchy version installed on your system.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Issues and pull requests are welcome. If you find a compatibility problem with a newer Omarchy release, please include your Omarchy version and relevant logs or error messages when reporting it.
