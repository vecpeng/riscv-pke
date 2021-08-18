#include "util/load_store.S"

#
# M-mode trap entry point
#
.globl mtrapvec
.align 4
mtrapvec:
    # swap a0 and mscratch
    # so that a0 points to interrupt frame
    csrrw a0, mscratch, a0

    # save the registers in interrupt frame
    addi t6, a0, 0
    store_all_registers
    # save the user a0 in itrframe->a0
    csrr t0, mscratch
    sd t0, 72(a0)

    # use stack0 for sp
    la sp, stack0
    li a3, 4096
    csrr a4, mhartid
    addi a4, a4, 1
    mul a3, a3, a4
    add sp, sp, a3

    // save the address of interrupt frame in the csr "mscratch"
    csrw mscratch, a0

    call handle_mtrap

    // restore all registers
    csrr t6, mscratch
    restore_all_registers

    mret

