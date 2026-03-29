addi x1, x0, 1
addi x2, x0, 2
add x3, x1, x2
add x3, x3, x1
j next
add x1, x0, 4
xor x5, x1, x2
addi x1, x0, -4
next: 
add x1, x0, 8
loop: j loop