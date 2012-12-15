mkdir ../dist
cd ../src
7za a -tzip ..\dist\ld25.love *
cd ..
cd windows
copy /b love.exe+..\dist\ld25.love ..\dist\ld25.exe
copy /b *.dll ..\dist\
cd ..
dist\ld25.exe
