.PHONY: build run clean

build:
	go build -o app

run: build
	./app

clean:
	rm -f app
