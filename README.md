# MIPS
Implementation of 32-bit CPU on MAX 10 FPGA using key instructions from the MIPS32 instruction set.

## Datapath
![Datapath](https://user-images.githubusercontent.com/40513675/57999240-b3b84780-7aa2-11e9-925f-b70365c66d36.PNG)

## Selected MIPS32 Instructions
### R-Type
ADDU (Add unsigned)

SUBU (Subtract unsigned)

MULT, MULTU (Signed/unsigned multiplication)

AND, OR, XOR (Bit-wise logic operations)

SRL, SLL, SRA, SLA (Shift left/right, logical/arithmetic)

SLT, SLTU (Set on less than signed/unsigned)

MFHI, MFLO (Move from hi or lo registers)

JR (PC jump to register value)

### I-Type
ADDIU, SUBIU, MULTI, MULTIU (Immediate versions of the basic math operations)

ANDI, ORI, XORI (Immediate versions of the bit-wise logic operations)

SLTI, SLTIU (Immediate versions of the Set On Less Than operations)

LW (Load word from RAM into a register)

SW (Store word from register into RAM address)

BEQ, BNE (Branch on equal, branch on not equal)

BLEZ, BGTZ, BLTZ, BGEZ (Branch on compare to zero)

### J-Type
J (Jump to address directly)

JAL (Jump to address and save the PC to link register)
