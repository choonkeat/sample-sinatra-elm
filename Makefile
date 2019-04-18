run: static/Main.js
	bundle exec ruby app.rb

static/Main.js: elm src/*.elm
	elm make src/Main.elm --output=static/Main.js

elm:
	@which elm || (echo Install https://guide.elm-lang.org/install.html; exit 1)
