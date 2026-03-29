lui x1, 0x12345
auipc x2, 0x1

jal x3, jal_target
addi x4, x0, 99

jal_target:
addi x5, x3, 16
jalr x6, x5, 0

addi x7, x0, 77

lui x8, 0xabcde
auipc x9, 0x2

jal x0, done
addi x10, x0, 1

done:
jal x0, done
