#!/bin/bash
# Corrida de exploracion (temporal)
vcs -full64 -sverilog -debug_access+all -timescale=1ns/1ps \
    -f filelist.f \
    ../sim/tb_explore.sv \
    -l explore_compile.log -o simv_explore

./simv_explore -l explore_sim.log
