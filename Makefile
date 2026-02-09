SHELL := /bin/bash

.PHONY: help format lint test check build facetimectl clean

help:
	@printf "%s\n" \
		"make format      - swift format in-place" \
		"make lint        - swift format lint" \
		"make test        - swift test" \
		"make check       - lint + test" \
		"make build       - release build into bin/ (codesigned)" \
		"make facetimectl - clean rebuild + run debug binary (ARGS=...)" \
		"make clean       - swift package clean"

format:
	swift format --in-place --recursive Sources Tests

lint:
	swift format lint --recursive Sources Tests

test:
	scripts/generate-version.sh
	swift test

check:
	$(MAKE) lint
	$(MAKE) test

build:
	scripts/generate-version.sh
	mkdir -p bin
	swift build -c release --product facetimectl
	cp .build/release/facetimectl bin/facetimectl
	codesign --force --sign - --identifier com.steipete.facetimectl bin/facetimectl

facetimectl:
	scripts/generate-version.sh
	swift package clean
	swift build -c debug --product facetimectl
	./.build/debug/facetimectl $(ARGS)

clean:
	swift package clean
