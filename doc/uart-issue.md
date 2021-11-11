### USART2 Issue
The problem I'm having is that I can see that data is not read out of the
data register. When stepping through the code in the debugger I can see that
the second time `uart_write_char` is called the old data is still in the USART2
Transmit Data Registry (TDR). I'm assuming here that the data would be removed
when it is copied to the shift register of the USART. Hmm, that might be an
incorrect assumption, like think about a mov instruction, that will only copy
the data and not remove it from the source register.

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


