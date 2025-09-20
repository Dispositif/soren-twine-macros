# Søren macros for Twine SugarCube v2.37 



![SugarCube](images/sugarcube.png "SugarCube") A few tips or JS that may be useful to others.

- [Preload image](#preload-image)
- [imageRight macro](#imageright-macro)
- [injectBodyImage](#injectbodyimage)
- [Pseudo-random pickFromArray()](#pseudo-random-pickfromarray)
- [decrypt](#decrypt)
- [Remove SugarCube UI](#remove-sugarcube-ui)
- [Click sound](#click-sound)

Also see my [Bash script ideas for Linux/Mac](bash/BASH.md).

-------------

## Preload image

Download images in browser cache, to display them immediately on the following passages. This ensures that players don't experience delays when heavy images are displayed (on the web).

Browsers are smart. You can write preload for the same image on 50 passages, the image will be downloaded only once. No performance issue. Same with audio caching using SC `<<audiocache>>`.

In "StoryInit" I only `<<preload>>` the images displayed on the Start screen : this minimizes the game's loading time.

```javascript
// Preload images inside any passage
// Use : <<preload "images/fu.jpg" "images/bar.png" … >>
Macro.add('preload', {
    handler() {
        const urls = this.args.filter(Boolean);
        urls.forEach(u => { const img = new Image(); img.src = u; });
    }
});
```

Example of use : 
```html
:: Test
<<preload "images/fu.jpg" "images/bar.png">>
This passage preload two images in browser cache.
```

💡 How to cache videos ? Just use `<<audiocache>>` ! 


-----------


## imageRight macro
To get around CSS "[stacking context](https://philipwalton.com/articles/what-no-one-told-you-about-z-index/)" issues, I prefer to display large images (illustration, portrait) in a DIV that is not a child of #passages and .passage containers.

It allows to position and resize independently the image, have the image that extends beyond (behind) the .passage box. My .passage can become a text-only box (a small dialog box in a visual novel).

In my visual novel, I created different macros depending on the desired NPC portrait positions (right, left, behind, etc.). One example is given below. It uses a [transparent.png](images/transparent.png) image when not needed (Why I didn't use a `.hidden` class?).

An other solution is to use my macro [`<<injectBodyImage>>`](#injectbodyimage). 

HTML in StoryInterface :
```html
:: StoryInterface
<div id="design">
    <div id="image-right" style="display:none;"><img class="responsive-image" src="images/transparent.png" /></div>
</div>
<div id="passages"></div>
```

Javascript :
```javascript
setup.transparentUrl = "images/transparent.png";

// Change the right panel image (desktop) which is outside the #passage container.
// Use : <<imageRight "srcImage.png">>
Macro.add('imageRight', {
    handler: function () {
        const imgUrl = this.args[0] || setup.transparentUrl;
        setTimeout(() => {
            const $container = $('#image-right');
            const $img = $container.find('img.responsive-image');
            if ($img.length > 0) {
                $container.show();
                $img.attr('src', imgUrl);
            }
            if (imgUrl === setup.transparentUrl) {
                $container.hide();
            }
        }, 0);
    }
});
```

Use in a passage :
```html
:: Test
<<imageRight "images/hero.png">> \
This passage display an image on the right side of the screen.
```

CSS example (image on the right side) :
```css
#image-right {
    position: fixed;
    z-index: 10;
    right: 0.5rem;
    top: 3rem;
    height: 100%;
    width: auto;
}
.passage {
    z-index: 20; /* above #image-right */
    max-width: 50%;
    background: rgba(255, 255, 255, 0.7); /* semi-transparent */
    border: 1px solid red;
}
```


## injectBodyImage

This macro create a `<div>` containing an `<img>` directly into the `<body>`. This ensures the CSS stacking context is the body, not #passage. The image can extend beyond (or behind) the `.passage` box borders.

A more flexible solution than my [`<<imageRight>> macro`](#imageright-macro). With `<<injectBodyImage>>`, no need to create in advance a DIV in the `StoryInterface` passage.


```javascript
/**
 * <<injectBodyImage "className" "image.png">>
 *
 * Injects a <div> containing an <img> directly into the <body>.
 * This ensures the stacking context is the body, not #passage.
 * If a div with the same class already exists in <body>, it is removed
 * before appending the new one (prevents stacking duplicates).
 *
 * @param {string} className - CSS class of the new <div>
 * @param {string} imgSrc - Path of the image
 * @returns {void}
 *
 * Example:
 *   <<injectBodyImage "portrait" "images/alice.png">>
 */
Macro.add('injectBodyImage', {
    handler: function () {
        if (this.args.length < 2) {
            return this.error('Usage: <<injectBodyImage "className" "image.png">>');
        }
        const divClass = this.args[0];
        const imgSrc   = this.args[1];

        setTimeout(() => {
            $('body').find('.' + divClass).remove();
            const $newDiv = $('<div>', { class: divClass }).append(
                $('<img>', { src: imgSrc })
            );
    
            $('body').append($newDiv);
        }, 0);
    }
});

/**
 * Removes a <div> (and child elements).
 * @param {string} className - CSS class of the <div> to remove
 * Example:
 *   <<removeBodyImage "portrait">>
 */
Macro.add('removeBodyImage', {
    handler: function () {
        const className = String(this.args[0]).trim();
        if (!className) {
            return this.error('Invalid className: empty string.');
        }
        setTimeout(() => {
            $('body').find('.' + className).remove();
        }, 0);
    }
});


```

In a passage :
```html
:: Test
<<injectBodyImage "portrait" "images/alice.png">>
This passage inject a div.portrait containing an image directly into the body.
[[Test2]]

:: Test2
This passage does not inject the image again, so the image is still visible.
[[Test3]]

:: Test3
<<injectBodyImage "portrait" "images/bob.png">>
This passage replaces the image with another one.
[[Test4]]

:: Test4
<<removeBodyImage "portrait">>
This passage removes the image, using the removeBodyImage macro.
```

CSS example :
```css
.portrait {
    position: fixed;
    z-index: 10;
    right: 0.5rem;
    top: 3rem;
    height: 100%;
    width: auto;
}
.passage {
    z-index: 20; /* above .portrait */
    max-width: 50%;
    background: rgba(255, 255, 255, 0.7); /* semi-transparent */
    border: 1px solid red;
}
```

Tips : For the implementation of a game, I create dedicated widgets for recurring images.
Example : 
```html
:: characterPortrait [widget nobr]
<<widget "characterPortrait">>
   <<if ndef _args[0] || _args[0]=''>><<removeBodyImage "portrait">><</if>>
   <<if _args[0] === "Bob">>
      <<injectBodyImage "portrait" "images/bob.png">>
      /* ... other characters... */
   <</if>>
<</widget>>

:: Test
<<characterPortrait "Bob">>
This passage displays Bob's portrait. [[Go to Test2|Test2]]

:: Test2
<<characterPortrait>>
This passage removes the portrait.
```

----------


## Pseudo-random pickFromArray()
Pick deterministic-random element from array, using seed. You obtain the same result each time you use the same seed. 
Essential for procedural generation of passages, events, NPC names, etc.

Javascript :
```javascript
/* Hash (FNV-1a 32-bit). Example "test" -> 16777619 */
setup.fnv1aHash = function (str) {
    let h = 0x811c9dc5 >>> 0;
    for (let i = 0; i < str.length; i++) {
        h ^= str.charCodeAt(i);
        h = Math.imul(h >>> 0, 0x01000193) >>> 0;
    }
    return h >>> 0;
};

/**
 * Pick (deterministic) random element from array, using seed.
 * @param seed {string|number} Seed value
 * @param arr {Array} Array to pick from
 * @param salt {number} Optional salt to vary the result
 * @returns {*} An element from arr
 */
setup.pickFromArray = function (seed, arr, salt = 0) {
    if (!Array.isArray(arr) || arr.length === 0) {
        throw new Error("Array is empty.");
    }
    const hash = setup.fnv1aHash(String(seed));
    const mixed = (hash ^ Math.imul(salt >>> 0, 0x9e3779b9)) >>> 0;
    return arr[mixed % arr.length];
};
```

Use in a passage :
```xhtml
:: Test
<<set _item = setup.pickFromArray(passage(), ["apple", "banana", "cherry"]) >>
<<= _item>>
```

Note : if you want seed everywhere, you can use the SugarCube [random()](https://www.motoslave.net/sugarcube/2/docs/#functions-function-random) with [State.prng.init()](https://www.motoslave.net/sugarcube/2/docs/#state-api-method-prng-init)

--------


## random events
(todo)

----

## decrypt
Decipher the content of a passage written in ROT13. With this naive encryption method some passages can be unreadable in the source code (like the final solution of a puzzle).
Use online ROT13 tool to encode the text.

Javascript : 
```javascript
setup.decrypt = function(message) {
    const originalAlpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const cipher = "nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM";
    return message.replace(/[a-z]/gi, letter =>
        cipher[originalAlpha.indexOf(letter)]
    );
};

// Use : <<decrypt>>Uryyb<</decrypt>> -> Hello
Macro.add('decrypt', {
    handler() {
        const text = this.payload[0].contents.trim();
        const decoded = setup.decrypt(text);
        $(this.output).wiki(decoded);
    }
});
```
Example bellow display the text "Hello!"
```html
:: Test
<<decrypt>>Uryyb!<</decrypt>>
```
----

## translation macros + i18n-tracker
(todo)

## Remove SugarCube UI
To remove default UI bar and some sticky CSS. _The taste of freedom._

JavaScript :
```javascript
UIBar.destroy(); $('#ui-bar').remove();
```
Overwrite some sugar CSS : 
```css
#ui-overlay {
    height: 0px;
    width: 0px;
    top: 10px;
    right: 10px;
    transition: none;
}

#ui-overlay:not(.open) {
    -webkit-transition: none;
    -moz-transition: none;
    transition: none;
}

a.link-external::after {
    display: none;
}

/* and work on .passage styling !! */
```

-----------------------

## Click sound
Play a sound when the player clicks on internal links.

Javascript :
```javascript
const clickSound = new Audio("audio/sfx/click.mp3");
clickSound.volume = 0.4; // adjust as needed

/* Play sound on click of internal links */
$(document).on('click', '[data-passage].link-internal', function (e) {
    clickSound.currentTime = 0;
    clickSound.play().catch(err => {
        console.warn("Click sound couldn't be played:", err);
    });
});
```
In `StoryInit` passage :
```html
:: StoryInit
<<cacheaudio "click" "audio/sfx/click.mp3">> /* Keep! JS click sound */
```
