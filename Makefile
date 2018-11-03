.PHONY: run install

run:
	bundle exec jekyll serve

install:
	bundle install --path vendor/bundle
