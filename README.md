# Søren macros for Twine SugarCube v2.37

A few tips that may be useful to others.

## Preload image
Download images in browser cache, to display them immediately on other passages.

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
How to cache videos ? Just use `<<audiocache>>` ! ;-)

---

## imageRight

## Pseudo-random pickFromArray()
Pick deterministic-random element from array, using seed. You obtain the same result each time you use the same seed. 
Essential for procedural generation of passages, events, NPC names, etc.

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

Use :
```xhtml
:: Test
<<set _item = setup.pickFromArray(passage(), ["apple", "banana", "cherry"]) >>
<<= _item>>
```

## random events

## decrypt
Déchiffrez le contenu d'un passage, écrit en ROT13. Ca permet de rendre illisible un texte dans le code source (solution d'une énigme)
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

## translation macros + i18n-tracker

## Remove SugarCube UI
To clean default UI…

JavaScript :
```javascript
// remove UI bar
UIBar.destroy(); $('#ui-bar').remove();
```
CSS : 
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
