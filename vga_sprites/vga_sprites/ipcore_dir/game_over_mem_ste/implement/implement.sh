#!/bin/sh

# Clean up the results directory
rm -rf results
mkdir results

#Synthesize the Wrapper Files
echo 'Synthesizing XST wrapper file (core_top.vhd) with XST';
echo 'Synthesizing example design with XST';
xst -ifn xst.scr
cp game_over_mem_top.ngc ./results/


# Copy the netlist generated by Coregen
echo 'Copying files from the netlist directory to the results directory'
cp ../../game_over_mem.ngc results/

#  Copy the constraints files generated by Coregen
echo 'Copying files from constraints directory to results directory'
cp ../example_design/game_over_mem_top.ucf results/

cd results

echo 'Running ngdbuild'
ngdbuild -p xc6slx16-csg324-3 game_over_mem_top

echo 'Running map'
map game_over_mem_top -o mapped.ncd -pr i

echo 'Running par'
par mapped.ncd routed.ncd

echo 'Running trce'
trce -e 10 routed.ncd mapped.pcf -o routed

echo 'Running design through bitgen'
bitgen -w routed

echo 'Running netgen to create gate level Verilog model'
netgen -ofmt verilog -sim -tm game_over_mem_top -pcf mapped.pcf -w routed.ncd routed.v
cp routed.sdf ../../production/timing/
