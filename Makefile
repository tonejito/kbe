#!/usr/bin/make -f
SHELL=/bin/bash

HUGO_IMAGE=docker.io/klakegg/hugo:ext-asciidoctor
HUGO_NAME=hugo-kbe
HUGO_ENV=development
HUGO_THEME=beautifulhugo
BIND_HOST?=0.0.0.0
BIND_PORT?=1313

default:	run

install:
	brew install hugo
	# snap install hugo --channel=extended

run:
	 hugo server \
	  --environment ${HUGO_ENV} \
	  --debug --verbose --log --verboseLog --logFile /dev/fd/2 \
	  --bind ${BIND_HOST} --port ${BIND_PORT} \
	  --theme=${HUGO_THEME} \
	  --buildDrafts --buildExpired --buildFuture \
	  --noHTTPCache --ignoreCache \
	  --renderToDisk --disableFastRender \
	;

container:
	docker run \
	  -it --rm --name ${HUGO_NAME} \
	  -v $(CURDIR):/src \
	  -p ${BIND_PORT}:${BIND_PORT} \
	  ${HUGO_IMAGE} \
	    server \
	      --environment ${HUGO_ENV} \
	      --debug --verbose --log --verboseLog --logFile /dev/fd/2 \
	      --bind ${BIND_HOST} --port ${BIND_PORT} \
	      --theme=${HUGO_THEME} \
	      --buildDrafts --buildExpired --buildFuture \
	      --noHTTPCache --ignoreCache \
	      --disableFastRender \
	    ;
