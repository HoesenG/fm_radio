#!/bin/csh

source /vol/eecs392/env/questasim.env

mkdir -p lib
make -f Makefile.questa dpi_lib32 LIBDIR=lib

vsim -do fm_radio_sim_uvm.do
