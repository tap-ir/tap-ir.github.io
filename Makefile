.PHONY: docs

h help:
	@grep '^[a-z]' Makefile

docs:
	npx docsify-cli serve 

docs-py:
	python3 -m http.server 3000
