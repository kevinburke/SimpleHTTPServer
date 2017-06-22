.PHONY: assets static templates

SHELL = /bin/bash

BUMP_VERSION := $(shell command -v bump_version)
DIFFER := $(shell command -v differ)
GO_BINDATA := $(shell command -v go-bindata)
JUSTRUN := $(shell command -v justrun)
STATICCHECK := $(shell command -v staticcheck)

# Add files that change frequently to this list.
WATCH_TARGETS = static/style.css templates/index.html main.go

vet:
ifndef STATICCHECK
	go get -u honnef.co/go/tools/cmd/staticcheck
endif
	go list ./... | grep -v vendor | xargs staticcheck
	go list ./... | grep -v vendor | xargs go vet

test: vet
	go test ./...

race-test: vet
	go test -race ./...

serve:
	go install . && SimpleHTTPServer

generate_cert:
	go run "$$(go env GOROOT)/src/crypto/tls/generate_cert.go" --host=localhost:7065,127.0.0.1:7065 --ecdsa-curve=P256 --ca=true

diff:
	@#no-op is OK - differ will run "git diff" afterwards
	differ ls

# Run "GITHUB_TOKEN=my-token make release version=0.x.y" to release a new version.
release: diff race-test
ifndef version
	@echo "Please provide a version"
	exit 1
endif
ifndef GITHUB_TOKEN
	@echo "Please set GITHUB_TOKEN in the environment"
	exit 1
endif
ifndef BUMP_VERSION
	go get -u github.com/Shyp/bump_version
endif
	bump_version --version=$(version) main.go
	git push origin --tags
	mkdir -p releases/$(version)
	# Change the binary names below to match your tool name
	GOOS=linux GOARCH=amd64 go build -o releases/$(version)/SimpleHTTPServer-linux-amd64 .
	GOOS=darwin GOARCH=amd64 go build -o releases/$(version)/SimpleHTTPServer-darwin-amd64 .
	GOOS=windows GOARCH=amd64 go build -o releases/$(version)/SimpleHTTPServer-windows-amd64 .
ifndef RELEASE
	go get -u github.com/aktau/github-release
endif
	# Change the Github username to match your username.
	# These commands are not idempotent, so ignore failures if an upload repeats
	github-release release --user kevinburke --repo SimpleHTTPServer --tag $(version) || true
	github-release upload --user kevinburke --repo SimpleHTTPServer --tag $(version) --name SimpleHTTPServer-linux-amd64 --file releases/$(version)/SimpleHTTPServer-linux-amd64 || true
	github-release upload --user kevinburke --repo SimpleHTTPServer --tag $(version) --name SimpleHTTPServer-darwin-amd64 --file releases/$(version)/SimpleHTTPServer-darwin-amd64 || true
	github-release upload --user kevinburke --repo SimpleHTTPServer --tag $(version) --name SimpleHTTPServer-windows-amd64 --file releases/$(version)/SimpleHTTPServer-windows-amd64 || true
