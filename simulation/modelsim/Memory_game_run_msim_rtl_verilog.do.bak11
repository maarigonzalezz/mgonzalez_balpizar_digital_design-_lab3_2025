transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/gonza/Desktop/laboratorio\ 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management {C:/Users/gonza/Desktop/laboratorio 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management/verificar_pareja.sv}
vlog -sv -work work +incdir+C:/Users/gonza/Desktop/laboratorio\ 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management {C:/Users/gonza/Desktop/laboratorio 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management/Shuffle.sv}
vlog -sv -work work +incdir+C:/Users/gonza/Desktop/laboratorio\ 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management {C:/Users/gonza/Desktop/laboratorio 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management/mostrar_carta_random.sv}
vlog -sv -work work +incdir+C:/Users/gonza/Desktop/laboratorio\ 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management {C:/Users/gonza/Desktop/laboratorio 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management/bit_shifter.sv}
vlog -sv -work work +incdir+C:/Users/gonza/Desktop/laboratorio\ 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management {C:/Users/gonza/Desktop/laboratorio 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management/seleccionar_parejas.sv}
vlog -sv -work work +incdir+C:/Users/gonza/Desktop/laboratorio\ 3/mgonzalez_balpizar_digital_design-_lab3_2025 {C:/Users/gonza/Desktop/laboratorio 3/mgonzalez_balpizar_digital_design-_lab3_2025/card_controller.sv}

vlog -sv -work work +incdir+C:/Users/gonza/Desktop/laboratorio\ 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management_tb {C:/Users/gonza/Desktop/laboratorio 3/mgonzalez_balpizar_digital_design-_lab3_2025/Arr_Management_tb/tb_card_controller.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_card_controller

add wave *
view structure
view signals
run -all
