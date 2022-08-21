@echo off
cd ..
:onCrash
echo [%date% %time%] Restarting No-Go Map Server...
xi_map.exe --ip 91.132.137.205 --port 54340
echo ...
GOTO onCrash