VERSION ?= $(shell cat VERSION)
IMAGE   := wirelessjeano/peatio:$(VERSION)

.PHONY: default build push run ci deploy

default: build run

build:
	@echo '> Building "peatio" docker image...'
	@docker build -t $(IMAGE) .

push: build
	@docker push $(IMAGE)

run:
	@echo '> Starting "peatio" container...'
	@docker run -it -p 3000:3000 --rm $(IMAGE) bash

ci:
	@fly -t ci set-pipeline -p peatio -c config/pipelines/review.yml -n
	@fly -t ci unpause-pipeline -p peatio

deploy: push
	@helm install ./config/charts/peatio --set "image.tag=$(VERSION)"
