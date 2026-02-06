auth:
	unset GH_TOKEN && gh auth login

deploy:
	flutter build web --no-tree-shake-icons --release --base-href /egbj_ATCO_HOW_TOW_WebApp/ && \
	rm -rf ~/Development/Flutter_projects/egbj_atco_how_tow/egbj_ATCO_HOW_TOW_WebApp && \
	cp -R ~/Development/Flutter_projects/egbj_atco_how_tow/build/web ~/Development/Flutter_projects/egbj_atco_how_tow/egbj_ATCO_HOW_TOW_WebApp && \
	cd ~/Development/Flutter_projects/egbj_atco_how_tow/egbj_ATCO_HOW_TOW_WebApp && \
	echo "# EGBJ ATCO HOW-TOW webapp" >> README.md  && \
	git init && \
	git add README.md && \
	git commit -m "first commit" && \
	git branch -M main && \
	git remote add origin https://github.com/EgbjATC/egbj_ATCO_HOW_TOW_WebApp.git && \
	git add .  && \
	git commit -m 'deploy' && \
	git push -f origin main && \
	cd ~/Development/Flutter_projects/egbj_atco_how_tow