cd src
7za a -tzip ..\dist\ld25.love *
cd ..
copy /b love.exe+dist\ld25.love dist\ld25.exe
dist\ld25.exe