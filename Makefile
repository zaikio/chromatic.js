SOURCES := $(shell find src/ -type f -name *.coffee)

dist/chromatic.min.js: dist/chromatic.js
	npm run dist/chromatic.min.js

dist/chromatic.js: dist/chromatic.es.js
	npm run dist/chromatic.js

dist/chromatic.es.js: node_modules $(SOURCES)
	npm run dist/chromatic.es.js

node_modules: package.json
	npm install
	touch node_modules
