#!/usr/bin/make -f
SHELL=/bin/bash

HUGO_IMAGE=docker.io/klakegg/hugo:ext-asciidoctor
HUGO_NAME=hugo-kbe
HUGO_ENV=development
HUGO_THEME=beautifulhugo
BIND_HOST?=0.0.0.0
BIND_PORT?=1313

SITE_REPO=https://github.com/tonejito/kbe.git
SITE_URL=https://tonejito.github.io/kbe/
SITE_BRANCH=gh-pages
SITE_DIR=public/

HUGO_ARGS=\
--environment ${HUGO_ENV} \
--debug --verbose --log --verboseLog --logFile /dev/fd/2 \
--bind ${BIND_HOST} --port ${BIND_PORT} \
--theme ${HUGO_THEME} \
--buildDrafts --buildExpired --buildFuture \
--noHTTPCache --ignoreCache \
--disableFastRender

default:	container

install:
	brew install hugo
	# snap install hugo --channel=extended

run:
	 hugo server \
	  ${HUGO_ARGS} --renderToDisk \
	;

container:
	-docker rm ${HUGO_NAME}
	docker run \
	  -it --rm --name ${HUGO_NAME} \
	  -v $(CURDIR):/src \
	  -p ${BIND_PORT}:${BIND_PORT} \
	  ${HUGO_IMAGE} \
	    server \
	      ${HUGO_ARGS} \
	    ;

release:
	git submodule add -f -b ${SITE_BRANCH} ${SITE_REPO} ${SITE_DIR}
	docker run \
	  -it --rm --name ${HUGO_NAME}-release \
	  -v $(CURDIR):/src \
	  ${HUGO_IMAGE} \
	    --baseURL ${SITE_URL} --theme ${HUGO_THEME}
	$(MAKE) -C public -f ../Makefile do_release

do_release:
	git add --all
	git status
	git commit
	git push -u origin ${SITE_BRANCH}
