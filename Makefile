
BIN ?= weather
PREFIX ?= /usr/local

install:
	cp weather.sh $(PREFIX)/bin/$(BIN)

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)

weather.sh:
	./weather.sh

.PHONY: weather.sh

