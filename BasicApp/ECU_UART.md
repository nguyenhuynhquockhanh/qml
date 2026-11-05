# ECU UART input

The cluster reads one UTF-8 JSON object per line from the STM32 serial port.
Default settings: auto-detect a USB serial device, 115200 baud, 8N1. On the
current Pi, the device is `/dev/ttyACM0`, with the stable path
`/dev/serial/by-id/usb-FIREPHX_USB_SER_FX2348N-if00`. The Flask server is not
required for the Qt dashboard; both can consume the same JSON schema, but only
one process can own a serial port at a time.

Example packet:

```json
{"spd": 90, "brk": 1, "snL": 49, "snR": 255}
```

| JSON field | Cluster behavior |
| --- | --- |
| `spd` | Speed in km/h, limited to the gauge's 0–240 range. |
| `brk` | Nonzero shows the two brake indicators; zero hides them. |
| `snL` | Left blind spot blinks when distance is less than 50 cm. |
| `snR` | Right blind spot blinks when distance is less than 50 cm. |

The aliases `Speed`, `Brake`, `Sonar_L`, and `Sonar_R` are also accepted. Missing
fields retain their last value. Invalid JSON is ignored. After 3 seconds
without a valid packet, all four values reset to zero/off. The UART adapter
retries the port every 2 seconds after a disconnect. RPM stays at zero until
the ECU protocol supplies it; the former speed based estimate was removed.

Set the port or baud rate before launching the application if needed:

```sh
ECU_SERIAL_PORT=/dev/serial/by-id/usb-FIREPHX_USB_SER_FX2348N-if00 \
ECU_BAUD_RATE=115200 ./BasicApp -platform eglfs
```

To replace UART with SPI later, implement a new input adapter that forwards
each JSON line to `EcuDataModel::applyJsonLine()` and remove
`UartTelemetrySource` from `main.cpp`. The QML bindings do not change.
