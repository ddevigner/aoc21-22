# -----------------------------------------------------------------------------
# Author: Devid Dokash.
# Version: v1.12
# -----------------------------------------------------------------------------
import re
import sys

def params(instr):
    instr = re.sub(r'\n|\t', ' ', instr)
    op = instr.split(" ")[0]
    instr = instr[len(op):].split(";")[0]
    instr = re.sub(r' +|\)|r|R|fp|FP|', '', instr).replace('(',',')
    return [op] + re.split(',', instr)

if not len(sys.argv) == 2:
    print("\n\nusage -- fast-ram <input-file>\n")
    exit(1)

input  = open(sys.argv[1], 'r')
output = open(f"ram_{(sys.argv[1].split('.'))[0]}.out", 'w')
output.write ("signal RAM : RamType := (\t")
asm = ""
pc  = 0
n   = 0

for instr in input.readlines():
    pc = pc + 4
    if instr != "\n":
        ins_t = params(instr)
        ins_t[0] = str.lower(ins_t[0])
        print(ins_t)

        if ins_t[0] == 'nop':
            # NOP: 000000 00000 00000 00000 00000 0000000
            asm = '00000000'
        else:
            if ins_t[0] == 'add':
                # ADD rd, rs, rt: 000001 sssss ttttt ddddd 00000 0000000
                rs =  f"{int(ins_t[2]):05b}"
                rt =  f"{int(ins_t[3]):05b}"
                rd =  f"{int(ins_t[1]):05b}"
                asm = f"{int('000001' + rs + rt + rd + '00000000000', 2):08x}"
            elif ins_t[0] == 'lw':
                # LW rt, inm(rs): 000010 sssss ttttt iiiiiiiiiiiiiiiiiii
                rs  = f"{int(ins_t[3]):05b}"
                rt  = f"{int(ins_t[1]):05b}"
                if int(ins_t[2]) < 0:
                    inm = f"{(1<<16) - abs(int(ins_t[2])):016b}"
                else:
                    inm = f"{int(ins_t[2]):016b}"
                asm = f"{int('000010' + rs + rt + inm, 2):08x}"
            elif ins_t[0] == 'sw':
                # SW rt, inm(rs): 000011 sssss ttttt iiiiiiiiiiiiiiiiiii
                rs  = f"{int(ins_t[3]):05b}"
                rt  = f"{int(ins_t[1]):05b}"
                if int(ins_t[2]) < 0:
                    inm = f"{(1<<16) - abs(int(ins_t[2])):016b}"
                else:
                    inm = f"{int(ins_t[2]):016b}"
                asm = f"{int('000011' + rs + rt + inm, 2):08x}"
            elif ins_t[0] == 'beq':
                # BEQ rs, rt, inm: 000100 sssss ttttt iiiiiiiiiiiiiiiiiii
                rs  = f"{int(ins_t[1]):05b}"
                rt  = f"{int(ins_t[2]):05b}"
                cod = int((int(ins_t[3])-pc)/4)
                if cod < 0:
                    inm = f"{(1<<16) - abs(cod):b}"
                else:
                    inm = f"{cod:016b}"
                asm = f"{int('000100' + rs + rt + inm, 2):08x}"
            elif ins_t[0] == 'addfp':
                # ADDFP rd, rs, rt: 100001 sssss ttttt ddddd 00000 0000000
                rs =  f"{int(ins_t[2]):05b}"
                rt =  f"{int(ins_t[3]):05b}"
                rd =  f"{int(ins_t[1]):05b}"
                asm = f"{int('100001' + rs + rt + rd + '00000000000', 2):08x}"
            elif ins_t[0] == 'lwfp':
                # LWFP rtm imm(rs): 100010 sssss ttttt iiiiiiiiiiiiiiiiiii
                rs  = f"{int(ins_t[3]):05b}"
                rt  = f"{int(ins_t[1]):05b}"
                if int(ins_t[2]) < 0:
                    inm = f"{(1<<16) - abs(int(ins_t[2])):016b}"
                else:
                    inm = f"{int(ins_t[2]):016b}"
                asm = f"{int('100010' + rs + rt + inm, 2):08x}"
            elif ins_t[0] == 'swfp':
                # SWFP rt, imm(rs): 100011 sssss ttttt iiiiiiiiiiiiiiiiiii
                rs  = f"{int(ins_t[3]):05b}"
                rt  = f"{int(ins_t[1]):05b}"
                if int(ins_t[2]) < 0:
                    inm = f"{(1<<16) - abs(int(ins_t[2])):016b}"
                else:
                    inm = f"{int(ins_t[2]):016b}"
                asm = f"{int('100011' + rs + rt + inm, 2):08x}"
        output.write(f"X\"{asm}\"")
        if not n == 127:
            output.write(", ")
        else:
            output.write(");")
        if n % 8 == 7:
            output.write("\n\t\t\t\t\t\t\t")
        n += 1

for n in range(n, 128):
    output.write(f"X\"00000000\"")
    if not n == 127:
        output.write(", ")
    else:
        output.write(");")
    if n % 8 == 7:
        output.write("\n\t\t\t\t\t\t\t")
