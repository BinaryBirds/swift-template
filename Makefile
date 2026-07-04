SHELL=/bin/bash

.PHONY: docker

baseUrl = https://raw.githubusercontent.com/BinaryBirds/github-workflows/refs/heads/main/scripts

check: symlinks language deps lint headers

symlinks:
	curl -s $(baseUrl)/check-broken-symlinks.sh | bash

language:
	curl -s $(baseUrl)/check-unacceptable-language.sh | bash

deps:
	curl -s $(baseUrl)/check-local-swift-dependencies.sh | bash

lint:
	curl -s $(baseUrl)/run-swift-format.sh | bash

format:
	curl -s $(baseUrl)/run-swift-format.sh | bash -s -- --fix

headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash

fix-headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash -s -- --fix

docc-local:
	curl -s $(baseUrl)/generate-docc.sh | bash -s -- --local

run-docc:
	curl -s $(baseUrl)/run-docc-docker.sh | bash

docc-warnings:
	curl -s $(baseUrl)/check-docc-warnings.sh | bash

test:
	swift test --parallel

docker-test:
	docker build -t swift-template-tests . -f ./docker/tests/dockerfile && docker run --rm swift-template-tests

docker-run:
	docker run --rm -v $(pwd):/app -it swift:6.1

install:
	mkdir -p ~/.swift-template
	swift build -c release
	install .build/release/swift-template /usr/local/bin/swift-template

uninstall:
	rm -r ~/.swift-template
	rm /usr/local/bin/swift-template


