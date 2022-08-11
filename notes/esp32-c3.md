## ESP32-C3-MINI-1
This is based on a RISC-V single core processor (up to 160MHz), and has 15 GPIO
pins, 4 MB of on chip flash from Espressif Systems.

![ESP32-C3-MINI-1 image](./img/esp32-c3-mini1.jpg "Image of ESP32-C3-MINI-1")

### Datasheet for ESP32-C3-MINI-1
https://www.espressif.com/sites/default/files/documentation/esp32-c3-mini-1_datasheet_en.pdf

### Technical Reference Manual ESP32-C3
https://www.espressif.com/sites/default/files/documentation/esp32-c3_technical_reference_manual_en.pdf#page33

### openocd
We need to build the fork of OpenOCD:
```console
$ git clone git@github.com:espressif/openocd-esp32.git
$ ./bootstrap.sh
$ ./configure
$ make
```
The `openocd` executable can then be found in `./src/openocd`:
```console
$ ./src/openocd -v
Open On-Chip Debugger  v0.11.0-esp32-20220706-47-g9d742a71 (2022-08-08-15:14)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
```

```console
$ ./src/openocd -s tcl -f board/esp32c3-builtin.cfg
Open On-Chip Debugger  v0.11.0-esp32-20220706-47-g9d742a71 (2022-08-08-15:14)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
Info : only one transport option; autoselect 'jtag'
Info : esp_usb_jtag: VID set to 0x303a and PID to 0x1001
Info : esp_usb_jtag: capabilities descriptor set to 0x2000
Warn : Transport "jtag" was already selected
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Error: esp_usb_jtag: could not find or open device!

Error: Unsupported xlen: -1
Error: Unknown target arch!
```
Trying to rule out things I installed
[esp-idf](https://github.com/espressif/esp-idf.git):
```console
$ git clone --recursive https://github.com/espressif/esp-idf.git
$ cd esp-idf
$ ./install.sh esp32c3
$ . ./export.sh
```
I'm trying to rule out any issue with the USB cable which I've seen mentioned
in the documentation and in forum posts:
```console
$ esptool.py chip_id
esptool.py v4.2
Found 2 serial ports
Serial port /dev/ttyUSB0
Connecting....
Detecting chip type... ESP32-C3
Chip is ESP32-C3 (revision 3)
Features: Wi-Fi
Crystal is 40MHz
MAC: a0:76:4e:5a:e2:80
Uploading stub...
Running stub...
Stub running...
Warning: ESP32-C3 has no Chip ID. Reading MAC instead.
MAC: a0:76:4e:5a:e2:80
Hard resetting via RTS pin...
```
Now, if there was an issue with the cable the above command would timeout I
think.
```console
$ esptool.py flash_id
esptool.py v4.2
Found 2 serial ports
Serial port /dev/ttyUSB0
Connecting....
Detecting chip type... ESP32-C3
Chip is ESP32-C3 (revision 3)
Features: Wi-Fi
Crystal is 40MHz
MAC: a0:76:4e:5a:e2:80
Uploading stub...
Running stub...
Stub running...
Manufacturer: 20
Device: 4016
Detected flash size: 4MB
Hard resetting via RTS pin...
```

```
$ espefuse.py --port /dev/ttyUSB0 summary
espefuse.py v4.2
Connecting....
Detecting chip type... ESP32-C3

=== Run "summary" command ===
EFUSE_NAME (Block) Description  = [Meaningful Value] [Readable/Writeable] (Hex Value)
----------------------------------------------------------------------------------------
Config fuses:
DIS_ICACHE (BLOCK0)                                Disables ICache                                    = False R/W (0b0)
DIS_DOWNLOAD_ICACHE (BLOCK0)                       Disables Icache when SoC is in Download mode       = False R/W (0b0)
DIS_FORCE_DOWNLOAD (BLOCK0)                        Disables forcing chip into Download mode           = False R/W (0b0)
DIS_CAN (BLOCK0)                                   Disables the TWAI Controller hardware              = False R/W (0b0)
VDD_SPI_AS_GPIO (BLOCK0)                           Set this bit to vdd spi pin function as gpio       = False R/W (0b0)
BTLC_GPIO_ENABLE (BLOCK0)                          Enable btlc gpio                                   = 0 R/W (0b00)
POWERGLITCH_EN (BLOCK0)                            Set this bit to enable power glitch function       = False R/W (0b0)
POWER_GLITCH_DSENSE (BLOCK0)                       Sample delay configuration of power glitch         = 0 R/W (0b00)
DIS_DIRECT_BOOT (BLOCK0)                           Disables direct boot mode                          = False R/W (0b0)
DIS_USB_SERIAL_JTAG_ROM_PRINT (BLOCK0)             Disables USB-Serial-JTAG ROM printing              = False R/W (0b0)
UART_PRINT_CONTROL (BLOCK0)                        Sets the default UART boot message output mode     = Enabled R/W (0b00)
FORCE_SEND_RESUME (BLOCK0)                         Force ROM code to send a resume command during SPI = False R/W (0b0)
                                                    bootduring SPI boot                              
ERR_RST_ENABLE (BLOCK0)                            Use BLOCK0 to check error record registers         = without check R/W (0b0)
BLOCK_USR_DATA (BLOCK3)                            User data                                         
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W 

Efuse fuses:
WR_DIS (BLOCK0)                                    Disables programming of individual eFuses          = 0 R/W (0x00000000)
RD_DIS (BLOCK0)                                    Disables software reading from BLOCK4-10           = 0 R/W (0b0000000)

Flash Config fuses:
FLASH_TPUW (BLOCK0)                                Configures flash startup delay after SoC power-up, = 0 R/W (0x0)
                                                    unit is (ms/2). When the value is 15, delay is 7.
                                                   5 ms                                              

Identity fuses:
SECURE_VERSION (BLOCK0)                            Secure version (used by ESP-IDF anti-rollback feat = 0 R/W (0x0000)
                                                   ure)                                              
MAC (BLOCK1)                                       Factory MAC Address                               
   = a0:76:4e:5a:e2:80 (OK) R/W 
WAFER_VERSION (BLOCK1)                             WAFER version                                      = 3 R/W (0b011)
PKG_VERSION (BLOCK1)                               Package version                                    = ESP32-C3 R/W (0b000)
BLOCK1_VERSION (BLOCK1)                            BLOCK1 efuse version                               = 4 R/W (0b100)
OPTIONAL_UNIQUE_ID (BLOCK2)                        Optional unique 128-bit ID                        
   = de 62 ee 68 aa 9c 88 da 66 74 55 b8 ac 8e 6a 9d R/W 
BLOCK2_VERSION (BLOCK2)                            Version of BLOCK2                                  = 7 R/W (0b111)
CUSTOM_MAC (BLOCK3)                                Custom MAC Address                                
   = 00:00:00:00:00:00 (OK) R/W 

Jtag Config fuses:
SOFT_DIS_JTAG (BLOCK0)                             Software disables JTAG. When software disabled, JT = 0 R/W (0b000)
                                                   AG can be activated temporarily by HMAC peripheral
DIS_PAD_JTAG (BLOCK0)                              Permanently disable JTAG access via pads. USB JTAG = False R/W (0b0)
                                                    is controlled separately.                        

Security fuses:
DIS_DOWNLOAD_MANUAL_ENCRYPT (BLOCK0)               Disables flash encryption when in download boot mo = False R/W (0b0)
                                                   des                                               
SPI_BOOT_CRYPT_CNT (BLOCK0)                        Enables encryption and decryption, when an SPI boo = Disable R/W (0b000)
                                                   t mode is set. Enabled when 1 or 3 bits are set,di
                                                   sabled otherwise                                  
SECURE_BOOT_KEY_REVOKE0 (BLOCK0)                   If set, revokes use of secure boot key digest 0    = False R/W (0b0)
SECURE_BOOT_KEY_REVOKE1 (BLOCK0)                   If set, revokes use of secure boot key digest 1    = False R/W (0b0)
SECURE_BOOT_KEY_REVOKE2 (BLOCK0)                   If set, revokes use of secure boot key digest 2    = False R/W (0b0)
KEY_PURPOSE_0 (BLOCK0)                             KEY0 purpose                                       = USER R/W (0x0)
KEY_PURPOSE_1 (BLOCK0)                             KEY1 purpose                                       = USER R/W (0x0)
KEY_PURPOSE_2 (BLOCK0)                             KEY2 purpose                                       = USER R/W (0x0)
KEY_PURPOSE_3 (BLOCK0)                             KEY3 purpose                                       = USER R/W (0x0)
KEY_PURPOSE_4 (BLOCK0)                             KEY4 purpose                                       = USER R/W (0x0)
KEY_PURPOSE_5 (BLOCK0)                             KEY5 purpose                                       = USER R/W (0x0)
SECURE_BOOT_EN (BLOCK0)                            Enables secure boot                                = False R/W (0b0)
SECURE_BOOT_AGGRESSIVE_REVOKE (BLOCK0)             Enables aggressive secure boot key revocation mode = False R/W (0b0)
DIS_DOWNLOAD_MODE (BLOCK0)                         Disables all Download boot modes                   = False R/W (0b0)
ENABLE_SECURITY_DOWNLOAD (BLOCK0)                  Enables secure UART download mode (read/write flas = False R/W (0b0)
                                                   h only)                                           
BLOCK_KEY0 (BLOCK4)
  Purpose: USER
               Encryption key0 or user data                      
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W 
BLOCK_KEY1 (BLOCK5)
  Purpose: USER
               Encryption key1 or user data                      
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W 
BLOCK_KEY2 (BLOCK6)
  Purpose: USER
               Encryption key2 or user data                      
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W 
BLOCK_KEY3 (BLOCK7)
  Purpose: USER
               Encryption key3 or user data                      
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W 
BLOCK_KEY4 (BLOCK8)
  Purpose: USER
               Encryption key4 or user data                      
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W 
BLOCK_KEY5 (BLOCK9)
  Purpose: USER
               Encryption key5 or user data                      
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W 
BLOCK_SYS_DATA2 (BLOCK10)                          System data (part 2)                              
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W 

Spi_Pad_Config fuses:
SPI_PAD_CONFIG_CLK (BLOCK1)                        SPI CLK pad                                        = 0 R/W (0b000000)
SPI_PAD_CONFIG_Q (BLOCK1)                          SPI Q (D1) pad                                     = 0 R/W (0b000000)
SPI_PAD_CONFIG_D (BLOCK1)                          SPI D (D0) pad                                     = 0 R/W (0b000000)
SPI_PAD_CONFIG_CS (BLOCK1)                         SPI CS pad                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_HD (BLOCK1)                         SPI HD (D3) pad                                    = 0 R/W (0b000000)
SPI_PAD_CONFIG_WP (BLOCK1)                         SPI WP (D2) pad                                    = 0 R/W (0b000000)
SPI_PAD_CONFIG_DQS (BLOCK1)                        SPI DQS pad                                        = 0 R/W (0b000000)
SPI_PAD_CONFIG_D4 (BLOCK1)                         SPI D4 pad                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_D5 (BLOCK1)                         SPI D5 pad                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_D6 (BLOCK1)                         SPI D6 pad                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_D7 (BLOCK1)                         SPI D7 pad                                         = 0 R/W (0b000000)

Usb Config fuses:
DIS_USB_JTAG (BLOCK0)                              Disables USB JTAG. JTAG access via pads is control = False R/W (0b0)
                                                   led separately                                    
DIS_USB_DEVICE (BLOCK0)                            Disables USB DEVICE                                = False R/W (0b0)
USB_EXCHG_PINS (BLOCK0)                            Exchanges USB D+ and D- pins                       = False R/W (0b0)
DIS_USB_SERIAL_JTAG_DOWNLOAD_MODE (BLOCK0)         Disables USB-Serial-JTAG download feature in UART  = False R/W (0b0)
                                                   download boot mode                                

Wdt Config fuses:
WDT_DELAY_SEL (BLOCK0)                             Selects RTC WDT timeout threshold at startup       = False R/W (0b0)

```


Lets try verifying to the serial connection by connecting using minicom and
then pressing the reset button:
```console
$ minicom --baudrate 115200 --device /dev/ttyUSB0

Welcome to minicom 2.7.1

OPTIONS: I18n 
Compiled on Jul 22 2021, 00:00:00.
Port /dev/ttyUSB0, 09:28:39

Press CTRL-A Z for help on special keys

ESP-ROM:esp32c3-api1-20210207
Build:Feb  7 2021
rst:0x1 (POWERON),boot:0xc (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:1
load:0x3fcd6100,len:0x17a8
load:0x403ce000,len:0x894
load:0x403d0000,len:0x2bf8
entry 0x403ce000
I (52) boot: ESP-IDF v4.3-beta2-2-g9a2d251912 2nd stage bootloader
I (52) boot: compile time 19:26:26
I (53) boot: chip revision: 3
I (56) boot_comm: chip revision: 3, min. bootloader chip revision: 0
I (63) boot.esp32c3: SPI Speed      : 80MHz
I (67) boot.esp32c3: SPI Mode       : DIO
I (72) boot.esp32c3: SPI Flash Size : 4MB
I (77) boot: Enabling RNG early entropy source...
I (82) boot: Partition Table:
I (86) boot: ## Label            Usage          Type ST Offset   Length
I (93) boot:  0 sec_cert         unknown          3f 00 0000d000 00003000
I (101) boot:  1 nvs              WiFi data        01 02 00010000 00006000
I (108) boot:  2 otadata          OTA data         01 00 00016000 00002000
I (116) boot:  3 phy_init         RF data          01 01 00018000 00001000
I (123) boot:  4 ota_0            OTA app          00 10 00020000 00190000
I (131) boot:  5 ota_1            OTA app          00 11 001b0000 00190000
I (138) boot:  6 fctry            WiFi data        01 02 00340000 00006000
I (146) boot:  7 coredump         Unknown data     01 03 00350000 00010000
I (154) boot: End of partition table
I (158) boot_comm: chip revision: 3, min. application chip revision: 0
I (165) esp_image: segment 0: paddr=00020020 vaddr=3c110020 size=3999ch (235932) map
I (210) esp_image: segment 1: paddr=000599c4 vaddr=3fc90000 size=03f00h ( 16128) load
I (214) esp_image: segment 2: paddr=0005d8cc vaddr=40380000 size=0274ch ( 10060) load
I (218) esp_image: segment 3: paddr=00060020 vaddr=42000020 size=104070h (1065072) map
I (391) esp_image: segment 4: paddr=00164098 vaddr=4038274c size=0d70ch ( 55052) load
I (408) boot: Loaded app from partition at offset 0x20000
I (408) boot: Disabling RNG early entropy source...
I (419) cpu_start: Pro cpu up.
I (476) cpu_start: Pro cpu start user code
I (476) cpu_start: cpu freq: 160000000
I (476) cpu_start: Application information:
I (479) cpu_start: Project name:     led_light
I (484) cpu_start: App version:      1.1
I (489) cpu_start: Compile time:     Apr  9 2021 19:28:05
I (495) cpu_start: ELF file SHA256:  55af42c4ad14898f...
I (501) cpu_start: ESP-IDF:          v4.3-beta2-2-g9a2d251912
I (507) heap_init: Initializing. RAM available for dynamic allocation:
I (514) heap_init: At 3FC9AD20 len 000252E0 (148 KiB): DRAM
I (521) heap_init: At 3FCC0000 len 0001F060 (124 KiB): STACK/DRAM
I (527) heap_init: At 50000000 len 00002000 (8 KiB): FAKEDRAM
I (534) spi_flash: detected chip: generic
I (539) spi_flash: flash io: dio
I (543) cpu_start: Starting scheduler.
I (548) gpio: GPIO[9]| InputEn: 1| OutputEn: 0| OpenDrain: 0| Pullup: 1| Pulldown: 0| Intr:3 
I (558) coexist: coexist rom version 9387209
I (558) pp: pp rom version: 9387209
I (558) net80211: net80211 rom version: 9387209
I (578) wifi:wifi driver task: 3fca4f58, prio:23, stack:6656, core=0
I (578) system_api: Base MAC address is not set
I (578) system_api: read default base MAC address from EFUSE
I (588) wifi:wifi firmware version: bb5a818
I (588) wifi:wifi certification version: v7.0
I (588) wifi:config NVS flash: enabled
I (598) wifi:config nano formating: disabled
I (598) wifi:Init data frame dynamic rx buffer num: 32
I (608) wifi:Init management frame dynamic rx buffer num: 32
I (608) wifi:Init management short buffer num: 32
I (618) wifi:Init dynamic tx buffer num: 32
I (618) wifi:Init static tx FG buffer num: 2
I (618) wifi:Init static rx buffer size: 1600
I (628) wifi:Init static rx buffer num: 10
I (628) wifi:Init dynamic rx buffer num: 32
I (638) wifi_init: rx ba win: 6
I (638) wifi_init: tcpip mbox: 32
I (638) wifi_init: udp mbox: 6
I (648) wifi_init: tcp mbox: 6
I (648) wifi_init: tcp tx win: 5744
I (658) wifi_init: tcp rx win: 5744
I (658) wifi_init: tcp mss: 1440
I (658) wifi_init: WiFi IRAM OP enabled
I (668) wifi_init: WiFi RX IRAM OP enabled
I (678) esp_rmaker_work_queue: Work Queue created.
I (678) esp_claim: Initialising Assisted Claiming. This may take time.
I (688) esp_claim: Private key already exists. No need to re-initialise it.
I (688) esp_rmaker_node: Node ID ----- A0764E5AE280
I (698) esp_rmaker_ota: OTA state = 2
I (698) esp_rmaker_ota_using_topics: OTA enabled with Topics
I (708) esp_rmaker_time_service: Time service enabled
I (708) esp_rmaker_time: Initializing SNTP. Using the SNTP server: pool.ntp.org
I (718) esp_rmaker_core: Starting RainMaker Work Queue task
I (728) esp_rmaker_work_queue: RainMaker Work Queue task started.
I (738) esp_claim: Waiting for assisted claim to finish.
W (738) BTDM_INIT: esp_bt_mem_release not implemented, return OK
I (748) wifi_prov_scheme_ble: BT memory released
I (748) app_wifi: Starting provisioning
I (758) phy_init: phy_version 300,77edb9b,Feb 25 2021,11:36:08
I (928) wifi:set rx active PTI: 0, rx ack PTI: 12, and default PTI: 1
I (928) wifi:mode : sta (a0:76:4e:5a:e2:80)
I (928) wifi:enable tsf
W (928) BTDM_INIT: esp_bt_controller_mem_release not implemented, return OK
I (938) BTDM_INIT: BT controller compile version [ae5cf49]
I (938) coexist: coexist rom version 9387209
I (948) BTDM_INIT: Bluetooth MAC: a0:76:4e:5a:e2:81

I (958) protocomm_nimble: BLE Host Task Started
GAP procedure initiated: stop advertising.
GAP procedure initiated: advertise; disc_mode=2 adv_channel_map=0 own_addr_type=0 adv_filter_policy=0 adv_itvl_min=256 adv_itvl_max=256
I (978) wifi_prov_mgr: Provisioning started with service name : PROV_adc0d2 
I (978) app_wifi: Provisioning started
I (988) esp_rmaker_local: Event 1
I (988) app_wifi: Scan this QR code from the ESP RainMaker phone app for Provisioning.
                                      
  �█�▀�▀�▀�▀�▀�█ �█  �▄�▄�█ �▀�▀ �▀�▄�▄�▄ �▀�▄ �█�▀�▀�▀�▀�▀�█   
  �█ �█�█�█ �█ �█�█�▄ �█�▄ �▄�▀�▀ �▀ �▀�▄�█�▀ �█ �█�█�█ �█   
  �█ �▀�▀�▀ �█ �▄�█�█ �▀�▀�█�▀�█ �▄�▄�▄ �▀�▀  �█ �▀�▀�▀ �█   
  �▀�▀�▀�▀�▀�▀�▀ �▀ �█�▄�▀ �▀ �▀�▄�█ �█�▄�█�▄�▀ �▀�▀�▀�▀�▀�▀�▀   
  �█�▀  �█�█�▀ �▄ �▀ �▀ �▀�█�▄�▀�▄�▀�▀�▀�▀�▄�▀�▄ �█ �▀�█�▀�▀   
  �█�▄�▀�█�▄�█�▀�▀�▄�█�▀ �▄�▀ �█�█�█�▀ �▀�█�▄�▀�█�█�▀�▄�█�█�▀�█    
   �▄  �▄�█�▀   �▄�▀�▄�▄�█�▄�█�▀�▄�▀�▀�▀�▄�▀ �▄�▀�▄�▀ �▄�▄�▀   
  �▄�▄  �█ �▀�▀�▀�▀�▄�█�▀�▀ �▀�▄�█�▀�▄ �▄�█�▀�▄�█ �▀ �█�▀�▀�▄   
  �▀ �▀�█�█�▄�▀ �▀�█�█ �▀�▄�▄�▄�█�▀�▄�▀�█�▀   �█�▀�▄�▀�▀  �▀   
  �▀�▄�█�▀�█�▄�▀ �█ �▀ �▄�▀ �▀�▀�█�█�▄ �▄�█�▀�█ �▄�█�▄�█�▀�▀�▄   
  �▄�▄�▄�█ �▄�▀�▀�█ �█�▀�▄ �▄�█�▄�▀�█ �▄�█ �▀�▀�▀�▀ �▀ �▄�█�▀   
     �█�█�▄�▀�▄�▀�▄�▀�█�▀ �▀�█�▄�▄ �▄ �█�▄�▀  �█�▀�▀�▀�▀�▄�▄   
  �▀�▀  �▀�▀�▀�▀�█�▀  �▀�▄�▄�▄�▄�█�█�▀�█�▀ �▄�█�▀�▀�▀�█�█�▄�▀    
  �█�▀�▀�▀�▀�▀�█ �▄ �▀ �▄ �█�▀�█�█�▀  �▄�█�▀�█ �▀ �█�█�▀�▀    
  �█ �█�█�█ �█ �▀�▄�▄�▀�█�▄�█�▄�█�▀�█�▀ �▀�█ �█�█�█�▀�█�▀�▄�▄�█   
  �█ �▀�▀�▀ �█ �▄�█�▀�█�█�▀ �█�▀�▄ �▄�█�█�█�▀  �▀�█�▀�▄ �▀    
  �▀�▀�▀�▀�▀�▀�▀ �▀  �▀    �▀�▀  �▀�▀�▀�▀�▀�▀      �▀   
                                      

I (1178) app_wifi: If QR code is not visible, copy paste the below URL in a browser.
https://rainmaker.espressif.com/qrcode.html?data={"ver":"v1","name":"PROV_adc0d2","pop":"adbd1dde","transport":"ble"}
####################################################################################################
  ______  _____ _____    _____            _____ _   _ __  __          _  ________ _____
 |  ____|/ ____|  __ \  |  __ \     /\   |_   _| \ | |  \/  |   /\   | |/ /  ____|  __ \
 | |__  | (___ | |__) | | |__) |   /  \    | | |  \| | \  / |  /  \  | ' /| |__  | |__) |
 |  __|  \___ \|  ___/  |  _  /   / /\ \   | | | . ` | |\/| | / /\ \ |  < |  __| |  _  /
 | |____ ____) | |      | | \ \  / ____ \ _| |_| |\  | |  | |/ ____ \| . \| |____| | \ \
 |______|_____/|_|      |_|  \_\/_/    \_\_____|_| \_|_|  |_/_/    \_\_|\_\______|_|  \_\

Welcome to ESP RainMaker led_light demo application!
Follow these steps to get started:
1. Download the ESP RainMaker phone app by visiting this link from your phone's browser:

   http://bit.ly/esp-rmaker

2. Sign up and follow the steps on screen to add the device to your Wi-Fi network.
3. You are now ready to use the device and control it locally as well as remotely.
   You can also use the Boot button on the board to control your device.

If you want to reset Wi-Fi credentials, or reset to factory, press and hold the Boot button.

This application uses ESP RainMaker, which is based on ESP IDF.
Check out the source code for this application here:
   https://github.com/espressif/esp-rainmaker/blob/master/examples/led_light

Please visit https://rainmaker.espressif.com for additional information.

####################################################################################################
I (1338) app_wifi: Provisioning Started. Name : PROV_adc0d2, POP : adbd1dde
```
I misunderstood this completly and thought that it would be possible to simply
connect an USB cable and be good to go. But we need an additional USB cable
, or just one if we can power the device with it as well) which should be
connected to `D-`, `D+`, `VBUS`, and `GND`. Is is also possible to use an
external JTAG adapter. 

_wip_

### USB Serial/JTAG Controller (USB_SERIAL_JTAG)
This can program the system of chips flash, read program output, and also attach
as a debugger to a running program. The docs say that this is prossible without
from an USB host without any additional external components.
The serial port communication is a two-wire interface which is mainly used to
flash new firmware (program the device). The USB Serial part of this controller
is what converts/transforms/translates from USB to serial format. When an error
occurs the JTAG debugging port is used which requires interfacing with the JTAG
debug port which usually requires an external JTAG adapter.

### eFuse Controller (eFuse)
This component is a 4096-bit eFuse controller for one-time programmable storage
parameters. eFuse is a microscopic fuse that is placed on a chip. This
technology was invented by IBM in 2004 and allows for dynamic reprogramming of a
chip. So instead of hard wiring this allows changes to be made during operation.
If one of these parameter are written with a 1, it can never be reverted back to
0. The values of parameters can only be read by using the eFuse Controller.


