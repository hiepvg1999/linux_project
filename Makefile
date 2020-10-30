build:
	make clean
	mkdir dist
	cd dist
	cp test.sh dist 
	chmod +x dist/test.sh
clean:
	rm -Rf dist
