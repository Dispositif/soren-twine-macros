# Søren macros for Twine SugarCube v2.37

A few tips or JS macros that may be useful to others.


- [Preload image](#preload-image)
- [imageRight macro](#imageright-macro)
- [Pseudo-random pickFromArray()](#pseudo-random-pickfromarray)
- [decrypt](#decrypt)
- [Remove SugarCube UI](#remove-sugarcube-ui)

-------------

## Preload image

Download images in browser cache, to display them immediately on the following passages. This ensures that players don't experience delays when heavy images are displayed (on the web).

Browsers are smart. You can write preload for the same image on 50 passages, the image will be downloaded only once. No duplicate download or performance issue.

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
To get around CSS "stacking context" issues, I prefer to display large images (illustration, portrait) in a DIV that is not a child of #passages and .passage containers.

It allows also to position and resize independently the image, have the image that extends beyond the .passage box. My .passage can become a text-only box (or a dialog box in a visual novel).

I create different macros depending on the desired positions (right, left, behind, etc.). One example is given below.

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
