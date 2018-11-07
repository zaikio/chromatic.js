Chromatic = require './chromatic';

$.fn.extend
  chromatic: (photos, options) ->
    new Chromatic.GalleryView(this, photos, options)
    return this

module.exports = Chromatic;
