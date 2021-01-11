onerror {resume}
quietly WaveActivateNextPane {} 0
#                                /<name of the tb entity>/<signal name>
add wave -noupdate -format Logic /tb_elevator/clk_i
add wave -noupdate -format Logic /tb_elevator/gf_cab_i
add wave -noupdate -format Logic /tb_elevator/f1_cab_i
add wave -noupdate -format Logic /tb_elevator/gf_call_i
add wave -noupdate -format Logic /tb_elevator/f1_call_i
add wave -noupdate -format Logic /tb_elevator/gf_end_i
add wave -noupdate -format Logic /tb_elevator/f1_end_i
add wave -noupdate -format Logic /tb_elevator/reset_i
add wave -noupdate -format Logic /tb_elevator/engine_o
add wave -noupdate -format Logic /tb_elevator/i_elevator/s_next_state
add wave -noupdate -format Logic /tb_elevator/i_elevator/s_present_state




TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ps}
WaveRestoreZoom {0 ps} {2000 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -signalnamewidth 0
configure wave -justifyvalue left
