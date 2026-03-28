addi x1, x0, 0

# Byte tests
# expect: mem[0] = 0x80
#   lb  -> x3  = 0xffffff80
#   lbu -> x4  = 0x00000080
addi x2, x0, -128
sb x2, 0(x1)
lb x3, 0(x1)
lbu x4, 0(x1)

# expect: mem[1] = 0x7f
#   lb  -> x6  = 0x0000007f
#   lbu -> x7  = 0x0000007f
addi x5, x0, 127
sb x5, 1(x1)
lb x6, 1(x1)
lbu x7, 1(x1)

# Halfword tests
# x8 lower 16-bit = 0x8123
# expect:
#   lh  -> x9  = 0xffff8123
#   lhu -> x10 = 0x00008123
lui x8, 0x8
addi x8, x8, 0x123
sh x8, 4(x1)
lh x9, 4(x1)
lhu x10, 4(x1)

# x11 lower 16-bit = 0x7456
# expect:
#   lh  -> x12 = 0x00007456
#   lhu -> x13 = 0x00007456
lui x11, 0x7
addi x11, x11, 0x456
sh x11, 6(x1)
lh x12, 6(x1)
lhu x13, 6(x1)

# Word sanity check after subword stores
# expect:
#   x14 = 0x00007f80
#   x15 = 0x74568123
lw x14, 0(x1)
lw x15, 4(x1)
