## Bash scripts for Linux and Mac

Bash shell scripts examples. To give ideas of a possible workflow with IDE + Tweego, and what to ask to Chat-GPT!

[Tweego](https://www.motoslave.net/tweego/) is a command line tool for compiling twine files into HTML.

### My directory structure
```
Project
├── audio
├── build
├── images
├── resources
├── src
│   ├── config
│   ├── javascript
│   ├── scenes
│   ├── styles
│   ├── tests
│   ├── ui
│   └── widgets
└── test.html

```

### [build-final.sh](build-final.sh)
* write `setup.mode = 'prod'` in the main JS file
* replace the start passage name in src/config/_story.tw (splash screen for prod)
* compile the Twine .tw (+CSS + JS) files into `build/index.html` with Tweego
* copy the **used** assets into /build (after parsing .tw)
* make an archive ZIP for Itch.io.
* story text analysis (passages count, estimated reading time)
