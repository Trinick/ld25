mkdir ..\dist
cd ..\src
..\deps\7za a -tzip ..\dist\ld25.love *
cd ..
cd deps
copy /b love.exe+..\dist\ld25.love ..\dist\ld25.exe
copy /b *.dll ..\dist\
cd ..
dist\ld25.exe
cd util