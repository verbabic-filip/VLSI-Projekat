onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/at
add wave -noupdate /top/bt
add wave -noupdate /top/oct
add wave -noupdate /top/out
add wave -noupdate /top/clk
add wave -noupdate /top/rst_n
add wave -noupdate /top/cl
add wave -noupdate /top/ld
add wave -noupdate /top/inc
add wave -noupdate /top/dec
add wave -noupdate /top/outr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {200 ps}
