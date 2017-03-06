JEKYLL=JEKYLL_ENV=production bundle exec jekyll

deps:
	bundle install --binstubs --path=vendor

build:
	$(JEKYLL) build

serve:
	$(JEKYLL) serve
