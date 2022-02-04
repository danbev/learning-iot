## Startup notes
With a microcontroller we flash the program into non-volatile memory which
contains the complete program. For program execution RAM is used which is
volatile, it will be cleared upon powering down the device. 

If we have a static variable defined like this:
```assembly
.data
one: .word 1

.text

  ldr r0, =one
```
So this instruction is loading the address on the label `one`into register r0.
gT
If we inspect the memory of this:
```console
(gdb) p/x $r0
$7 = 0x20000000
```
This is the end of the .text section, and also the start of the RAM section.
The issue is that `one` above is initialized to `1` but this value is in the
Flash memory unit. The address of one is a location in RAM but the value stored
in that location is undefined, whatever was there before or zero:
```console
(gdb) x/d $r0
0x20000000:	1745707070
```
Variables like `one` above that need to be initialized will have a portion
of the program memory (RAM memory) set aside for that value. 

Note that the following is specific to an example found in
[nrf/misc/startup.s](../nrf/misc/startup.s) and not the general case.

```
       Flash Memory                                  Ram Memory
   +-------------------+                          +-------------------+
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   +-------------------+                          +-------------------+
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |     Data          |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   |                   |                          |                   |
   +-------------------+<-- _end_data             +-------------------+ 0x20000000
   |                   |                          |                   |
   |                   |                          |                   |
   |   .data           |<-- _start_data           |                   |
   |                   |<-- _end_text             |                   |
   |   Code            |  ----------------------> |   Code            |
   |                   |                          |                   |
   |                   |                          |                   |
   |    .text          |                          |                   |
   +-------------------+ 0x00000000               +-------------------+ 0x00000000
```

```assembly
  ldr r0, =one
  ldr r1, =_end_text    // end of .text segment in Flash memory.
  ldr r2, =_start_data  // start of .data segment in RAM memory.
  ldr r3, =_end_data    // end of .data segment in RAM memory.
```

```console
r0             0x20000000          536870912   // one
r1             0x90                144         // _end_text
r2             0x20000000          536870912s  // _start_data
r3             0x2000000c          536870924   // _end_data
```
If we look at _start_data and end_data we can see that the difference is C hex
which is 12 in decimal. And we have 3 words (32 bits/4 bytes) and 3*4=12 so we
have three variables. And r0 which shows the address of `one` which also looks
as expected. But the value of `one` is not what we would expect, it should be
1 in our case. 

Notice that what is happeing is that the .data section is copied/mapped from 
flash to RAM but this is readonly memory and our data (the addresses of our
variables `one`, `two`, and `three` are in the Data part of RAM starting with
0x20000000 and after a reset the data in these location could be anything.
What we need to to in our ResetHandler which in our assembly examples is just
the "main/start" function is to reach into the Code RAM memory and get the
values for these variable and copy them into the Data RAM locations.

So we have `_end_text` which is a symbol that is created by the linker via the
linker_script.ld:
```console
  .text : { 
	  *(.text) 
	  _end_text = .;
  } > FLASH
```
We can inspect the values in the Code memory using the address of `_end_text`
```console
(gdb) x/1 _end_text
0x90:	1
(gdb) x/1 _end_text + 4
0x94:	2
(gdb) x/1 _end_text + 8
0x98:	3
```
So we can see that the values for our variables are there. What we need to
do now is to copy them into the Data RAM memory locations.

So we have to compare the current variable_address with the _end_data address
and if the current variable_address is less than _end_data then we should
copy/mov the value from the current_flash_mem to the current variable_address
and then increment both pointers.

//*dst++ = *src++;
```console
(gdb) p/t (int*)one
$4 = 1
(gdb) p/t (int*)two
$5 = 10
(gdb) p/d (int*)two
$6 = 2
(gdb) p/d (int*)three
$7 = 3
```


