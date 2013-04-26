// Generated by CoffeeScript 1.6.2
(function() {
  'use strict';
  var Generator, path, util, yeoman;

  util = require('util');

  path = require('path');

  yeoman = require('yeoman-generator');

  Generator = module.exports = function() {
    return yeoman.generators.Base.apply(this, arguments);
  };

  util.inherits(Generator, yeoman.generators.Base);

  Generator.name = 'Tâmia project generator';

  Generator.prototype.tamia = function() {
    var distUrl, done,
      _this = this;

    console.log('tamia');
    done = this.async();
    distUrl = 'https://github.com/sapegin/tamia/archive/master.tar.gz';
    return this.tarball(distUrl, path.join(this.sourceRoot(), 'tamia'), function() {
      _this.directory('tamia/tamia', 'tamia/tamia');
      _this.directory('tamia/blocks', 'tamia/blocks');
      return done();
    });
  };

}).call(this);
