@echo off
MODE CON: COLS=180 LINES=500

REM Type source build.tcl
IF EXIST D:\Xilinx\Vivado (GOTO d_drive) ELSE (GOTO c_drive)

:d_drive
  SET PATH=d:\Xilinx\Vivado\2021.2\bin;d:\Xilinx\Vivado\2021.2\lib\win64.o;%PATH%
  SET XILINX_VIVADO=d:\Xilinx\Vivado\2021.2
  GOTO end
	
:c_drive
  SET PATH=C:\Xilinx\Vivado\2021.2\bin;C:\Xilinx\Vivado\2021.2\lib\win64.o;%PATH%
  SET XILINX_VIVADO=C:\Xilinx\Vivado\2021.2
  GOTO end
  
:end

vivado -mode tcl -notrace -source build.tcl
pause
