# My personal website

## System dependencies

To build the site:

* `ruby`
* `ruby-dev`
* RubyGems 3+
* `bundler` gem

## Local dependencies

`sudo make prepare`

## Local server

`make run`

## Using docker

```
docker build . --tag githubio
docker run --volume="$PWD:/src/jekyll" -p 4000:4000 -it githubio jekyll serve --host 0.0.0.0 --port 4000
```
