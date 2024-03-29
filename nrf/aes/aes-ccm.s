/*
 Example of using the AES CCM peripheral.

 1) A new Keystream needs to be generated before encryption/decryption can
    proceed.

 Encryption is done by reading the unencrypted message located in INPTR, then
 the encryption takes place, followed by appending a 4 byte Message Integrity
 Check (which is a Message Authentication Code (MAC) but is named MIC instead
 as this is what is used in the Bluetooth specification) field to the message.
*/
.syntax unified
.thumb

.data

plain_text:
    .byte         0            // Header
    .byte         5            // Length in bytes
    .byte         1            // Reserved for future use
    .byte         1            // Reserved for future use
    .ascii        "hello"      // Payload

/* ccm_data_struct will be stored RAM, but the value "bajja\n" will be in the
 flash memory */
ccm_data_struct:
    .ascii        "0123456789abcedf"  // AES Key (16 bytes, 128 bits)
    .byte         0                   // Octet 0 of packet counter
    .byte         0                   // Octet 1 of packet counter
    .byte         0                   // Octet 2 of packet counter
    .byte         0                   // Octet 3 of packet counter
    .byte         0                   // Octet 4 of packet counter ?
    .byte         0                   // Ignored
    .byte         0                   // Ignored
    .byte         0                   // Ignored
    .byte         0                   // Direction bit?
    .byte         0,0,0,0,0,0,0,0     // IV


packet:
    .space 64

.text

.equ CCM_BASE, 0x4000F000
.equ TASK_KSGEN_R, CCM_BASE + 0x000
.equ EVENTS_ENDKSGEN_R, CCM_BASE + 0x100
.equ CNFPTR_R, CCM_BASE + 0x508 
.equ TASK_CRYPT_R, CCM_BASE + 0x004
.equ EVENTS_ENDCRYPT_R, CCM_BASE + 0x104
.equ INPTR_R, CCM_BASE + 0x50C
.equ OUTPTR_R, CCM_BASE + 0x510
.equ MODE_R, CCM_BASE + 0x504
.equ ENABLE_R, CCM_BASE + 0x500
.equ SCRATCHPTR_R, CCM_BASE + 0x514

.equ TASK_KSGEN_START, 1
.equ EVENTS_ENDKSGEN, 1
.equ TASK_CRYPT_START, 1
.equ EVENTS_ENDCRYPT, 1
.equ ENCRYPT, 0
.equ ENABLE, 2

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
  /* Enable AES */
  ldr r1, =ENABLE_R
  ldr r2, =ENABLE
  str r2, [r1]

  /* Configure the pointer to the AES-CCM data structure */
  ldr r1, =CNFPTR_R
  ldr r2, =ccm_data_struct
  str r2, [r1]

  /* Set mode to encrypt */
  ldr r1, =MODE_R
  ldr r2, =ENCRYPT
  str r2, [r1]

  /* Generate Keystream */
  ldr r1, =TASK_KSGEN_R
  ldr r2, =TASK_KSGEN_START
  str r2, [r1]

  /* Wait for ENDKSGEN event */
wait_for_end_ksgen:
  ldr r1, =EVENTS_ENDKSGEN_R
  ldr r2, =EVENTS_ENDKSGEN
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_for_end_ksgen

  /* Set the pointer to the plain-text to be encrypted */
  ldr r1, =INPTR_R
  ldr r2, =plain_text
  str r2, [r1]

  /* Set the pointer to the packet which will contain the encrypted payload */
  ldr r1, =OUTPTR_R
  ldr r2, =packet
  str r2, [r1]

  /* Start the encryption */
  ldr r1, =TASK_CRYPT_R
  ldr r2, =TASK_CRYPT_START
  str r2, [r1]

  /* Wait for Crypt Task event */
wait_for_end_crypt:
  ldr r1, =EVENTS_ENDCRYPT_R
  ldr r2, =EVENTS_ENDCRYPT
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_for_end_crypt

  /* Encrypted packet should be available at the address of OUTPTR
     Header is 5 bits at offset 0
     Length is a offset 1
     RFU (Reserved For Future) is at offset 2
     Payload is at offset 3
     MIC (tag) is at offset 3+payload length
   */
  ldr r1, =packet
  ldr r2, [r1]

  bl .
