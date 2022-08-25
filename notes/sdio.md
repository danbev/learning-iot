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

### Registers/addresses
The SD card has a fixed internal register space which allows hosts to obtain
information about the card and perform operations like enabling.

### Common I/O Area (CIA)
This is access by using I/O reads and writes to `Function 0`.

This area contains 3 structures, the `Card Common Control Register (CCCR)`, the
`Function Basic Registers (FBR)`, and the `Card Information Structure (CIS)`:
```
Address                                                        Code Storage Area (CSA)
0x000000 - 0x0000FF CCCR (Card Common Control Register)        +----------------------+
0x000100 - 0x0001FF FBR (Function Base Register 1)             |                      |
           window register-----------------------------------> |                      |
0x000200 - 0x0002FF FBR (Function Base Register 2)             |                      |
           window register-----------------------------------> |                      |
0x000300 - 0x0003FF FBR (Function Base Register 3)             |                      |
           window register-----------------------------------> |                      |
0x000400 - 0x0004FF FBR (Function Base Register 4)             |                      |
           window register-----------------------------------> |                      |
0x000500 - 0x0005FF FBR (Function Base Register 5)             |                      |
           window register-----------------------------------> |                      |
0x000600 - 0x0006FF FBR (Function Base Register 6)             |                      |
           window register-----------------------------------> |                      |
0x000700 - 0x0007FF FBR (Function Base Register 7)             |                      |
           window register-----------------------------------> |                      |
0x000800 - 0x000FFF Reserved for Future Usage (RFU)            |                      |
           window register-----------------------------------> |                      |
                                                               +----------------------+
0x001000 - 0x017FFF CIS (Card Information Regsters) per function.
```

### Card Common Control Register (CCCR)
This register contains information specific to the SD card and also has bit
field entries that are for individual functions.
```
Address
0x00       CCCR/SDIO Revision           8 bits
0x01       SD Specification Revistion   RFU  RFU  RFU  RFU  SD3  SD2  SD1  SD0 
0x02       I/O Enable                   IOE7 IOE6 IOE5 IOE4 IOE3 IOE2 IOE1 RFU
0x03       I/O Ready                    IOR7 IOR6 IOR5 IOR4 IOR3 IOR2 IOR1 RFU
0x04       Interrupt Enable             IEN7 IEN6 IEN5 IEN4 IEN3 IEN2 IEN1 RFU
0x05       Interrupt Pending            INT7 INT6 INT5 INT4 INT3 INT2 INT1 RFU
0x06       I/O Abort                    RFU  RFU  RFU  RFU  RES  AS2  AS1  ASO
0x07       Bus Interface Control        CD   SCSI ECSI RFU  RFU  RFU  BW1  BW0 (Bus Width)
...
0x09-0x0B  Common CIS pointer
```
For example take `I/O Enable` it has 7 entries for functions (not that function
0 is not included which is the function for the Common I/O Area itself.
I think how this works is that this common area, which remember is at a fixed
address can be used to check what functions are available and also enable them,
plus set other card settings. One the host knows that a function is available
it can use the Funtion Base Register for that function by using the index of
the function.

### Function Base Register
Each supported function has a 256-bytes area which is used to allow the host
to query the properties and requirement of the function.
The addresses are from `0x00n00` to `0x00nFF` and these areas have the following
structures (the example below is for function 1, but just replace the one with
any number from 1-7):
```
 Address
 0x100      Function x CSA enable  Function x supports CSA  RFU RFU Function x Standard SDIO Function interface code
 0x101      Function x Extended Standard SDIO Function Interface code 
 0x102      RFU RFU RFU RFU RFU EPS SPS
 0x103-0x108 RFU
 0x109-0x10B Pointer to Function x CIS
 0x10C-0x10E Pointer to Function x CSA
 0x10F       Data access window to Function x CSA
 0x110-0x111 I/O Block size for Function 1

```
Function supports CSA: 1 = this function supports a Code Storage Area.
Function CSA Enable: 1 = access to the Code Storage Area is enabled.

Standard SDIO Function Interface Code:
  0x0 No SDIO standard interface supported by this function
  0x1 SDIO Standard UART
  0x2 SDIO Standard A-Type for Bluethooth standard interface
  0x3 SDIO Standard B-Type for Bluethooth standard interface
  0x4 SDIO GPS standard interface
  0x5 SDIO Camera standard interface
  0x6 SDIO PHS standard interface
  0x7 SDIO WLAN standard interface
  0x8 Embedded SDIO-ATA standard interface


### Card Information Structure (CIS)


### Commands

#### IO_RW_DIRECT (CMD52)
Is used to write a single 8-bit value


```
Start:             1 bit  (always 0)
Direction:         1 bit  (1 for command, 0 for response)
Command index:     6 bits (52 decimal for command 52)
R/W flag:          1 bit  (0 for read, 1 for write)
Function number:   3 bits (select the bus, backplane or radio interface)
RAW flag:          1 bit  (1 to read back result of write)
Unused:            1 bit
Register address: 17 bits (128K address space)
Unused:            1 bit
Data value:        8 bits (byte to be written, unused if read cycle)
CRC:               7 bits (cyclic redundancy check)
End:               1 bit  (always 1)

Total: 48-bits
```

### Operation Conditions Register
There is one such register for each SD card.

From [SDIO Simplified Spec 2.0, 3.2](https://www.csie.ntu.edu.tw/~b94029/Courses/DSD/DSD_Group4/Materials/Simplified_SDIO_Card_Spec.pdf):
```
 Bit posistion         VDD Voltage Window
 0-3                   Reserved
 4                     Reserved
 5                     Reserved
 6                     Reserved
 7                     Reserved
 8                     2.0-2.1
 9                     2.1-2.2
 ...
```

Can be written using IO_SEND_OP_COND (CMD5):
```
  +-----------+-------+-------+----+-+
  |S|D|000101b| RFU   |I/O OCR| CRC|E|
  +-----------+-------+-------+----+-+

S = Start bit. Always 0.
D = Direction bit. 1 means transfer from host to device/card.
Command index = Identifies the command which in this case is CMD5 (101b).
IO/OCR = The supported min/max values for VDD.
CRC = 7 bits CRC
E = End bit. Always 1.
```
The SDIO card will respond with a R4 (Response 4) message in SD mode:
```
  +---------+-------------------+-------------+----+-------+---+-+
  |S|D|C|RFU| Nr of I/O Funtions|Memory Present|RFU|I/O OCR|RFU|E|
  +---------+-------------------+-------------+----+-------+---+-+
S = Start bit. Always 0.
D = Direction bit. 0 means transfer device/card to host.
RFU = Reserved for Future Use. 6 bits
Nr of I/O Functions = The total nr of I/O functions supported by this card.
                      0-7
Memory Present = 1 = the SD card contains memory, and 0 = I/O only.
I/O OCR = The supported min/max values for VDD.
```
When a card/device receives a CMD5 the I/O portion of the card is enabled.


### Status Register
See Section 4.10.8 of 
https://www.csie.ntu.edu.tw/~b94029/Courses/DSD/DSD_Group4/Materials/Simplified_SDIO_Card_Spec.pdf

### IO_RW_DIRECT (CMD52)
Is a way to access a single register within the total 128K register space, using
any I/O Funtion.
```
  +---+-------------+--------+---------------+--------+---+----------------+---+----------------+---+-+
  |S|D|Command Index|R/W flag|Function Number|RAW flag|RFU|Register address|RFU|Write Data/Stuff|CRC|E|
  +---+-------------+--------+---------------+--------+---+----------------+---+----------------+---+-+
   1 1       6          1         3              1      1     17                

S = Start bit. Always 0.
D = Direction bit. Always 1 which means transfer device/card to host.
Command index = Identifies the command which in this case is CMD52 (110100b).
R/W Flag = If this value is set to 0 then the command shall read the value of
           from the SD card at the address specified by the function number and
           the Register Address and return it to the host in a response 5 (R5)
           message. If this bit is 1 then the data in  Write Data shall be
           written to the address location identified by Function Number and
           Register Address. If the RAW flag is 0 then the data in the register
           shall be read and returned in the response.
RAW Flag = Read And Write Flag.
Function Number = The hardware function within the card to read or write to.
                  Function 0 = Common I/O Area (CIA)
Register Address = This is the address of the byte to read/write, inside the
                   Funtion (0-7)
