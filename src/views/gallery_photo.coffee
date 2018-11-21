createPhotoElement = (photo, { className = 'chromatic-gallery-photo' }) =>
  element = $('<div/>').addClass(className)

  for key,value of (photo.attributes or {})
    element.attr(key,value);

  return element

class GalleryPhotoView
  constructor: (gallery, photo, options = {}) ->
    @gallery = gallery
    @photo   = photo
    @el      = (options.createPhotoElement or createPhotoElement)(photo, options, createPhotoElement)

    gallery.el.append(@el)

    if options.onClick
      @el.on 'click', (event) -> options.onClick.call(this, event, photo)

  load: (callback) =>
    return if @loaded
    image = new Image()
    #console.log(@photo);
    image.onload = =>
      @photo.aspect_ratio = image.width/image.height
      callback() if callback
      @el.css {
        backgroundImage: "url(#{@photo.small})"
        backgroundColor: 'transparent'
      }
      #@el.attr('data-test','gijs');

      @loaded = true
    image.src = @photo.small

  unload: =>
    @el.css {
      backgroundImage: ''
      backgroundColor: ''
    }
    @loaded = false

  #zoom: =>
    #@parent.zoom(@photo)

  resize: (width, height) ->
    @el.css
      width: width - parseInt(@el.css('marginLeft')) - parseInt(@el.css('marginRight'))
      height: height - parseInt(@el.css('marginTop')) - parseInt(@el.css('marginBottom'))
    @top = @el.offset().top
    @bottom = @top + @el.height()

module.exports = GalleryPhotoView;
