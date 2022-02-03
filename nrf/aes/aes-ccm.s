/*
 Example of using the AES CCM peripheral.

 1) A new Keystream needs to be generated before encryption/decryption can
    proceed.

 Encryption is done by reading the unencrypted message located in INPTR, then
 the encryption takes place, followed by appending a 4 byte Message Integrity
 Check (which is a Message Authentication Code (MAC) but is named MIC instead
 as this is what is used in the Bluetooth specification) field to the message.
*/
.thumb

.data

ccm_data_struct:
    .ascii        "bajja"  /* AES Key (16 bytes, 128 bits) */
    .space        9

plain_text:
    .ascii        "hello"

cipher_text:
    .skip 20

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

  /* Set the pointer to the encrypted cipher-text */
  ldr r1, =OUTPTR_R
  ldr r2, =cipher_text
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

  /* Encrypted data should be available at the address of OUTPTR */
  ldr r1, =cipher_text
  ldr r2, [r1]

  bl .
