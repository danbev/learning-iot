/* Near Field Communication example. 
 *
 * This example is very basic where the device acts as a tag that can be
 * read by a reader like a smartphone.
*/
.syntax unified
.thumb

.data

tag:
    .ascii "bajja"
len = . - tag

.text

// Near Field Communication Tag base address
.equ NFCT_BASE, 0x40005000

.equ TASKS_ACTIVATE_R, NFCT_BASE + 0x000
.equ ERRORSTATUS_R, NFCT_BASE + 0x404
.equ PACKETPTR_R, NFCT_BASE + 0x510
.equ MAXLEN_R, NFCT_BASE + 0x514
.equ EVENTS_READY, NFCT_BASE + 0x100
.equ EVENTS_FIELDDETECTED, NFCT_BASE + 0x104

.equ READY, 1
.equ ACTIVATE, 1

.global start

Vector_Table:                   // Exception Nr  Handler               IRQ Nr
  .word     0x20002000          // 0             Initial SP value
  .word     start + 1           // 1             Reset

start:
  ldr r1, =_end_text    // end of .text segment in Flash memory.
  ldr r2, =_start_data  // start of .data segment in RAM memory.
  ldr r3, =_end_data    // end of .data segment in RAM memory.

copy_loop:
  cmp r2, r3
  bge no_copy

  ldr r4, [r1], #4
  str r4, [r2], #4
  b copy_loop

no_copy:
  ldr r1, =PACKETPTR_R
  ldr r2, =tag
  str r2, [r1]

  ldr r1, =MAXLEN_R
  ldr r2, =len
  str r2, [r1]

  /* This register is write only */
  ldr r1, =TASKS_ACTIVATE_R
  ldr r2, =ACTIVATE
  str r2, [r1]

wait_for_ready:
  ldr r1, =EVENTS_READY
  ldr r2, =READY
  ldr r0, [r1]
  cmp r0, r2
  bne wait_for_ready

  bl .
