/* nRF LED external example */
.thumb
.text

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  b .
