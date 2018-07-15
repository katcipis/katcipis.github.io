build:V:
	hugo

publish: build
	git add blog categories tags
	git commit -a -m "publish site"
	git push origin

deps:VQ:
	# WHY: https://gohugo.io/getting-started/installing/#source
	# Basically because fuck go get =(
	sudo pacman -S hugo