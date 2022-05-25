onerror {resume}
quietly virtual signal -install /testbench/uut { /testbench/uut/IR_ID(15 downto 11)} Rd
quietly WaveActivateNextPane {} 0
add wave -noupdate -label {Riesgos control} /testbench/uut/c_r_control/int_count
add wave -noupdate -label {Riesgos de datos} /testbench/uut/c_r_datos/int_count
add wave -noupdate -label {Riesgos estructurales} /testbench/uut/c_r_estructural/int_count
add wave -noupdate -label Ciclos /testbench/uut/c_ciclos/int_count
add wave -noupdate -label CLK /testbench/clk
add wave -noupdate -label Reset /testbench/reset
add wave -noupdate -expand -group IF -label PC /testbench/uut/PC_out
add wave -noupdate -expand -group IF -label {New PC} /testbench/uut/PC_in
add wave -noupdate -expand -group IF -label load_PC /testbench/uut/load_PC
add wave -noupdate -expand -group IF -label MemI_out /testbench/uut/MemI_out
add wave -noupdate -expand -group IF -label IR_in /testbench/uut/IR_in
add wave -noupdate -expand -group IF -expand -group Signals_IF -label Parar_ID /testbench/uut/Parar_ID
add wave -noupdate -expand -group IF -expand -group Signals_IF -label Parar_EX /testbench/uut/Parar_EX_FP
add wave -noupdate -expand -group IF -expand -group Signals_IF -label Kill_if /testbench/uut/Kill_If
add wave -noupdate -expand -group IF -expand -group Signals_IF -label Z /testbench/uut/Z
add wave -noupdate -expand -group IF -expand -group Signals_IF -label Branch /testbench/uut/Branch
add wave -noupdate -expand -group IF -expand -group Signals_IF -label PCSrc /testbench/uut/PCSrc
add wave -noupdate -expand -group ID -label IR /testbench/uut/IR_ID
add wave -noupdate -expand -group ID -label Rs /testbench/uut/Reg_Rs_ID
add wave -noupdate -expand -group ID -label Rt /testbench/uut/Reg_Rt_ID
add wave -noupdate -expand -group ID -label CO /testbench/uut/IR_op_code
add wave -noupdate -expand -group ID -label A /testbench/uut/BusA
add wave -noupdate -expand -group ID -label B /testbench/uut/BusB
add wave -noupdate -expand -group ID -label InmSex /testbench/uut/inm_ext
add wave -noupdate -expand -group ID -label Rd /testbench/uut/Rd
add wave -noupdate -expand -group ID -label BR32 /testbench/uut/INT_Register_bank/reg_file
add wave -noupdate -expand -group ID -label BR32_FP /testbench/uut/FP_Register_bank/reg_file
add wave -noupdate -expand -group ID -label load_EX_FP /testbench/uut/load_EX_FP
add wave -noupdate -expand -group EX -expand -group EX_INT -expand -group MuxA -label MuxA_ctrl /testbench/uut/MUX_ctrl_A
add wave -noupdate -expand -group EX -expand -group EX_INT -expand -group MuxA -label MuxA_out /testbench/uut/Mux_A_out
add wave -noupdate -expand -group EX -expand -group EX_INT -expand -group MuxA -label {(0) A_EX} /testbench/uut/BusA_EX
add wave -noupdate -expand -group EX -expand -group EX_INT -expand -group MuxA -label {(1) ALUOut_MEM} /testbench/uut/ALU_out_MEM
add wave -noupdate -expand -group EX -expand -group EX_INT -expand -group MuxA -label {(2) busW} /testbench/uut/BusW
add wave -noupdate -expand -group EX -expand -group EX_INT -expand -group MuxA -label {(3) 0} /testbench/uut/cero
add wave -noupdate -expand -group EX -expand -group EX_INT -group MuxB -label {(0) B_EX} /testbench/uut/BusB_EX
add wave -noupdate -expand -group EX -expand -group EX_INT -group MuxB -label {(1) ALUOut_MEM} /testbench/uut/ALU_out_MEM
add wave -noupdate -expand -group EX -expand -group EX_INT -group MuxB -label {(2) busW} /testbench/uut/BusW
add wave -noupdate -expand -group EX -expand -group EX_INT -group MuxB -label {(3) 0} /testbench/uut/cero
add wave -noupdate -expand -group EX -expand -group EX_INT -group MuxB -label MuxB_out /testbench/uut/Mux_B_out
add wave -noupdate -expand -group EX -expand -group EX_INT -group MuxB -label MuxB_Ctrl /testbench/uut/MUX_ctrl_B
add wave -noupdate -expand -group EX -expand -group EX_INT -group ALUSrc -label {(0) MuxB} /testbench/uut/Mux_B_out
add wave -noupdate -expand -group EX -expand -group EX_INT -group ALUSrc -label {(1) InmSex_EX} /testbench/uut/inm_ext_EX
add wave -noupdate -expand -group EX -expand -group EX_INT -group ALUSrc -label ALUSrc_out /testbench/uut/ALU_Src_out
add wave -noupdate -expand -group EX -expand -group EX_INT -label ALUOut /testbench/uut/ALU_out_EX
add wave -noupdate -expand -group EX -expand -group EX_INT -group MuxMDSrc -label {(0) MuxB} /testbench/uut/Mux_B_out
add wave -noupdate -expand -group EX -expand -group EX_INT -group MuxMDSrc -label {(1) B_FP_EX} /testbench/uut/busB_FP_EX
add wave -noupdate -expand -group EX -expand -group EX_INT -group MuxMDSrc -label MDSrc_out /testbench/uut/BusB_4_MD
add wave -noupdate -expand -group EX -expand -group EX_INT -group RegDst -label {(0) Rt_EX} /testbench/uut/Reg_Rt_EX
add wave -noupdate -expand -group EX -expand -group EX_INT -group RegDst -label {(1) Rd_EX} /testbench/uut/Reg_Rd_EX
add wave -noupdate -expand -group EX -expand -group EX_INT -group RegDst -label RW /testbench/uut/RW_EX
add wave -noupdate -expand -group EX -expand -group EX_INT -label Rs_EX /testbench/uut/Reg_Rs_EX
add wave -noupdate -expand -group EX -expand -group EX_FP -label RegWrite_FP_EX_mux_out /testbench/uut/RegWrite_FP_EX_mux_out
add wave -noupdate -expand -group EX -expand -group EX_FP -label FP_mem_EX /testbench/uut/FP_mem_EX
add wave -noupdate -expand -group EX -expand -group EX_FP -label A_FP_EX /testbench/uut/busA_FP_EX
add wave -noupdate -expand -group EX -expand -group EX_FP -label B_FP_EX /testbench/uut/busB_FP_EX
add wave -noupdate -expand -group EX -expand -group EX_FP -label ALUFP_ON /testbench/uut/FP_add_EX
add wave -noupdate -expand -group EX -expand -group EX_FP -label ALUFP_DONE /testbench/uut/FP_done
add wave -noupdate -expand -group EX -expand -group EX_FP -label ALUFP_OUT /testbench/uut/ADD_FP_out
add wave -noupdate -expand -group EX -expand -group EX_FP -label Rs_FP_EX /testbench/uut/Reg_Rs_FP_EX
add wave -noupdate -expand -group EX -expand -group EX_FP -label Rt_FP_EX /testbench/uut/Reg_Rt_FP_EX
add wave -noupdate -expand -group EX -expand -group EX_FP -label Rd_FP_EX /testbench/uut/Reg_Rd_FP_EX
add wave -noupdate -expand -group EX -expand -group EX_FP -label RW_FP_EX /testbench/uut/RW_FP_EX
add wave -noupdate -expand -group MEM -group MEM_INT -label ALUOut_MEM /testbench/uut/ALU_out_MEM
add wave -noupdate -expand -group MEM -group MEM_INT -label B_MEM /testbench/uut/BusB_MEM
add wave -noupdate -expand -group MEM -group MEM_INT -label RW_MEM /testbench/uut/RW_MEM
add wave -noupdate -expand -group MEM -group MEM_INT -label MD_DOUT /testbench/uut/Mem_out
add wave -noupdate -expand -group MEM -group MEM_INT -label MD /testbench/uut/Mem_D/RAM
add wave -noupdate -expand -group MEM -expand -group MEM_FP -label RegWrite_FP_MEM /testbench/uut/RegWrite_FP_MEM
add wave -noupdate -expand -group MEM -expand -group MEM_FP -label FP_mem_MEM /testbench/uut/FP_mem_MEM
add wave -noupdate -expand -group MEM -expand -group MEM_FP -label ALUFP_OUT_MEM /testbench/uut/ADD_FP_out_MEM
add wave -noupdate -expand -group MEM -expand -group MEM_FP -label RW_FP_MEM /testbench/uut/RW_FP_MEM
add wave -noupdate -expand -group WB -group WB_INT -expand -group MemToReg -label {(0) ALUOut_WB} /testbench/uut/ALU_out_WB
add wave -noupdate -expand -group WB -group WB_INT -expand -group MemToReg -label {(1) MDR} /testbench/uut/MDR
add wave -noupdate -expand -group WB -group WB_INT -expand -group MemToReg -label busW /testbench/uut/BusW
add wave -noupdate -expand -group WB -group WB_FP -label ALUFP_OUT_WB /testbench/uut/ADD_FP_out_WB
add wave -noupdate -expand -group WB -group WB_FP -label MDR /testbench/uut/MDR
add wave -noupdate -expand -group WB -group WB_FP -label BusW_FP /testbench/uut/BusW_FP
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {450104 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 175
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {77646 ps}
