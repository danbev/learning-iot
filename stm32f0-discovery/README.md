### Assembly GPIO example
So the goal of this example is to turn on a LED on the bord. The board I'm using
is stm32f0-discovery:

[Product documentation](https://www.st.com/en/evaluation-tools/32f072bdiscovery.html#documentation)  
[User Manual](https://www.st.com/resource/en/user_manual/um1690-discovery-kit-for-stm32f0-series-microcontrollers-with-stm32f072rb-stmicroelectronics.pdf)

This board is based on a STM32F072RBT6 so we will need its 
[reference manual](https://www.st.com/resource/en/reference_manual/rm0091-stm32f0x1stm32f0x2stm32f0x8-advanced-armbased-32bit-mcus-stmicroelectronics.pdf) as well.


There are four LEDs on this board which we can turn on and we can choose one.
There are details about these LEDs on page 14 of the above user manual:
```
                           LED3
                      LED4      LED5
                           LED6

* User LD3: This red user LED is connected to the I/O PC6
* User LD4: This orange user LED is connected to the I/O PC8
* User LD5: This green user LED is connected to the I/O PC9
* User LD6: This blue user LED is connected to the I/O PC7
```
So we can see that we need to access PORT C and then a PIN on that port.
So we can see that all these PINs are connected to PORT C. 
If we look at the block diagram we can see that PORT C is connected via the
AHB1 bus (Advanced High Performace Bus).
```
6.3.5 RCC AHB1 peripheral reset register (RCC_AHB1RSTR)
Address offset: 0x10
```
Notice that this is just giving us an offset. To find the RCC base address we
can look at the Memory Map table:
```
0x4002 1000 - 0x4002 13FF 1 KB RCC
...
```
So our RCC_AHB1 would be 0x40033800 + 0x10.

So we need to find the address of PORT A. To do this we look in the reference
manual on page 38 there is a table with a Memory Map (same table as we used 
previously):
```
...
0x4800 0800 - 0x4800 0BFF 1KB GPIOC
...
```


### Building
```console
$ make gpio.elf
```

### Flashing
```console
$ make openocd
```
From a new terminal (as the first terminal will be running the openocd server)
and it is good to keep that visible so you can see the commands being executed)

```console
$ telnet localhost 4444
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Open On-Chip Debugger
> reset halt
> flash write_image erase main.hex
> reset run
> CTRL+]
telnet> quit
```

![Blue Led example](./blue-led.jpg "Example of blue led blinking")
