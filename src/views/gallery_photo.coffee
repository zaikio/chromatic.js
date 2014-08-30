@Chromatic = @Chromatic or {}

class Chromatic.GalleryPhotoView
  constructor: (parent, photo, options) ->
    @parent = parent
    @photo  = photo
    @el     = $('<div class="chromatic-gallery-photo"/>')
    parent.el.append(@el)
    @el.on  'click', @zoom

  load: =>
    return if @loaded
    @el.css('backgroundImage', "url(#{@photo.small})")
    @loaded = true

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
