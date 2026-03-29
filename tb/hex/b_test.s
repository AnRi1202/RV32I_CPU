  addi x1, x0, 1
  addi x2, x0, 2
  loop:
  slt x3, x1, x2
  bne x1, x2, loop
