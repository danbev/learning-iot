### USART2 Issue
The problem I'm having after changing to UART1 is that I can see that FTDI
serial adapter's RX led is blinking when the board is transmitting. But the
only thing that is getting transmited looks like the start bit and nothing else.

```console
$ minicom -D /dev/ttyUSB0 -b 9600 -8 -H
Welcome to minicom 2.7.1

OPTIONS: I18n 
Compiled on Jan 26 2021, 00:00:00.
Port /dev/ttyUSB0, 19:56:24

Press CTRL-A Z for help on special keys

00 00 00 00 00 00 00 00 00 00 00 00
```
When using an oscilloscope I'm only seeing the start bit and nothing else, it
is like it is sent but nothing else after it.


Lets take a closer look at the RCC_CR (Clock Control) register:
```console
uart_init () at uart.s:89
89	  ldr r1, =RCC_CR
(gdb) si
(gdb) x/wt $r1
0x40021000:	00000000000000000101001010000011
```
So this is showing the default settings.
```
Bit 0 (1) is saying that HSI clock is enabled.
Bit 1 (1) is saying that the HSI oscillator is stable.
Bit 2 (0) is reserved.
Bit 3-7 (10000) is for HSI clock trimming and used in combination with (HSICAL,
the next 8 bits). These 4 bits provide a user programmable trimming value to
adjust to variations in temparature and voltage. The default value is 16
(10000b) and when this value is added to the value in HSICAL it should trim the
HSI to 8 MHz. 
Bit 8-15 (1010010) HSI clock callibration (HSICAL).
```
The rest of the bits are zero so the HSE clock is not enabled.

Next, lets take a look at `RCC_RC2`:
```console
(gdb) x/wt $r1
0x40021034:	10001000000000000111010010000000
```
As far as I can tell the values in this register are mainly for HSI14, and we
know that HSI is enabled by default (From bit 0 in RCC_CR).

Next, lets inspect `RCC_CFGR` register
```console
gdb) x/wt $r1
0x40021004:	00000000000000000000000000000000
```
So nothing in this register is being set by default. A few of the interesting
bits related to HSI are:
```
Bit 0-1 (00) System clock switch (SW) 00 = HSI selected as system clock.
Bit 2-3 (00) System clock switch status (SWS) 00 = HSI oscillator used as
system clock.
Bit 4-7 (0000) HCKL prescalar. 0000 means no division factor of AHB clock.
Bit 8-10 (000) PCKL prescalar. 000 means no division factor of APB clock.
Bit 13 (0) reserved.
Bit 14 (0) ADC prescalar. Is obselete according to the manual.
Bit 15-16 (00) PLL input clock source. 00 = HSI/2 selected as PLL. PREDIV forced
to divide by 2 on STM32F07x.
Bit 17 (0) HSE divider for PLL input clock.
Bit 18-21 (0000) PLL multiplication factor (PLLMUL). 0000 = PLL input clock x 2
Bit 22 (0) reserved
Bit 23 (0) reserved
Bit 24-27 (0000) Microcontroller clock output (MCO). 000 MCO ouput disabled.
Bit 28-30 (000) Microcontroller clock ouput prescalar (MCOPRE). 000 = MCO is
divided by 1.
Bit 31 (0) PLL clock not divided (PLLNODIV). 0 = PLL is not divided by 2 for
MCO.
```
So if `HSI` is used and there are no prescalars that would mean we have a clock
with a frequency of 8 MHz

Next we have `RCC_CFGR3`:
```console
(gdb) x/wt $r1
0x40021030:	00000000000000000000000000000000
```
Since I'm using USART2 the only relevant value I think is bit 16-17:
```
Bit 16-17 (00) USART2 clock source selection (USART2SW). 00 = PCKL selected as
USART2 clock source (default).
```

`FCKL` is the clock signal provided to the CPU core.  
`HCKL` is the clock signal provided to the high-speed bus (AHB).  
`PCKL` is the clock signal provided to the low-speed bus (APB).

Lets take a look at the USART2_CR1 register and find the value of `OVER8` which
is bit 15:
```console
(gdb) x/wt $r1
0x40004400:	00000000000000000000000000000000
```
Bit 15 (0) Oversampling Mode (OVER8). 0 = Oversampling by 16.

This value is important when cacluating the Baud rate. 

So the system clock is 8 MHz, and in this case I think `PCKL` is that same value
, and we know that Oversampling is 16. So if we want to have a baud rate of
9600:
```
         8000000
  9600 = --------
         USARTDIV

             80000
  USARTDIV = ----- = 833d, 0x341
              96
```
And we have a symbol for this in uart.s:
```assembly
.equ BRR_CNF, 0x341
```
But if you look at the code I'm just writing this directly into the `USART_BRR`
register: 
```console
(gdb) x/wt $r1
0x4000440c:	00000000000000000000000000000000
(gdb) i r $r2
r2             0x341               833
(gdb) p/t $r0
$1 = 1101000001
(gdb) x/wt $r1
0x4000440c:	00000000000000000000001101000001
```
Actually the manual says When OVER8 = 0, BRR[3:0] = USARTDIV[3:0] so this should
be correct in this case.

With these current settings I can see that after writing to the DTR USART2_IRS
is then cleared with only one bit set:
```console
(gdb) x/wt $r1
0x4000441c:	00000000001000000000000000000000
```
The is bit 21 that is set. This is Transmit enable acknowledge flag (TEACK)
which is set by hardware when Transmit Enable.
TEACK can be configured in USART_CR1:
```
Bit 7 TXEIE: interrupt enable
This bit is set and cleared by software.
  0: Interrupt is inhibited
  1: A USART interrupt is generated whenever TXE=1 in the USART_ISR register

Bit 6 TCIE: Transmission complete interrupt enable
This bit is set and cleared by software.
  0: Interrupt is inhibited
  1: A USART interrupt is generated whenever TC=1 in the USART_ISR register

Bit 4 IDLEIE: IDLE interrupt enable
This bit is set and cleared by software.
  0: Interrupt is inhibited
  1: A USART interrupt is generated whenever IDLE=1 in the USART_ISR register
```

After spending an embarrasing amount of time trying to get USART to work I
need to find out if there was something else wrong (like an issue with cables,
pins, serial board etc). So I tried using `libopencm3` (open cortex-m I think
it stands for). Trying the example that ships with libopencm3 I was able to
verify that USART does work which was good news. I've been looking at that
as a reference and using the same port and pins which I know work. But after
going through this over and over I still get the same behavior.

I checked the baud rate in `libopencm3/lib/stm32/common/usart_common_all.c`
which contains the function usart_set_baudrate which is of interest to me as
I've been struggling getting usart to work in assembly and I suspect that the
baud rate is wrong.
```c
void usart_set_baudrate(uint32_t usart, uint32_t baud)
{
        ...
	USART_BRR(usart) = (clock + baud / 2) / baud;
}
```
In this case I can check the value of the clock and the passed in baud:
```console
(gdb) info locals
clock = 8000000

(gdb) info args 
baud = 115200
```
So that should give us:
```console
(gdb) p/x (clock + baud / 2) / baud
$3 = 0x45
```
That might not be enough though. I also noticed that in usart.c there is a
delay
```c
		for (i = 0; i < 100000; i++) {	/* Wait a bit. */
			__asm__("NOP");
		}
```
With that baud rate it still does not work. So I started to look at what
happens before the main function is called.

So if we take a look at the `reset_handler` which is the entry point
```c
void __attribute__ ((weak)) reset_handler(void)                                    
  {                                                                                  
          volatile unsigned *src, *dest;                                             
          funcp_t *fp;                                                               
                                                                                     
          for (src = &_data_loadaddr, dest = &_data;                                 
                  dest < &_edata;                                                    
                  src++, dest++) {                                                   
                  *dest = *src;                                                      
          }                                                                       
                                                                                  
          while (dest < &_ebss) {                                                 
                  *dest++ = 0;                                                    
          }                                                                       
                                                                                  
          /* Ensure 8-byte alignment of stack pointer on interrupts */            
          /* Enabled by default on most Cortex-M parts, but not M3 r1 */          
          SCB_CCR |= SCB_CCR_STKALIGN;                                            
                                                                                  
          /* might be provided by platform specific vector.c */                   
          pre_main();                                                             
                                                                                  
          /* Constructors. */                                                     
          for (fp = &__preinit_array_start; fp < &__preinit_array_end; fp++) {       
                  (*fp)();                                                        
          }                                                                       
          for (fp = &__init_array_start; fp < &__init_array_end; fp++) {          
                  (*fp)();                                                        
          }                                                                       
                                                                                  
          /* Call the application's entry point. */                               
          (void)main();                                                           
                                                                                  
          /* Destructors. */                                                      
          for (fp = &__fini_array_start; fp < &__fini_array_end; fp++) {          
                  (*fp)();                                                        
          }                                                                       
                                                                                  
  }                        
```
We can take a look at the linker command using:
```console
$ make -Bn | grep 'arm-none-eabi-gcc --static'
arm-none-eabi-gcc --static -nostartfiles -T../stm32f0-discovery.ld -mthumb -mcpu=cortex-m0 -msoft-float -ggdb3 -Wl,-Map=usart.map -Wl,--cref -Wl,--gc-sections -L../../../../../libopencm3//lib usart.o -lopencm3_stm32f0 -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group -o usart.elf
```
So lets take closer look at the linker script (`-T` which overrides the default
linker script) stm32f0-discovery.ld:
```console
$ cat ../stm32f0-discovery.ld 
/* Linker script for ST STM32F0DISCOVERY (STM32F051R8T6, 64K flash, 8K RAM). */

/* Define memory regions. */
MEMORY
{
	rom (rx) : ORIGIN = 0x08000000, LENGTH = 64K
	ram (rwx) : ORIGIN = 0x20000000, LENGTH = 8K
}

/* Include the common ld script. */
INCLUDE cortex-m-generic.ld
```

`libopencm3/lib/cortex-m-generic.ld` has the following instructions for the
linker:
```console
        .data : {                                                                  
                _data = .;                                                         
                *(.data*)       /* Read-write initialized data */                  
                *(.ramtext*)    /* "text" functions to run in ram */               
                . = ALIGN(4);                                                      
                _edata = .;                                                        
        } >ram AT >rom                                                             
        _data_loadaddr = LOADADDR(.data);   
```
The `.data*` starts an output section which will contain a symbol named `_data`
with the value of the current location counter. This will act as the start of
some data of interest, likewise the  `_edata` is the end of this data. In
between these the linker will place all `.data*` and `.ramtext*` sections.
Also notice that another variable named `_data_loadaddr` is being created and
set to the address of the output .data section.

[Linker script notes](https://github.com/danbev/learning-cpp#ld-linker-scripts)

Looking again at the code in the reset handler we can see that src is assigned
to the .data section, and dest is assigned the to `_data`:
```c
  volatile unsigned *src, *dest;

  for (src = &_data_loadaddr, dest = &_data; dest < &_edata; src++, dest++) {
	  *dest = *src;
  }

  while (dest < &_ebss) {
	  *dest++ = 0;
  }
```
So `dest` is set to point the memory address of `_data` what was created by the
linker. Keep in mind that this happens at link time so all this happens before
our executable object file is created (so don't go looking for information about
these sections in the executble). But what we can do is see the symbols created
by the compiler:
```console
$ arm-none-eabi-nm usart.elf | egrep '_?data'
20000000 D _data
080004b4 A _data_loadaddr
20000004 D _edata
```
And if we take a closer look at the reset_handler we should be able to see
these addresses being used:
```console
$ arm-none-eabi-objdump --disassemble=reset_handler usart.elf

usart.elf:     file format elf32-littlearm


Disassembly of section .text:

08000314 <reset_handler>:
 8000314:	b510      	push	{r4, lr}
 8000316:	4b16      	ldr	r3, [pc, #88]	; (8000370 <reset_handler+0x5c>)
 8000318:	4a16      	ldr	r2, [pc, #88]	; (8000374 <reset_handler+0x60>)
 800031a:	4917      	ldr	r1, [pc, #92]	; (8000378 <reset_handler+0x64>)
 800031c:	428b      	cmp	r3, r1
 800031e:	d318      	bcc.n	8000352 <reset_handler+0x3e>
```
Notice that these addresses match the symbols for `_data` (`r3`, `dest`),
`_data_loadaddr` (`r2`, `src`), and `_edata` (`r1`):
```console
 8000370:	20000000 	.word	0x20000000
 8000374:	080004b4 	.word	0x080004b4
 8000378:	20000004 	.word	0x20000004

(gdb) info locals 
src = 0x80004b4
dest = 0x20000000 <rcc_apb1_frequency>
(gdb) x/wx dest
0x20000000 <rcc_apb1_frequency>:	0x007a1200
(gdb) p/d *dest
$12 = 8000000
```
And the compare is performed on `dest` and `_edata` and (dest < &_edata)
the branch to 8000352:
```console
(gdb) disassemble 
Dump of assembler code for function reset_handler:
   0x08000314 <+0>:	push	{r4, lr}
   0x08000316 <+2>:	ldr	r3, [pc, #88]	; (0x8000370 <reset_handler+92>)
   0x08000318 <+4>:	ldr	r2, [pc, #88]	; (0x8000374 <reset_handler+96>)
   0x0800031a <+6>:	ldr	r1, [pc, #92]	; (0x8000378 <reset_handler+100>)
   0x0800031c <+8>:	cmp	r3, r1
   0x0800031e <+10>:	bcc.n	0x8000352 <reset_handler+62>

// We only branch once after that dest and _edata are equal so we continue here:
   0x08000320 <+12>:	movs	r1, #0          ; just resetting perhaps?
   0x08000322 <+14>:	ldr	r2, [pc, #88]	; (0x800037c <reset_handler+104>) ; _ebss
   0x08000324 <+16>:	cmp	r3, r2          ; compare dest and _ebss (which are equal in this case so no carry flags set)
   0x08000326 <+18>:	bcc.n	0x8000358 <reset_handler+68>
// Will continue to here after comparing dest and _ebss:
   0x08000328 <+20>:	movs	r3, #128	; 0x80
   0x0800032a <+22>:	ldr	r2, [pc, #84]	; (0x8000380 <reset_handler+108>)
   0x0800032c <+24>:	lsls	r3, r3, #2
   0x0800032e <+26>:	ldr	r1, [r2, #0]
   0x08000330 <+28>:	ldr	r4, [pc, #80]	; (0x8000384 <reset_handler+112>)
   0x08000332 <+30>:	orrs	r3, r1
   0x08000334 <+32>:	str	r3, [r2, #0]
   0x08000336 <+34>:	ldr	r3, [pc, #80]	; (0x8000388 <reset_handler+116>)
   0x08000338 <+36>:	cmp	r4, r3
   0x0800033a <+38>:	bcc.n	0x800035c <reset_handler+72>
   0x0800033c <+40>:	ldr	r4, [pc, #76]	; (0x800038c <reset_handler+120>)
   0x0800033e <+42>:	ldr	r3, [pc, #80]	; (0x8000390 <reset_handler+124>)
   0x08000340 <+44>:	cmp	r4, r3
   0x08000342 <+46>:	bcc.n	0x8000362 <reset_handler+78>
   0x08000344 <+48>:	bl	0x80000c0 <main>
   0x08000348 <+52>:	ldr	r4, [pc, #72]	; (0x8000394 <reset_handler+128>)
   0x0800034a <+54>:	ldr	r3, [pc, #76]	; (0x8000398 <reset_handler+132>)
   0x0800034c <+56>:	cmp	r4, r3
   0x0800034e <+58>:	bcc.n	0x8000368 <reset_handler+84>
   0x08000350 <+60>:	pop	{r4, pc}

// This is where we will branch to
   0x08000352 <+62>:	ldmia	r2!, {r0}      ; load (m = multiple) from r2 (src) into r0 and increment the array (in r2)
   0x08000354 <+64>:	stmia	r3!, {r0}      ; store (m = multiple) the register r0 (populated by previous instruction into r3 (dest) and increment the array (in r3)

(gdb) i r $r0
r0             0xffffffff          -1
(gdb) i r $r2
r2             0x80004b4           134218932
(gdb) i r $r3
r3             0x20000000          536870912

// After the ldmia r2!, {r0}:
(gdb) i r $r2
r2             0x80004b8           134218936
(gdb) i r $r0
r0             0x7a1200            8000000
(gdb) i r $r3
r3             0x20000004          536870916
So dest[0] = 8000000
(gdb) x/2x $r3 - 4
0x20000000 <rcc_apb1_frequency>:	0x007a1200	0xed84efad
   0x08000356 <+66>:	b.n	0x800031c <reset_handler+8> ; branch back to the cmp of dest and e_data

   0x08000358 <+68>:	stmia	r3!, {r1}
   0x0800035a <+70>:	b.n	0x8000324 <reset_handler+16>
   0x0800035c <+72>:	ldmia	r4!, {r3}
   0x0800035e <+74>:	blx	r3
   0x08000360 <+76>:	b.n	0x8000336 <reset_handler+34>
   0x08000362 <+78>:	ldmia	r4!, {r3}
   0x08000364 <+80>:	blx	r3
   0x08000366 <+82>:	b.n	0x800033e <reset_handler+42>
   0x08000368 <+84>:	ldmia	r4!, {r3}
   0x0800036a <+86>:	blx	r3
   0x0800036c <+88>:	b.n	0x800034a <reset_handler+54>
   0x0800036e <+90>:	nop			; (mov r8, r8)
   0x08000370 <+92>:	movs	r0, r0
   0x08000372 <+94>:	movs	r0, #0
   0x08000374 <+96>:	lsls	r4, r6, #18
   0x08000376 <+98>:	lsrs	r0, r0, #32
   0x08000378 <+100>:	movs	r4, r0
   0x0800037a <+102>:	movs	r0, #0
   0x0800037c <+104>:	movs	r4, r0
   0x0800037e <+106>:	movs	r0, #0
   0x08000380 <+108>:			; <UNDEFINED> instruction: 0xed14e000
   0x08000384 <+112>:	lsls	r4, r6, #18
   0x08000386 <+114>:	lsrs	r0, r0, #32
   0x08000388 <+116>:	lsls	r4, r6, #18
   0x0800038a <+118>:	lsrs	r0, r0, #32
   0x0800038c <+120>:	lsls	r4, r6, #18
   0x0800038e <+122>:	lsrs	r0, r0, #32
   0x08000390 <+124>:	lsls	r4, r6, #18
   0x08000392 <+126>:	lsrs	r0, r0, #32
   0x08000394 <+128>:	lsls	r4, r6, #18
   0x08000396 <+130>:	lsrs	r0, r0, #32
   0x08000398 <+132>:	lsls	r4, r6, #18
   0x0800039a <+134>:	lsrs	r0, r0, #32
End of assembler dump.
```
So, as far as I can tell the code related to this issue has been done through
above.  dest[0] = 8000000
```console
(gdb) x/2x $r3 - 4
0x20000000 <rcc_apb1_frequency>:	0x007a1200	0xed84efad
```
And notice that this is the rcc_abp1_frequency and this is placed as the first
entry in the .data output section:
```console
$ arm-none-eabi-objdump -d -j .data usart.elf 

usart.elf:     file format elf32-littlearm

Disassembly of section .data:

20000000 <rcc_apb1_frequency>:
20000000:	00 12 7a 00                                         ..z.
```
And this value is later used in `usart_set_baudrate`:
```c
void usart_set_baudrate(uint32_t usart, uint32_t baud)                          
{                                                                               
        uint32_t clock = rcc_apb1_frequency;
```
So when I commented out the lines in the request_handler I would get the
same behavior as I'm seeing in my code. And if I manually set the value of
clock to `8000000` in `usart_set_baudrate` in
`libopencm3/lib/stm32/common/usart_common_all.c` it works. So it still seems to
point to an invalid value for UART1_BRR.
```c
void usart_set_baudrate(uint32_t usart, uint32_t baud)                             
{
    ...
    USART_BRR(usart) = (clock + baud / 2) / baud;
```
So in this case usart will be in r0, an baud in r1:
```console
(gdb) i r $r0
r0             0x40013800          1073821696
(gdb) i r $r1
r1             0x1c200             115200
(gdb) p/d $r1
$2 = 115200

(gdb) x/t 0x40013800
0x40013800:	00000000000000000000000000000000
```
Notice that `usart` matches our USART1_BASE register.
```assembly
.equ USART1_BASE, 0x40013800
```
And we can see that it is cleared/zero upon entering this function.
```console
(gdb) disassemble 
Dump of assembler code for function usart_set_baudrate:
=> 0x08000270 <+0>:	ldr	r3, [pc, #16]	; (0x8000284 <usart_set_baudrate+20>)
   0x08000272 <+2>:	push	{r4, lr}
   0x08000274 <+4>:	ldr	r3, [r3, #0]
   0x08000276 <+6>:	movs	r4, r0          ; move r0 into r4
   0x08000278 <+8>:	lsrs	r0, r1, #1      ; logical shift right (update conditions flags register)
   0x0800027a <+10>:	adds	r0, r0, r3
   0x0800027c <+12>:	bl	0x800039c <__udivsi3>
   0x08000280 <+16>:	str	r0, [r4, #12]   ;r0 = usart base, plus 12 (0xC) is the BRR registr
   0x08000282 <+18>:	pop	{r4, pc}
   0x08000284 <+20>:	movs	r0, r0
   0x08000286 <+22>:	movs	r0, #0

(gdb) x/d 0x08000284
0x8000284 <usart_set_baudrate+20>:	8000000

(gdb) x/x $r4 + 12
0x4001380c:	0x00000045
(gdb) x/d $r4 + 12
0x4001380c:	69
```
Alright, so this turned out to be an combination of the baud rate being
incorrect and me changing code around too much. What was happening is that
the character that I wanted to send was in $r0 which was is passed as the
first argument to uart_write_char, but after I added code for the LED and also
to have a delay. These functions use r0 so it was getting overwritten and
indeed was zero, hence 0x0 was being sent. 
Hardcoding the value to be sent just before sending verified this:
```console
$ minicom --baudrate 115200 --device /dev/ttyUSB0

Welcome to minicom 2.7.1

OPTIONS: I18n 
Compiled on Jan 26 2021, 00:00:00.
Port /dev/ttyUSB0, 13:15:05

Press CTRL-A Z for help on special keys

BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
```
