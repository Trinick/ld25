mkdir -p dist
cd src && zip -r9 ../dist/ld25.love * && cd ..
zip -r9 dist/ld25.love art
cat `which love` dist/ld25.love > dist/phaedra && chmod +x dist/phaedra
dist/phaedra
