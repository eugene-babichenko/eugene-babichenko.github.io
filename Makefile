.PHONY: run install

all: run

run:
	bundle exec jekyll serve

install:
	bundle install --path vendor/bundle
