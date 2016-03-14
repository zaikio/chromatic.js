@Chromatic = @Chromatic or {}

# Extend jquery with easeOut transition (loading jquery UI would be overkill)
$.extend $.easing,
  easeOutCirc: (x, t, b, c, d) ->
    return c * Math.sqrt(1 - (t=t/d-1)*t) + b

jQuery.event.special.swipe.settings.sensitivity = 100

class Chromatic.ZoomView
  constructor: (photos, options) ->
    @el = $('<div class="chromatic-zoom"/>')
    @el.html("<div class=\"chromatic-zoom-arrow-left\"></div><div class=\"chromatic-zoom-arrow-right\"></div><div class=\"chromatic-zoom-arrow-up\"></div>")
    @descVis = false
    @photos = photos
    $(document.body).append(@el)
    @el.hide()
      .on('click', @close)
      .on('mousemove mouseenter', @showArrows)
      .on('mouseleave', @hideArrows)
      .on('click', '.chromatic-zoom-arrow-left', @showPrevious)
      .on('swiperight', @showPrevious)
      .on('click', '.chromatic-zoom-arrow-right', @showNext)
      .on('swipeleft', @showNext)
      .on('click', '.chromatic-zoom-arrow-up', @showInfo)
      .on('swipeup', @showInfo)
      .on('click', '.chromatic-zoom-arrow-down', @hideInfo)
      .on('swipedown', @hideInfo)
      .on('move', @move) # FIXME
      .on('swipecanceled', @cancel)
    @_debouncedLayout = _.debounce((=> @layout()), 100)

  close: =>
    $(document.body).css('overflowY', 'auto')
    clearTimeout(@arrows_timer)
    key.unbind 'esc'; key.unbind 'enter'; key.unbind 'up'; key.unbind 'down'; key.unbind 'left'; key.unbind 'j'; key.unbind 'right'; key.unbind 'k'; # doesnt support multiple keys
    # $(window).off 'resize orientationchange', @_debouncedLayout
    @el.fadeOut 500, =>
      @previous_zoom_photo_view.remove()
      @current_zoom_photo_view.remove()
      @next_zoom_photo_view.remove()
      @previous_zoom_photo_view = null
      @current_zoom_photo_view  = null
      @next_zoom_photo_view     = null

  show: (photo) =>
    $(document.body).css('overflowY', 'hidden') # prevent translucent scrollbars
    key 'esc, enter', @close
    key 'left, k',        _.debounce(@showPrevious, 100, true)
    key 'right, j',       _.debounce(@showNext, 100, true)
    key 'up',       _.debounce(@showInfo, 100, true)
    key 'down',       _.debounce(@hideInfo, 100, true)
    $(window).on 'resize orientationchange', @_debouncedLayout
    @hideArrows(false)
    @el.fadeIn(500)

    @previous_zoom_photo_view.remove() if @previous_zoom_photo_view
    @current_zoom_photo_view.remove()  if @current_zoom_photo_view
    @next_zoom_photo_view.remove()     if @next_zoom_photo_view
    previous  = @photos[@photos.indexOf(photo) - 1] || @photos[@photos.length-1]
    @current  = photo
    next      = @photos[@photos.indexOf(photo) + 1] || @photos[0]
    @previous_zoom_photo_view = new Chromatic.ZoomPhotoView(this, previous, @descVis)
    @current_zoom_photo_view  = new Chromatic.ZoomPhotoView(this, @current, @descVis)
    @next_zoom_photo_view     = new Chromatic.ZoomPhotoView(this, next, @descVis)
    @layout()
    @el.show()

  showNext: (e) =>
    if e
      e.preventDefault()
      e.stopPropagation()
      if e.type == "keydown" then @hideArrows() else @showArrows()
    @previous_zoom_photo_view.remove()
    @previous_zoom_photo_view = null
    @previous_zoom_photo_view = @current_zoom_photo_view
    @current_zoom_photo_view  = @next_zoom_photo_view
    @current  = @photos[@photos.indexOf(@current) + 1] || @photos[0]
    next      = @photos[@photos.indexOf(@current) + 1] || @photos[0]
    @next_zoom_photo_view = new Chromatic.ZoomPhotoView(this, next)
    @previous_zoom_photo_view.layout('previous', 0, true, @descVis)
    @current_zoom_photo_view.layout('current', 0, true, @descVis)
    @next_zoom_photo_view.layout('next', 0, false, @descVis)

  showPrevious: (e) =>
    if e
      e.preventDefault()
      e.stopPropagation()
      if e.type == "keydown" then @hideArrows() else @showArrows()
    @next_zoom_photo_view.remove()
    @next_zoom_photo_view = null
    @next_zoom_photo_view = @current_zoom_photo_view
    @current_zoom_photo_view = @previous_zoom_photo_view
    @current  = @photos[@photos.indexOf(@current) - 1] || @photos[@photos.length-1]
    previous  = @photos[@photos.indexOf(@current) - 1] || @photos[@photos.length-1]
    @previous_zoom_photo_view = new Chromatic.ZoomPhotoView(this, previous)
    @next_zoom_photo_view.layout('next', 0, true, @descVis)
    @current_zoom_photo_view.layout('current', 0, true, @descVis)
    @previous_zoom_photo_view.layout('previous', 0, false, @descVis)

  showInfo: (e) =>
    if e
       e.preventDefault()
       e.stopPropagation()
       if e.type == "keydown" then @hideArrows() else @showArrows()
    @el.find(".chromatic-zoom-arrow-up").removeClass('chromatic-zoom-arrow-up').addClass('chromatic-zoom-arrow-down')
    @descVis = true
    description = @el.find(".chromatic-zoom-desc")
    if description
      description.animate({opacity: 0.7}, 200)

  hideInfo: (e) =>
    if e
       e.preventDefault()
       e.stopPropagation()
       if e.type == "keydown" then @hideArrows() else @showArrows()
    @el.find(".chromatic-zoom-arrow-down").removeClass('chromatic-zoom-arrow-down').addClass('chromatic-zoom-arrow-up')
    @descVis = false
    description = @el.find(".chromatic-zoom-desc")
    if description
      description.animate({opacity: 0.01}, 200)

  showArrows: =>
    @el.find(".chromatic-zoom-arrow-left, .chromatic-zoom-arrow-right, .chromatic-zoom-arrow-up, .chromatic-zoom-arrow-down").stop().animate({opacity: 1}, 200)
    clearTimeout(@arrows_timer)
    @arrows_timer = window.setTimeout((=> @hideArrows(true)), 3000)

  hideArrows: (animated) =>
    @el.find(".chromatic-zoom-arrow-left, .chromatic-zoom-arrow-right, .chromatic-zoom-arrow-up, .chromatic-zoom-arrow-down").animate({opacity: 0.01}, animated ? 1000 : 0) # still clickable

  layout: (offset=0, animated, descVis) =>
    @current_zoom_photo_view.layout('current', offset, animated, @descVis)
    @previous_zoom_photo_view.layout('previous', offset, animated, @descVis)
    @next_zoom_photo_view.layout('next', offset, animated, @descVis)

  # Swipe
  move: (e) => @layout(e.distX, false)
  cancel: (e) => @layout(0, true)
