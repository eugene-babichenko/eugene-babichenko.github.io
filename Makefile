.PHONY: run install

all: run

run:
	bundle exec jekyll serve

prepare:
	bundle install --path vendor/bundle
