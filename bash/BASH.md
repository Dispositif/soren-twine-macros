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
A script to build the final production version of the game.
* replace `setup.mode = xxxx` with `setup.mode = 'prod'` in the main JS file
* replace the start passage name in my src/config/_story.tw "StoryData" with the prod start (splash screen)
* compile the Twine .tw (+CSS + JS) files into `build/index.html` with Tweego
* copy the **used** assets into /build (after parsing .tw). Only detect asset paths between double quotation marks ""
* make an archive ZIP for Itch.io.
* story text analysis (passages count, estimated reading time)

Don't forget to do `chmod +x build-final.sh` to make the script executable.

On Mac, I use https://brew.sh/ to install many packages, some of them are used in this script (zip, chrome…). Ask Chat-GPT for help.
