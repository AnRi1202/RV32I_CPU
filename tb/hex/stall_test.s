addi x1, x0, 0
addi x2, x0, 21
sw x2, 0(x1)
lw x3, 0(x1)
addi x4, x3, 1
add x5, x4, x3
loop:
j loop
