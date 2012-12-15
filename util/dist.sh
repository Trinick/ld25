mkdir -p dist
cd src && zip ../dist/ld25.love * && cd ..
cat `which love` dist/ld25.love > dist/ld25 && chmod +x dist/ld25
dist/ld25
