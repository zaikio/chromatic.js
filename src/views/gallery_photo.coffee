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
    src = @photo.src or @photo.small
    image = new Image()
    #console.log(@photo);
    image.onload = =>
      @photo.aspect_ratio = image.width/image.height
      callback() if callback
      @el.css {
        backgroundImage: "url(#{src})"
        backgroundColor: 'transparent'
      }
      #@el.attr('data-test','gijs');

      @loaded = true
    image.src = src

  is_visible: (viewport) =>
    top = @el.offset().top
    bottom = top + @el.height()
    is_visible = (top < viewport.bottom) && (bottom > viewport.top)
    return is_visible

  unload: =>
    @el.css {
      backgroundImage: ''
      backgroundColor: ''
    }
    @loaded = false

  #zoom: =>
    #@parent.zoom(@photo)

  margins: =>
    top: parseInt @el.css('marginTop')
    left: parseInt @el.css('marginLeft')
    bottom: parseInt @el.css('marginBottom')
    right: parseInt @el.css('marginRight')

  resize: (width, height) =>
    @el.css({ width, height })

module.exports = GalleryPhotoView;
