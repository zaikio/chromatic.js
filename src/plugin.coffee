Chromatic = @Chromatic or {}

$.fn.extend
  chromatic: (photos, options) ->
    new Chromatic.GalleryView(this, photos, options)
    return this
