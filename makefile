install:
	mkdir -p ~/.swift-template
	swift build -c release
	install .build/release/swift-template-cli /usr/local/bin/swift-template

uninstall:
	rm -r ~/.swift-template
	rm /usr/local/bin/swift-template

