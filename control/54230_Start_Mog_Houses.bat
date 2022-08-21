@echo off
cd ..
:onCrash
echo [%date% %time%] Restarting Cities Map Server...
rem xi_map.exe --ip 91.132.137.205 --port 54230
xi_map.exe
echo ...
GOTO onCrash