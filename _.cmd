@echo off
call stampdef awbm_ppm.def
call pasvpdsp awbm_ppm awbm_ppm.vk\
copy awbm_ppm.vk\awbm_ppm.exe awbm_ppm.vk\awbm_ppm.com
call copywdx awbm_ppm.vk\
call pasvpo awbm_ppm awbm_ppm.vk\

call ..\genvk AWBM_PPM

cd awbm_ppm.vk
call genpgp
cd ..


