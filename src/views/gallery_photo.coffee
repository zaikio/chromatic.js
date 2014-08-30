@Chromatic = @Chromatic or {}

class Chromatic.GalleryPhotoView
  constructor: (parent, photo, options) ->
    @parent = parent
    @photo  = photo
    @el     = $('<div class="chromatic-gallery-photo"/>')
    parent.el.append(@el)
    @el.on  'click', @zoom

  load: (callback) =>
    return if @loaded
    image = new Image()
    image.onload = =>
      @photo.aspect_ratio = image.width/image.height
      callback() if callback
      @el.css('backgroundImage', "url(#{@photo.small})")
      @loaded = true
    image.src = @photo.small

  unload: =>
    @el.css('backgroundImage', "")
    @loaded = false

  zoom: =>
    @parent.zoom(@photo)

  resize: (width, height) ->
    @el.css
      width: width - parseInt(@el.css('marginLeft')) - parseInt(@el.css('marginRight'))
      height: height - parseInt(@el.css('marginTop')) - parseInt(@el.css('marginBottom'))
    @top = @el.position().top
    @bottom = @top + @el.height()
