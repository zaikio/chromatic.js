@Chromatic = @Chromatic or {}

_is_css_blur_supported = (->
  _supported = 'dontknow'
  return ->
    return _supported unless _supported == 'dontknow'
    el = $('<div/>')
    $(document.body).append(el)
    el[0].style.webkitFilter = "grayscale(1)"
    _supported = window.getComputedStyle(el[0]).webkitFilter == "grayscale(1)"
    el.remove()
    return _supported
)()

class Chromatic.ZoomPhotoView
  constructor: (parent, photo, options) ->
    @photo = photo
    @el    = $('<div/>')
    @render()
    parent.el.append(@el)

  remove: (photo) =>
    @el.remove()

  render: =>
    @photo_el      = $('<div class="chromatic-zoom-photo"></div>')
    @grain_el      = $('<div class="chromatic-zoom-grain"></div>')
    @background_el = $('<div class="chromatic-zoom-background"></div>')

    if @photo.big
      big_img        = new Image()
      big_img.onload = => @photo_el.css('backgroundImage', "url(#{@photo.big})")
      big_img.src    = @photo.big
    @photo_el.css('backgroundImage', "url(#{@photo.small})")

    if @photo.blur
      @background_el.css('backgroundImage', "url(#{@photo.blur})")
    else if _is_css_blur_supported()
      @background_el.addClass('chromatic-zoom-background-blur').css('backgroundImage', "url(#{@photo.small})")

    if @photo.desc
      @photo_el.html("<div class=\"chromatic-zoom-desc\">#{@photo.desc}</div>")

    @el.append(@photo_el, @grain_el, @background_el)
    return this

  layout: (pos, offset=0, animated) =>
    container = $(window)

    if container.width() / container.height() > @photo.aspect_ratio
      height = container.height()
      width  = container.height() * @photo.aspect_ratio
    else
      height = container.width() / @photo.aspect_ratio
      width  = container.width()

    @photo_el.css
      height: height
      width:  width
      top:    (container.height() - height) / 2

    left = switch pos
      when 'previous' then -width-20+offset
      when 'current'  then (container.width()-width)/2+offset
      when 'next'     then container.width()+20+offset

    opacity = switch pos
      when 'current'  then 1-Math.abs(offset)/container.width()*2
      when 'previous' then 0+offset/container.width()*2
      when 'next'     then 0-offset/container.width()*2

    if animated
      @photo_el.stop().animate({left: left}, 600, 'easeOutCirc')
      @grain_el.stop().animate({opacity: opacity}, 600, 'easeOutCirc')
      @background_el.stop().animate({opacity: opacity}, 600, 'easeOutCirc')
    else
      @photo_el.css('left', left)
      @grain_el.css('opacity', opacity)
      @background_el.css('opacity', opacity)
