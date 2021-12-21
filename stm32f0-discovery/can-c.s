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
.equ CAN_TI0R_OFFSET, 0x180     /* TX Identifier register                   */
.equ CAN_TDT0R_OFFSET, 0x184    /* TX Data length control register          */
.equ CAN_TDL0R_OFFSET, 0x188    /* TX Data low register                     */
.equ CAN_FMR_OFFSET, 0x200      /* Filter Master Register                   */
.equ CAN_FM1R_OFFSET, 0x204     /* Filter Mode Register                     */
.equ CAN_FA1R_OFFSET, 0x21C     /* Filter Activation Register               */
.equ CAN_FFA1R_OFFSET, 0x214    /* Filter FIFO Assignment Register          */

.equ CAN_F0R1_OFFSET, 0x240
.equ CAN_F0R2_OFFSET, 0x248

.equ CAN_MCR, CAN_BASE + CAN_MCR_OFFSET
.equ CAN_MSR, CAN_BASE + CAN_MSR_OFFSET
.equ CAN_TSR, CAN_BASE + CAN_TSR_OFFSET
.equ CAN_ESR, CAN_BASE + CAN_ESR_OFFSET
.equ CAN_BTR, CAN_BASE + CAN_BTR_OFFSET
.equ CAN_FMR, CAN_BASE + CAN_FMR_OFFSET
.equ CAN_FM1R, CAN_BASE + CAN_FM1R_OFFSET
.equ CAN_FA1R, CAN_BASE + CAN_FA1R_OFFSET
.equ CAN_F0R1, CAN_BASE + CAN_F0R1_OFFSET
.equ CAN_F0R2, CAN_BASE + CAN_F0R2_OFFSET
.equ CAN_FFA1R, CAN_BASE + CAN_FFA1R_OFFSET

.equ CAN_MCR_INRQ, 1 << 0        /* Initialization mode request             */
.equ CAN_MCR_SLEEP, 1 << 1       /* Sleep mode                              */
.equ CAN_MSR_INAK, 1 << 0        /* Initialization acknowledgement          */
.equ CAN_BTR_LBKM, 1 << 30       /* Loopback mode                           */
.equ CAN_BTR_TS2, 2 << 20        /* TODO:                                   */
.equ CAN_BTR_TS1, 3 << 16        /* TODO:                                   */
.equ CAN_BTR_BRP, 3 << 16        /* Baud Rate Prescalar                     */
.equ CAN_FMR_INIT, 1 << 0        /* Filter init mode                        */
.equ CAN_FM1R_MASK_MODE, 0 << 0  /* Filter Mask mode                        */
.equ CAN_FM1R_LIST_MODE, 1 << 0  /* Filter List mode                        */
.equ CAN_FA1R_FACT0, 1 << 0      /* Activate Filter 0                       */
.equ CAN_F0R1_IDENT, 7 << 21     /* Identifier (currently ignored)          */
.equ CAN_F0R2_MASK, 0x0000 << 0  /* Filter mask, allow all identifiers      */
.equ CAN_FFA1R_FFA0, 0 << 0      /* FIFO 0 for Filter 0                     */

.global start

Vector_Table:
  .word     0x20002000
  .word     start + 1

start:
  bl can_init
  bl can_controller_init
  b .

can_controller_init:
  ldr r1, =CAN_MCR
  ldr r2, =CAN_MCR_INRQ
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  ldr r1, =CAN_MCR
  ldr r2, =CAN_MSR_INAK
wait_inak_set:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  bne wait_inak_set

  ldr r1, =CAN_MCR
  ldr r2, =CAN_MCR_INRQ
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Exit sleep mode */
  ldr r1, =CAN_MCR
  ldr r2, =CAN_MCR_SLEEP
  ldr r0, [r1]
  bic r0, r0, r2
  str r0, [r1]

  /* Set loopback mode */
  ldr r1, =CAN_BTR
  ldr r2, =CAN_BTR_LBKM
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

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

  ldr r1, =CAN_MCR
  ldr r2, =CAN_MSR_INAK
wait_inak:
  ldr r0, [r1]
  and r0, r0, r2
  cmp r0, r2
  beq wait_inak

  /* Enter Filter init mode */
  ldr r1, =CAN_FMR
  ldr r2, =CAN_FMR_INIT
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Activite Filter 0 */
  ldr r1, =CAN_FA1R
  ldr r2, =CAN_FA1R_FACT0
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Use Mask filter mode */
  ldr r1, =CAN_FM1R
  ldr r2, =CAN_FM1R_MASK_MODE
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Configure the Identifier filter register */
  ldr r1, =CAN_F0R1
  ldr r2, =CAN_F0R1_IDENT
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Configure the Mask filter register */
  ldr r1, =CAN_F0R2
  ldr r2, =CAN_F0R2_MASK
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  /* Select FIFO 0 for Filter 0 */
  ldr r1, =CAN_FFA1R
  ldr r2, =CAN_FFA1R_FFA0
  ldr r0, [r1]
  orr r0, r0, r2
  str r0, [r1]

  bx lr
