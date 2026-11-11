# Cluster CAN input

The Raspberry Pi receives classical CAN frames from Linux SocketCAN on `can0`
at 125 kbit/s. This cluster only monitors the bus, so configure the MCP2515
in **listen-only** mode before starting the dashboard:

```sh
sudo ip link set can0 down
sudo ip link set can0 type can bitrate 125000 listen-only on
sudo ip link set can0 up
/home/ras/BasicApp/bin/BasicApp -platform eglfs
```

The dashboard uses a nonblocking CAN raw socket with filters for only three
standard data IDs. It reads frames on Qt's event loop; no serial device, JSON
bridge, polling thread, or QtSerialBus module is needed. It never sends CAN
frames or configures the interface. In normal mode, the MCP2515 can still
send hardware ACK/error bits even when the app only reads and the Linux TX
packet counter remains zero. Listen-only mode prevents that bus activity.
It requires another active CAN node to acknowledge transmitted frames.

Check the active mode and error counters with
`ip -details -statistics link show can0`. If bus errors continue in listen-only
mode, check transceiver wiring, common ground, termination, and timing. The
provided STM32 settings imply a 125 kbit/s bit rate with a 75% sample point;
the Pi's previously observed default was 87.5%.
The `ip link` setting is not persistent across reboot; use the same
listen-only command in the Pi's privileged CAN startup configuration.

| CAN ID | Payload | Display |
| --- | --- | --- |
| `0x020` | Byte 0: nonzero means brake/AEB active. | Show both brake icons while active. |
| `0x040` | Bytes 0/1/2: left/center/right ultrasonic distance in cm. | Blink left/right blind-spot icons while the corresponding distance is below 50 cm. Center is unused. |
| `0x080` | Bytes 0–1: signed 16-bit motor RPM, little-endian; STM32 sends DLC 8 every 100 ms. | Show actual RPM and map 280 motor RPM to 240 km/h for the simulated speedometer. |

The STM32 firmware provided by the project computes RPM from the encoder
counter using `ENCODER_CPR` and its 10 ms control period before it sends ID
`0x080`. The Pi therefore reads RPM directly; it does not calculate raw pulses.
The speed mapping is **simulation only**, because no wheel size or gear ratio is
defined. To change the scale without rebuilding, set
`ECU_MOTOR_RPM_AT_240KMH` to the motor RPM corresponding to 240 km/h.
`ECU_CAN_INTERFACE` can select an interface other than `can0`.

The source reconnects every two seconds if `can0` is unavailable. Each signal
group has its own 3-second timeout, so a continuing RPM stream cannot keep an
old brake or blind-spot warning on screen. The model clears all values after a
socket disconnect. Other CAN IDs do not affect the cluster.
