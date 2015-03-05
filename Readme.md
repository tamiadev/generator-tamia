# Tâmia project generator for Yeoman

[![Build Status](https://travis-ci.org/tamiadev/generator-tamia.png)](https://travis-ci.org/tamiadev/generator-tamia)

Scaffolds out [Tâmia](https://github.com/tamiadev/tamia) and lots of other stuff.


## Getting started

1. Make sure you have [yo](https://github.com/yeoman/yo) installed: `npm install -g yo`.
2. Install the generator locally or globally: `npm install [-g] generator-tamia`.
3. Run: `yo tamia`.

## Sub-generators

```bash
$ yo tamia:framework
```

### framework

Installs/updates latest version of the [Tâmia](https://github.com/tamiadev/tamia) Stylus framework. Also installs jQuery.

### styles

Scaffolds `styles` direcotory with base Stylus styles. Also creates Gruntfile.

### js

Scaffolds `js` direcotory with base main.js file. Also adds JSHint, Uglify and creates/updates Gruntfile.

### deploy

Configures deploy using [shipit](https://github.com/sapegin/shipit).

### component

Creates new JS component.

### block

Creates new Stylus block. Also updates `stylus/index.styl`.

### module

Installs Tâmia module. Also updates Gruntfile and index stylesheet.

### html

Creates new HTML file.

### readme

Creates new HTML file.

### dots

Creates dotfiles: `.jshintrc`, `coffeelint.json`, `.jscs.json`, `.travis.yml`.

### humans

Creates `humans.txt`.

## Additional sub-generators

You can use them without Tâmia.

### jqplugin

Creates new jQuery plugin.

### wordpress

Installs latest version of WordPress.


## Options

```bash
$ yo tamia:framework --skip-bower
```

### `--skip-bower`, `--skip-npm`, `--skip-install`

Skips installation of Bower packages, npm backages or both.


---

## License

The MIT License, see the included [License.md](License.md) file.
