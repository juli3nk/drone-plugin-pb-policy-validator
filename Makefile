
IMAGE_NAME := "juli3nk/drone-pb-release-validator"

.PHONY: build
build:
	docker image build \
		-t $(IMAGE_NAME) \
		.

.PHONY: push
push:
	docker image push $(IMAGE_NAME)
