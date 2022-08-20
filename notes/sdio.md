## Secure Digital Input Output (SDIO)
Is a protocol for interfacing between a modem device and a host processor

Specification: https://www.ercankoclar.com/wp-content/uploads/2017/11/SD-InputOutput-SDIO-Card-Specification.pdf

```
    RP Pico Pi W                              CYW34439 (WiFi device)
  +-----------------+                      +----------------------+
  |     Host        |     clock            |      Device          |
  |                 |--------------------->|                      |
  |                 |     cmd              |                      |
  |                 |<-------------------->|                      |
  |                 |     data 0           |                      |
  |                 |<-------------------->|                      |
  |                 |     data 1           |                      |
  |                 |<-------------------->|                      |
  |                 |     data 2           |                      |
  |                 |<-------------------->|                      |
  |                 |     data 3           |                      |
  |                 |<-------------------->|                      |
  |                 |                      |                      |
  +-----------------+                      +----------------------+
```

### Signaling modes
* SPI
Pin 1: Card Select (CS)
Pin 2: Data Input (DI)
Pin 3: VSS1 (GND)
Pin 4: VDD (Supply Voltage)
Pin 5: SCLCK (Clock)
Pin 6: VSS2 (GND)
Pin 7: Data output (DO)
Pin 8: IRQ (Interrupt)
Pin 9: Not used

* 1-bit transfer mode where only dat[0] is used
Pin 1: Not Used
Pin 2: CMD (Command line/wire)
Pin 3: VSS1 (GND)
Pin 4: VDD (Supply Voltage)
Pin 5: CLCK (Clock)
Pin 6: VSS2 (GND)
Pin 7: Data (Data line/wire)
Pin 8: IRQ (Interrupt)
Pin 9: Read Wait (RW (optional))

* 4-bit transfer mode where dat[0]-dat[3] is used
Pin 1: Data[3] (Data line 3)
Pin 2: CMD (Command line/wire)
Pin 3: VSS1 (GND)
Pin 4: VDD (Supply Voltage)
Pin 5: CLCK (Clock)
Pin 6: VSS2 (GND)
Pin 7: Data[0] (Data line 0)
Pin 8: Data[1] (Data line 1 or optionally Interrupt)
Pin 9: Data[2] (Data line 2 or optionally Read Wait)

### Bus protocol
TODO:
