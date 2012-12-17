mkdir ..\dist
cd ..\src
..\deps\7za a -tzip ..\dist\ld25.love * ..\art
cd ..
cd deps
copy /b love.exe+..\dist\ld25.love ..\dist\phaedra.exe
copy /b *.dll ..\dist\
cd ..
dist\ld25.exe
cd util
