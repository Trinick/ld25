mkdir ..\dist
cd ..
deps\7za a -tzip dist\ld25.love src\*
cd deps
copy /b love.exe+..\dist\ld25.love ..\dist\ld25.exe
copy /b *.dll ..\dist\
cd ..
dist\ld25.exe
