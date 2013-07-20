# Tâmia project generator for Yeoman [![Build Status](https://travis-ci.org/sapegin/generator-tamia.png)](https://travis-ci.org/sapegin/generator-tamia)

Scaffolds out [Tâmia](https://github.com/sapegin/tamia) and lots of other stuff.


## Getting started

- Make sure you have [yo](https://github.com/yeoman/yo) installed: `npm install -g yo`
- Install the generator locally or globally: `npm install [-g] generator-tamia`
- Run: `yo tamia`


## Sub-generators

```bash
$ yo tamia:framework
```

### framework

Installs/updates latest version of the [Tâmia](https://github.com/sapegin/tamia) Stylus framework. Also installs Modernizr and jQuery.

### styles

Scaffolds `styles` direcotory with base Stylus styles. Also installs Tâmia (tamia:framework) and creates/updates Gruntfile.

### js

Scaffolds `js` direcotory with base main.js file. Also adds JSHint, Uglify and creates/updates Gruntfile.


## Options

```bash
$ yo tamia:framework --skip-bower
```

### `--skip-bower`, `--skip-npm`, `--skip-install`

Skips installation of Bower packages, npm backages or both.


---

## License

The MIT License, see the included `License.md` file.
