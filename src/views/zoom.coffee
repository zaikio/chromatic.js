@Chromatic = @Chromatic or {}

# Extend jquery with easeOut transition (loading jquery UI would be overkill)
$.extend $.easing,
  easeOutCirc: (x, t, b, c, d) ->
    return c * Math.sqrt(1 - (t=t/d-1)*t) + b

jQuery.event.special.swipe.settings.sensitivity = 100

class Chromatic.ZoomView
  constructor: (photos, options) ->
    @el = $('<div class="chromatic-zoom"/>')
    @el.html("<div class=\"chromatic-zoom-arrow-left\"></div><div class=\"chromatic-zoom-arrow-right\"></div>")
    @photos = photos
    $(document.body).append(@el)
    @el.hide()
      .on('click swipeup', @close)
      .on('mousemove mouseenter', @showArrows)
      .on('mouseleave', @hideArrows)
      .on('click', '.chromatic-zoom-arrow-left', @showPrevious)
      .on('swiperight', @showPrevious)
      .on('click', '.chromatic-zoom-arrow-right', @showNext)
      .on('swipeleft', @showNext)
      .on('move', @move) # FIXME
      .on('swipecanceled', @cancel)
    @_debouncedLayout = _.debounce((=> @layout()), 100)

  close: =>
    $(document.body).css('overflowY', 'auto')
    clearTimeout(@arrows_timer)
    key.unbind 'esc'; key.unbind 'enter'; key.unbind 'up'; key.unbind 'left'; key.unbind 'j'; key.unbind 'right'; key.unbind 'k'; # doesnt support multiple keys
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
    key 'esc, enter, up', @close
    key 'left, k',        _.debounce(@showPrevious, 100, true)
    key 'right, j',       _.debounce(@showNext, 100, true)
    $(window).on 'resize orientationchange', @_debouncedLayout
    @hideArrows(false)
    @el.fadeIn(500)

    @previous_zoom_photo_view.remove() if @previous_zoom_photo_view
    @current_zoom_photo_view.remove()  if @current_zoom_photo_view
    @next_zoom_photo_view.remove()     if @next_zoom_photo_view
    previous  = @photos[@photos.indexOf(photo) - 1] || @photos[@photos.length-1]
    @current  = photo
    next      = @photos[@photos.indexOf(photo) + 1] || @photos[0]
    @previous_zoom_photo_view = new Chromatic.ZoomPhotoView(this, previous)
    @current_zoom_photo_view  = new Chromatic.ZoomPhotoView(this, @current)
    @next_zoom_photo_view     = new Chromatic.ZoomPhotoView(this, next)
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
    @previous_zoom_photo_view.layout('previous', 0, true)
    @current_zoom_photo_view.layout('current', 0, true)
    @next_zoom_photo_view.layout('next', 0, false)

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
    @next_zoom_photo_view.layout('next', 0, true)
    @current_zoom_photo_view.layout('current', 0, true)
    @previous_zoom_photo_view.layout('previous', 0, false)

  showArrows: =>
    @el.find(".chromatic-zoom-arrow-left, .chromatic-zoom-arrow-right").stop().animate({opacity: 1}, 200)
    clearTimeout(@arrows_timer)
    @arrows_timer = window.setTimeout((=> @hideArrows(true)), 3000)

  hideArrows: (animated) =>
    @el.find(".chromatic-zoom-arrow-left, .chromatic-zoom-arrow-right").animate({opacity: 0.01}, animated ? 1000 : 0) # still clickable

  layout: (offset=0, animated) =>
    @current_zoom_photo_view.layout('current', offset, animated)
    @previous_zoom_photo_view.layout('previous', offset, animated)
    @next_zoom_photo_view.layout('next', offset, animated)

  # Swipe
  move: (e) => @layout(e.distX, false)
  cancel: (e) => @layout(0, true)
