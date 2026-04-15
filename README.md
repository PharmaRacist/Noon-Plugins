<h1 align="center"> Plugins </h1>
# This is very "Ambitious" yet very early stage plugins system and a very new concept for me ^^

## Roadmap
- [-] Docs
- [ ] Singletons
- [x] Color Palettes
- [x] Sidebar Modules (adds new sidebar contents)
- [ ] Plugins gui easy installer
- [ ] Desktop Widgets --- KDE API Workarounds
- [ ] Bars
- [ ] Bar Modules
- [ ] Dialog Components
- [ ] Routines
- [ ] Ambient Sounds
- [ ] AI Skills - Functions
- [ ] Complete Panels Alterations

## Plugins list
check out: https://github.com/pharmaracist/Noon-plugins
### Sidebar
- [x] Games
- [x] Web
- [x] Deen
- [x] Quickshare
- [x] Sokoun (Ambient Sounds)
- [x] Radio

## Directories Integrity
All plugins are inside `~/.noon_plugins/`.
- every panel has different sub directory eg, ../sidebar, ../palettes, etc

### Color Palettes
those are files inside the "palettes" in format `${PALETTE_NAME}.json` 
- each file name is the same name of palette in UI
- adds are reactive and NO RELOAD NEEDED.
- json keys are material3 colors with m3prefixed camel case check plugins/palettes/example.json

### Sidebar Plugins
- each plugin has to be in a different folder with explicitly named manifest.json
- check the plugins/sidebar/manifest.json
- for the path u need to add prefix `@plugins` for the shell imports to work and use normal qs imports
- qml js engine doesn't pick the imports of the non-siblings this means that script will inject an import "./" string in main entry qml and qmldir in each subdir recruisively in install time
