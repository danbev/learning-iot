### USART2 Issue
The problem I'm having is that I can see that data is not read out of the
data register. When stepping through the code in the debugger I can see that
the second time `uart_write_char` is called the old data is still in the USART2
Transmit Data Registry (TDR). I'm assuming here that the data would be removed
when it is copied to the shift register of the USART. Hmm, that might be an
incorrect assumption, like think about a mov instruction, that will only copy
the data and not remove it from the source register. I've check this and the
reference manual states that:
```
Clearing the TXE bit is always performed by a write to the transmit data
register. The TXE bit is set by hardware and it indicates:
• The data has been moved from the USART_TDR register to the shift register and
the data transmission has started.
• The USART_TDR register is empty.
• The next data can be written in the USART_TDR register without overwriting the
previous data.
```

There is no indications either on the serial adapter of any transmission, the rx
light is not blinking (I verfied that I could do a loop back using it by
shorting rx/tx and can see them working).

What would possible causes be?  
* TE is not enabled perhaps
* Incorrect baud rate (but I would have thought data would be able to be sent
but perhaps not recieved correctly. But when I step through the code the data
is still in the data register.
* Is there something wrong with the PORT and/or the AF number.

### Transmitter Enable (TE)


### Incorrect Baud Rate

### PORT/Alternative Function
From the data sheet I can read the following:
```
Table 15. Alternate functions selected through GPIOA_AFR registers for port A 

                 AF1
PA2             USART2_TX
```
I'm setting AF1 using:
```assembly
.equ AFSEL2_AF1, 1 << 8                      // checked

  /* Set GPIO Port A Pin 2 to 0001 (AF1) */ 
  ldr r1, =GPIOA_AFRL
  ldr r2, =AFSEL2_AF1
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]
```

![Oscilloscope image of PA2](./uart-oscilloscope.jpg "Oscilloscope image of PA2")

I actually had the USB connected incorrectly in that picture but I changed it
to USB User with the same result.
So I'm thinking it would still be the pin that is incorrectly setup but I've
checked this multiple times now. I'm leaning towards it being and issue with
the UART configuration.

