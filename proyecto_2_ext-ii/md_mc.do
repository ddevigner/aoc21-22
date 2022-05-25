onerror {resume}
quietly virtual signal -install /testbench_md_mas_mc/uut/MC { (context /testbench_md_mas_mc/uut/MC )(Tag &dir_cjto &dir_word )} RD_ADDR
quietly virtual signal -install /testbench_md_mas_mc/uut { (context /testbench_md_mas_mc/uut )(MC/Tag &MC/dir_cjto &MC/dir_word & ADDR(1 downto 0) )} RD_ADDR
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLK /testbench_md_mas_mc/uut/CLK
add wave -noupdate -label reset /testbench_md_mas_mc/uut/reset
add wave -noupdate -label IO_input /testbench_md_mas_mc/uut/IO_input
add wave -noupdate -label ADDR /testbench_md_mas_mc/uut/ADDR
add wave -noupdate -label Din /testbench_md_mas_mc/uut/Din
add wave -noupdate -label Dout /testbench_md_mas_mc/uut/Dout
add wave -noupdate -label RE /testbench_md_mas_mc/uut/RE
add wave -noupdate -label WE /testbench_md_mas_mc/uut/WE
add wave -noupdate -label Mem_Ready /testbench_md_mas_mc/uut/Mem_ready
add wave -noupdate -group Arbitro -label bus_frame /testbench_md_mas_mc/uut/Arbitraje/bus_frame
add wave -noupdate -group Arbitro -label Bus_TRDY /testbench_md_mas_mc/uut/Arbitraje/Bus_TRDY
add wave -noupdate -group Arbitro -label Grant0 /testbench_md_mas_mc/uut/Arbitraje/Grant0
add wave -noupdate -group Arbitro -label Grant1 /testbench_md_mas_mc/uut/Arbitraje/Grant1
add wave -noupdate -group Arbitro -label last_word /testbench_md_mas_mc/uut/Arbitraje/last_word
add wave -noupdate -group Arbitro -label priority /testbench_md_mas_mc/uut/Arbitraje/priority
add wave -noupdate -group Arbitro -label Req0 /testbench_md_mas_mc/uut/Arbitraje/Req0
add wave -noupdate -group Arbitro -label Req1 /testbench_md_mas_mc/uut/Arbitraje/Req1
add wave -noupdate -expand -group MC -label @_MC_Way /testbench_md_mas_mc/uut/MC/Via_0/Dir_MC
add wave -noupdate -expand -group MC -expand -group MC_UC -label {palabra_UC (UC)} /testbench_md_mas_mc/uut/MC/Unidad_Control/palabra_UC
add wave -noupdate -expand -group MC -expand -group MC_UC -label is_busy /testbench_md_mas_mc/uut/MC/Unidad_Control/is_busy
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_in -label state /testbench_md_mas_mc/uut/MC/Unidad_Control/state
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_in -label hit /testbench_md_mas_mc/uut/MC/Unidad_Control/hit
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_in -label addr_non_cacheable /testbench_md_mas_mc/uut/MC/Unidad_Control/addr_non_cacheable
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_in -label bus_TRDY /testbench_md_mas_mc/uut/MC/Unidad_Control/bus_TRDY
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_in -label Bus_DevSel /testbench_md_mas_mc/uut/MC/Unidad_Control/Bus_DevSel
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_in -label via_2_rpl /testbench_md_mas_mc/uut/MC/Unidad_Control/via_2_rpl
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_in -label Bus_grant /testbench_md_mas_mc/uut/MC/Unidad_Control/Bus_grant
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_in -label last_word_block /testbench_md_mas_mc/uut/MC/Unidad_Control/last_word_block
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label next_state /testbench_md_mas_mc/uut/MC/Unidad_Control/next_state
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label Bus_req /testbench_md_mas_mc/uut/MC/Unidad_Control/Bus_req
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label MC_WE0 /testbench_md_mas_mc/uut/MC/Unidad_Control/MC_WE0
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label MC_WE1 /testbench_md_mas_mc/uut/MC/Unidad_Control/MC_WE1
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label MC_bus_Rd_Wr /testbench_md_mas_mc/uut/MC/Unidad_Control/MC_bus_Rd_Wr
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label MC_tags_WE /testbench_md_mas_mc/uut/MC/Unidad_Control/MC_tags_WE
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label mux_origen /testbench_md_mas_mc/uut/MC/Unidad_Control/mux_origen
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label block_addr /testbench_md_mas_mc/uut/MC/Unidad_Control/block_addr
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label MC_send_addr_ctrl /testbench_md_mas_mc/uut/MC/Unidad_Control/MC_send_addr_ctrl
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label MC_send_data /testbench_md_mas_mc/uut/MC/Unidad_Control/MC_send_data
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label Frame /testbench_md_mas_mc/uut/MC/Unidad_Control/Frame
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label count_enable /testbench_md_mas_mc/uut/MC/Unidad_Control/count_enable
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label last_word /testbench_md_mas_mc/uut/MC/Unidad_Control/last_word
add wave -noupdate -expand -group MC -expand -group MC_UC -expand -group MC_UC_out -label mux_output /testbench_md_mas_mc/uut/MC/Unidad_Control/mux_output
add wave -noupdate -expand -group MC -expand -group MC_Storage -expand -group Via_0 -label hit_0 /testbench_md_mas_mc/uut/MC/Via_0/hit
add wave -noupdate -expand -group MC -expand -group MC_Storage -expand -group Via_0 -label Via_0_Dout /testbench_md_mas_mc/uut/MC/Via_0/Dout
add wave -noupdate -expand -group MC -expand -group MC_Storage -expand -group Via_0 -label Via_0_tags /testbench_md_mas_mc/uut/MC/Via_0/MC_Tags
add wave -noupdate -expand -group MC -expand -group MC_Storage -expand -group Via_0 -label Via_0_data -expand /testbench_md_mas_mc/uut/MC/Via_0/MC_data
add wave -noupdate -expand -group MC -expand -group MC_Storage -expand -group Via_1 -label hit_1 /testbench_md_mas_mc/uut/MC/Via_1/hit
add wave -noupdate -expand -group MC -expand -group MC_Storage -expand -group Via_1 -label Via_1_Dout /testbench_md_mas_mc/uut/MC/Via_1/Dout
add wave -noupdate -expand -group MC -expand -group MC_Storage -expand -group Via_1 -label Via_1_tags /testbench_md_mas_mc/uut/MC/Via_1/MC_Tags
add wave -noupdate -expand -group MC -expand -group MC_Storage -expand -group Via_1 -label Via_1_data -expand /testbench_md_mas_mc/uut/MC/Via_1/MC_data
add wave -noupdate -expand -group MD -label RE /testbench_md_mas_mc/uut/controlador_MD/MD/RE
add wave -noupdate -expand -group MD -label WE /testbench_md_mas_mc/uut/controlador_MD/MD/WE
add wave -noupdate -expand -group MD -label MD_RAM /testbench_md_mas_mc/uut/controlador_MD/MD/RAM
add wave -noupdate -expand -group MD_Scratch -label MD_Scratch_RAM -expand /testbench_md_mas_mc/uut/M_scratch/MD_scratch/RAM
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1079059 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 185
configure wave -valuecolwidth 78
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
WaveRestoreZoom {0 ps} {163071 ps}
