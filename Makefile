.PHONY: lint
lint:
	swift run -c release swiftlint lint --fix --strict

.PHONY: docs
docs:
	swift package generate-documentation

.PHONY: format
format:
	swift run -c release swift-format -r Sources -i