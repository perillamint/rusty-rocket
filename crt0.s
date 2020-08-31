.macro CLEAR_GPR_REG_ITER
    mov r\@, #0
.endm

.arm
.align 5
__start:
    .rept 16
    nop
    .endr
    /* Switch to supervisor mode, mask all interrupts, clear all flags */
    msr cpsr_cxsf, #0xDF

    //// FUCK, reset
    //ldr r0, =0x60006004
    //ldr r1, =0x04
    //str r1, [r0]

    // Initialize stack pointer
    ldr sp, =0x4003F000
    mov fp, #0

    // Erase BSS
    ldr r0, =__bss_start__
    ldr r1, =__bss_end__
    ldr r2, =0
.Lclearbss:
    str r2, [r0]
    add r0, r0, #4
    cmp r0, r1
    blt .Lclearbss

    .rept 13
    CLEAR_GPR_REG_ITER
    .endr

    //@ Set address of user IRQ handler
    //ldr r0, =MainIrqHandler
    //ldr r1, =0x03FFFFFC
    //str r0, [r1]

    //@ set IRQ stack pointer
    //mov r0, #0x12
    //msr CPSR_c, r0
    //ldr sp, =0x3007fa0

    //@ set user stack pointer
    //mov r0, #0x1f
    //msr CPSR_c, r0
    //ldr sp, =0x3007f00

    //@ copy .data section to IWRAM
    //ldr r0, =__data_lma     @ source address
    //ldr r1, =__data_start   @ destination address
    //ldr r2, =__data_end
    //subs r2, r1             @ length
    //@ these instructions are only executed if r2 is nonzero
    //@ (i.e. don't bother copying an empty .data section)
    //addne r2, #3
    //asrne r2, #2
    //addne r2, #0x04000000
    //swine 0xb0000

    // jump to user code
    bl main

//    .global MainIrqHandler
//    .align 4, 0
//MainIrqHandler:
//    @ Load base I/O register address
//    mov r2, #0x04000000
//    add r2, r2, #0x200
//
//    @ Save IRQ stack pointer and IME
//    mrs r0, spsr
//    ldrh r1, [r2, #8]
//    stmdb sp!, {r0-r2,lr}
//
//    @ Disable all interrupts by writing to IME
//    @ r2 (0x4000200) can be used as we only care about bit 0 being unset
//    strh r2, [r2, #8]
//
//    @ Acknowledge all received interrupts that were enabled in IE
//    ldr r3, [r2, #0]
//    and r0, r3, r3, lsr #16
//    strh r0, [r2, #2]
//
//    @ Switch from IRQ mode to system mode
//    @ cpsr_c = 0b000_10010u8 | 0b000_01101u8
//    mrs r2, cpsr
//    orr r2, r2, #0xD
//    msr cpsr_c, r2
//
//    @ Jump to user specified IRQ handler
//    ldr r2, =__IRQ_HANDLER
//    ldr r1, [r2]
//    stmdb sp!, {lr}
//    adr lr, .Lreturn
//    bx r1
//.Lreturn:
//    ldmia sp!, {lr}
//
//    @ Switch from ??? mode to IRQ mode, disable IRQ
//    @ cpsr_c = ( !0b000_01101u8 & cpsr_c ) | 0b100_10010u8
//    mrs r2, cpsr
//    bic r2, r2, #0xD
//    orr r2, r2, #0x92
//    msr cpsr_c, r2
//
//    @ Restore IRQ stack pointer and IME
//    ldmia sp!, {r0-r2,lr}
//    strh r1, [r2, #8]
//    msr spsr_cf, r0
//
//    @ Return to BIOS IRQ handler
//    bx lr
//    .pool
