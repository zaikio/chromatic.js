# jQuery.event.swipe
# 0.5
# Stephen Band

# Dependencies
# jQuery.event.move 1.2

# One of swipeleft, swiperight, swipeup or swipedown is triggered on
# moveend, when the move has covered a threshold ratio of the dimension
# of the target node, or has gone really fast. Threshold and velocity
# sensitivity changed with:
#
# jQuery.event.special.swipe.settings.threshold
# jQuery.event.special.swipe.settings.sensitivity
((module) ->
  if typeof define is "function" and define.amd

    # AMD. Register as an anonymous module.
    define ["jquery"], module
  else

    # Browser globals
    module jQuery
  return
) (jQuery, undefined_) ->

  # Just sugar, so we can have arguments in the same order as
  # add and remove.

  # Ratio of distance over target finger must travel to be
  # considered a swipe.

  # Faster fingers can travel shorter distances to be considered
  # swipes. 'sensitivity' controls how much. Bigger is shorter.
  moveend = (e) ->
    w = undefined
    h = undefined
    event = undefined
    w = e.target.offsetWidth
    h = e.target.offsetHeight

    # Copy over some useful properties from the move event
    event =
      distX: e.distX
      distY: e.distY
      velocityX: e.velocityX
      velocityY: e.velocityY
      finger: e.finger

    event.type = "swipecanceled"

    # Find out which of the four directions was swiped
    if e.distX > e.distY
      if e.distX > -e.distY
        event.type = "swiperight"  if e.distX / w > settings.threshold or e.velocityX * e.distX / w * settings.sensitivity > 1
      else
        event.type = "swipeup"  if -e.distY / h > settings.threshold or e.velocityY * e.distY / w * settings.sensitivity > 1
    else
      if e.distX > -e.distY
        event.type = "swipedown"  if e.distY / h > settings.threshold or e.velocityY * e.distY / w * settings.sensitivity > 1
      else
        event.type = "swipeleft"  if -e.distX / w > settings.threshold or e.velocityX * e.distX / w * settings.sensitivity > 1
    trigger e.currentTarget, event
    return
  getData = (node) ->
    data = jQuery.data(node, "event_swipe")
    unless data
      data = count: 0
      jQuery.data node, "event_swipe", data
    data
  add = jQuery.event.add
  remove = jQuery.event.remove
  trigger = (node, type, data) ->
    jQuery.event.trigger type, data, node
    return

  settings =
    threshold: 0.4
    sensitivity: 6

  jQuery.event.special.swipe = jQuery.event.special.swipeleft = jQuery.event.special.swiperight = jQuery.event.special.swipeup = jQuery.event.special.swipedown =
    setup: (data, namespaces, eventHandle) ->
      data = getData(this)

      # If another swipe event is already setup, don't setup again.
      return  if data.count++ > 0
      add this, "moveend", moveend
      true

    teardown: ->
      data = getData(this)

      # If another swipe event is still setup, don't teardown.
      return  if --data.count > 0
      remove this, "moveend", moveend
      true

    settings: settings

  return
