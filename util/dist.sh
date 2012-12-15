mkdir -p dist
cd src && zip -r9 ../dist/ld25.love * && cd ..
zip -r9 dist/ld25.love art
zip -r9 dist/ld25.love sound
cat `which love` dist/ld25.love > dist/ld25 && chmod +x dist/ld25
dist/ld25
