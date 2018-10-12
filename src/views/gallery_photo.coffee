@Chromatic = @Chromatic or {}

class @Chromatic.GalleryPhotoView
  constructor: (parent, photo, options) ->
    @parent = parent
    @photo  = photo
    @el     = $('<div class="chromatic-gallery-photo"/>')
    for key,value of @photo
      #only pass in mfp and data elements
      if ( ( key.lastIndexOf("data", 0) == 0 ) || ( key.lastIndexOf("mfp", 0) == 0 ) || ( key.lastIndexOf("id", 0) == 0 ) )
        @el.attr(key,value);

    parent.el.append(@el)
    #@el.on  'click', @zoom

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
