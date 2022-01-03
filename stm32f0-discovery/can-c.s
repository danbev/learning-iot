/*
Controller Area Network (CAN) Controller.
*/
.thumb
.text

.equ CAN_MCR_OFFSET, 0x00       /* Master Control Register                  */
.equ CAN_MSR_OFFSET, 0x04       /* Master Status Register                   */
.equ CAN_TSR_OFFSET, 0x08       /* Transmit Status Register                 */
.equ CAN_ESR_OFFSET, 0x18       /* Error Status Register                    */
.equ CAN_BTR_OFFSET, 0x1C       /* Bit Timing Register                      */

.equ CAN_TI0R_OFFSET, 0x180     /* Transmit Mailbox Identifier 0 Register   */
.equ CAN_TDT0R_OFFSET, 0x184    /* Transmit Mailbox Data Time 0 Register    */
.equ CAN_TDL0R_OFFSET, 0x188    /* Transmit Mailbox Data Low 0 Register     */
.equ CAN_TDH0R_OFFSET, 0x18C    /* Transmit Mailbox Data High 0 Register    */

.equ CAN_MCR, CAN_BASE + CAN_MCR_OFFSET
.equ CAN_MSR, CAN_BASE + CAN_MSR_OFFSET
.equ CAN_TSR, CAN_BASE + CAN_TSR_OFFSET
.equ CAN_ESR, CAN_BASE + CAN_ESR_OFFSET
.equ CAN_BTR, CAN_BASE + CAN_BTR_OFFSET

.equ CAN_TI0R, CAN_BASE + CAN_TI0R_OFFSET
.equ CAN_TDT0R, CAN_BASE + CAN_TDT0R_OFFSET
.equ CAN_TDL0R, CAN_BASE + CAN_TDL0R_OFFSET

.equ CAN_MCR_INRQ, 1 << 0        /* Initialization mode request             */
.equ CAN_MCR_SLEEP, 1 << 1       /* Sleep mode                              */
.equ CAN_MCR_NART, 1 << 4        /* Autmatic retransmit                     */
.equ CAN_MSR_INAK, 1 << 0        /* Initialization acknowledgement          */
.equ CAN_BTR_LBKM, 0 << 30       /* Loopback mode                           */
.equ CAN_BTR_SJW, 0x1 << 24      /* Loopback mode                           */
.equ CAN_BTR_TS1, 13 << 16       /* Time Segment 1 (prop seg+phase 1 seg)   */
.equ CAN_BTR_TS2, 2 << 20        /* Time Segment 2 (phase 2 segment)        */
.equ CAN_BTR_BRP, 6 << 0         /* Baud Rate Prescalar                     */
.equ CAN_TSR_TME0, 1 << 26       /* Transmit Mailbox 0 Empty                */
.equ CAN_TI0R_IDE, 0 << 2        /* Identifier extension                    */
.equ CAN_TI0R_TXRQ, 1 << 0       /* Transmit request                        */
.equ CAN_TDT0R_DCL, 1 << 0       /* Data Code Length                        */
.equ CAN_TI0R_ID, 7 << 21        /* Identifier                              */
.equ CAN_TI0R_RTR, 1 << 1        /* Data Frame                              */

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  bl led_init
  bl can_init
  bl can_controller_init
send_loop:
  bl turn_led_on
  bl can_send 
  bl delay
  bl turn_led_off
  b .

can_controller_init:
  /* Set CAN Initialization Request to enter initialization mode */
  ldr r1, =CAN_MCR
  ldr r2, =CAN_MCR_INRQ
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Wait for the Initialization Acknowledgement */
  ldr r1, =CAN_MSR
  ldr r2, =CAN_MSR_INAK
wait_inak_set:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_inak_set

  /* Exit sleep mode */
  ldr r1, =CAN_MCR
  ldr r2, =CAN_MCR_SLEEP
  ldr r0, [r1]
  bic r0, r0, r2
  str r0, [r1]

  /* Set No Automatic Retransmission */
  ldr r1, =CAN_MCR
  ldr r2, =CAN_MCR_NART
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Clear Bit Timing Register */
  ldr r1, =CAN_BTR
  ldr r2, =#0x0000
  str r2, [r1]

  /* Set loopback mode */
  ldr r1, =CAN_BTR
  ldr r2, =CAN_BTR_LBKM
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the reSynchronization Jump Width */
  ldr r1, =CAN_BTR
  ldr r2, =CAN_BTR_SJW
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set Time Segment 1/2 and Baud Rate Prescalar */
  ldr r1, =CAN_BTR
  ldr r2, =(CAN_BTR_TS1 + CAN_BTR_TS2 + CAN_BTR_BRP)
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Exit init mode */
  ldr r1, =CAN_MCR
  ldr r2, =CAN_MCR_INRQ
  ldr r0, [r1]
  bic r0, r0, r2
  str r0, [r1]

  /* Wait for Initialization Acknowledgement mode exit */
  ldr r1, =CAN_MSR
  ldr r2, =CAN_MSR_INAK
wait_inak:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  beq wait_inak

  bx lr

can_send:
  /* Check that the Transmit 0 mailbox is empty */
  ldr r1, =CAN_TSR
  ldr r2, =CAN_TSR_TME0
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne mailbox_0_not_empty

  /* Set standard message type */
  ldr r1, =CAN_TI0R
  ldr r2, =CAN_TI0R_IDE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the message length */
  ldr r1, =CAN_TDT0R
  ldr r2, =CAN_TDT0R_DCL
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set the message */
  ldr r1, =CAN_TDL0R
  ldr r2, ='A'
  str r2, [r1]

  /* Set the identifier */ 
  ldr r1, =CAN_TI0R
  ldr r2, =CAN_TI0R_ID
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Set Remote Transmission Request to be Data Frame */
  ldr r1, =CAN_TI0R
  ldr r2, =CAN_TI0R_RTR
  ldr r0, [r1]
  bic r0, r0, r2
  str r0, [r1]

  /* Request transmission of the mailbox. This bit is cleared by hardware
     when the mailbox becomes empty */
  ldr r6, =CAN_TSR
  ldr r1, =CAN_TI0R
  ldr r2, =CAN_TI0R_TXRQ
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr

mailbox_0_not_empty:
  b .
