@echo off
for %%d in (*.ppm) do del %%d
for %%d in (*.awb) do ..\awbm_ppm.vk\awbm_ppm.exe %%d
call pmview *.ppm
for %%d in (*.ppm) do del %%d