.PHONY: build
build:
	hugo

.PHONY: run
run:
	hugo server

.PHONY: publish
publish: build
	git add blog categories tags
	git commit -a -m "publish site"
	git push origin

.PHONY: deps
deps:
	# WHY: https://gohugo.io/getting-started/installing/#source
	# Basically because fuck go get =(
	sudo pacman -S hugo
