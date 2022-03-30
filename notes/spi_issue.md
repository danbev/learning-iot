### SPI issue notes
I'm attempting to do a loopback with SPI where I'm connecting the COPI with
the CIPO and see that data is transferred.

While I can see that the `RXNE` flag is getting set:
```console
(gdb) x/tw $r1
0x40013008:	00000000000000000000010000000011
```
I'm not able to write anything useful into the data register. What happens when
I try is that all 1s get written:

```console
(gdb) x/tw $r1
0x4001300c:	00000000000000001111111111111111
```
Why is this happening?

