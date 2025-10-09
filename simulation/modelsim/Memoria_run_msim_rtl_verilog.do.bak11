transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/space/Desktop/Brayan/Taller_Digitales/Taller_3 {C:/Users/space/Desktop/Brayan/Taller_Digitales/Taller_3/verificar_pareja.sv}
vlog -sv -work work +incdir+C:/Users/space/Desktop/Brayan/Taller_Digitales/Taller_3 {C:/Users/space/Desktop/Brayan/Taller_Digitales/Taller_3/top_verificar_pareja.sv}

vlog -sv -work work +incdir+C:/Users/space/Desktop/Brayan/Taller_Digitales/Taller_3 {C:/Users/space/Desktop/Brayan/Taller_Digitales/Taller_3/verificar_pareja_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  verificar_pareja_tb

add wave *
view structure
view signals
run -all
