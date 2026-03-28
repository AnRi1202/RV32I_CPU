addi x1, x0, 0
addi x2, x0, 8
sw x2, 0(x1)
lw x3, 0(x1)

addi x4, x0, 12
sw x4, 4(x1)
lw x5, 4(x1)

addi x6, x0, -1
sw x6, 8(x1)
lw x7, 8(x1)

addi x8, x3, 4
sw x8, 12(x1)
lw x9, 12(x1)

lw x10, 0(x1)
lw x11, 4(x1)
lw x12, 8(x1)
lw x13, 12(x1)
