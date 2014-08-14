# jquery.event.move
#
# 1.3.1
#
# Stephen Band
#
# Triggers 'movestart', 'move' and 'moveend' events after
# mousemoves following a mousedown cross a distance threshold,
# similar to the native 'dragstart', 'drag' and 'dragend' events.
# Move events are throttled to animation frames. Move event objects
# have the properties:
#
# pageX:
# pageY:   Page coordinates of pointer.
# startX:
# startY:  Page coordinates of pointer at movestart.
# distX:
# distY:  Distance the pointer has moved since movestart.
# deltaX:
# deltaY:  Distance the finger has moved since last event.
# velocityX:
# velocityY:  Average velocity over last few events.


((module) ->
  if typeof define is "function" and define.amd

    # AMD. Register as an anonymous module.
    define ["jquery"], module
  else

    # Browser globals
    module jQuery
  return
) (jQuery, undefined_) ->
  # Number of pixels a pressed pointer travels before movestart
  # event is fired.

  # Just sugar, so we can have arguments in the same order as
  # add and remove.

  # Shim for requestAnimationFrame, falling back to timer. See:
  # see http:#paulirish.com/2011/requestanimationframe-for-smart-animating/

  # Constructors
  Timer = (fn) ->
    trigger = (time) ->
      if active
        callback()
        requestFrame trigger
        running = true
        active = false
      else
        running = false
      return
    callback = fn
    active = false
    running = false
    @kick = (fn) ->
      active = true
      trigger()  unless running
      return

    @end = (fn) ->
      cb = callback
      return  unless fn

      # If the timer is not running, simply call the end callback.
      unless running
        fn()

      # If the timer is running, and has been kicked lately, then
      # queue up the current callback and the end callback, otherwise
      # just the end callback.
      else
        callback = (if active then ->
          cb()
          fn()
          return
         else fn)
        active = true
      return

    return

  # Functions
  returnTrue = ->
    true
  returnFalse = ->
    false
  preventDefault = (e) ->
    e.preventDefault()
    return
  preventIgnoreTags = (e) ->

    # Don't prevent interaction with form elements.
    return  if ignoreTags[e.target.tagName.toLowerCase()]
    e.preventDefault()
    return
  isLeftButton = (e) ->

    # Ignore mousedowns on any button other than the left (or primary)
    # mouse button, or when a modifier key is pressed.
    e.which is 1 and not e.ctrlKey and not e.altKey
  identifiedTouch = (touchList, id) ->
    i = undefined
    l = undefined
    return touchList.identifiedTouch(id)  if touchList.identifiedTouch

    # touchList.identifiedTouch() does not exist in
    # webkit yet… we must do the search ourselves...
    i = -1
    l = touchList.length
    return touchList[i]  if touchList[i].identifier is id  while ++i < l
    return
  changedTouch = (e, event) ->
    touch = identifiedTouch(e.changedTouches, event.identifier)

    # This isn't the touch you're looking for.
    return  unless touch

    # Chrome Android (at least) includes touches that have not
    # changed in e.changedTouches. That's a bit annoying. Check
    # that this touch has changed.
    return  if touch.pageX is event.pageX and touch.pageY is event.pageY
    touch

  # Handlers that decide when the first movestart is triggered
  mousedown = (e) ->
    data = undefined
    return  unless isLeftButton(e)
    data =
      target: e.target
      startX: e.pageX
      startY: e.pageY
      timeStamp: e.timeStamp

    add document, mouseevents.move, mousemove, data
    add document, mouseevents.cancel, mouseend, data
    return
  mousemove = (e) ->
    data = e.data
    checkThreshold e, data, e, removeMouse
    return
  mouseend = (e) ->
    removeMouse()
    return
  removeMouse = ->
    remove document, mouseevents.move, mousemove
    remove document, mouseevents.cancel, mouseend
    return
  touchstart = (e) ->
    touch = undefined
    template = undefined

    # Don't get in the way of interaction with form elements.
    return  if ignoreTags[e.target.tagName.toLowerCase()]
    touch = e.changedTouches[0]

    # iOS live updates the touch objects whereas Android gives us copies.
    # That means we can't trust the touchstart object to stay the same,
    # so we must copy the data. This object acts as a template for
    # movestart, move and moveend event objects.
    template =
      target: touch.target
      startX: touch.pageX
      startY: touch.pageY
      timeStamp: e.timeStamp
      identifier: touch.identifier


    # Use the touch identifier as a namespace, so that we can later
    # remove handlers pertaining only to this touch.
    add document, touchevents.move + "." + touch.identifier, touchmove, template
    add document, touchevents.cancel + "." + touch.identifier, touchend, template
    return
  touchmove = (e) ->
    data = e.data
    touch = changedTouch(e, data)
    return  unless touch
    checkThreshold e, data, touch, removeTouch
    return
  touchend = (e) ->
    template = e.data
    touch = identifiedTouch(e.changedTouches, template.identifier)
    return  unless touch
    removeTouch template.identifier
    return
  removeTouch = (identifier) ->
    remove document, "." + identifier, touchmove
    remove document, "." + identifier, touchend
    return

  # Logic for deciding when to trigger a movestart.
  checkThreshold = (e, template, touch, fn) ->
    distX = touch.pageX - template.startX
    distY = touch.pageY - template.startY

    # Do nothing if the threshold has not been crossed.
    return  if (distX * distX) + (distY * distY) < (threshold * threshold)
    triggerStart e, template, touch, distX, distY, fn
    return
  handled = ->

    # this._handled should return false once, and after return true.
    @_handled = returnTrue
    false
  flagAsHandled = (e) ->
    e._handled()
    return
  triggerStart = (e, template, touch, distX, distY, fn) ->
    node = template.target
    touches = undefined
    time = undefined
    touches = e.targetTouches
    time = e.timeStamp - template.timeStamp

    # Create a movestart object with some special properties that
    # are passed only to the movestart handlers.
    template.type = "movestart"
    template.distX = distX
    template.distY = distY
    template.deltaX = distX
    template.deltaY = distY
    template.pageX = touch.pageX
    template.pageY = touch.pageY
    template.velocityX = distX / time
    template.velocityY = distY / time
    template.targetTouches = touches
    template.finger = (if touches then touches.length else 1)

    # The _handled method is fired to tell the default movestart
    # handler that one of the move events is bound.
    template._handled = handled

    # Pass the touchmove event so it can be prevented if or when
    # movestart is handled.
    template._preventTouchmoveDefault = ->
      e.preventDefault()
      return


    # Trigger the movestart event.
    trigger template.target, template

    # Unbind handlers that tracked the touch or mouse up till now.
    fn template.identifier
    return

  # Handlers that control what happens following a movestart
  activeMousemove = (e) ->
    event = e.data.event
    timer = e.data.timer
    updateEvent event, e, e.timeStamp, timer
    return
  activeMouseend = (e) ->
    event = e.data.event
    timer = e.data.timer
    removeActiveMouse()
    endEvent event, timer, ->

      # Unbind the click suppressor, waiting until after mouseup
      # has been handled.
      setTimeout (->
        remove event.target, "click", returnFalse
        return
      ), 0
      return

    return
  removeActiveMouse = (event) ->
    remove document, mouseevents.move, activeMousemove
    remove document, mouseevents.end, activeMouseend
    return
  activeTouchmove = (e) ->
    event = e.data.event
    timer = e.data.timer
    touch = changedTouch(e, event)
    return  unless touch

    # Stop the interface from gesturing
    e.preventDefault()
    event.targetTouches = e.targetTouches
    updateEvent event, touch, e.timeStamp, timer
    return
  activeTouchend = (e) ->
    event = e.data.event
    timer = e.data.timer
    touch = identifiedTouch(e.changedTouches, event.identifier)

    # This isn't the touch you're looking for.
    return  unless touch
    removeActiveTouch event
    endEvent event, timer
    return
  removeActiveTouch = (event) ->
    remove document, "." + event.identifier, activeTouchmove
    remove document, "." + event.identifier, activeTouchend
    return

  # Logic for triggering move and moveend events
  updateEvent = (event, touch, timeStamp, timer) ->
    time = timeStamp - event.timeStamp
    event.type = "move"
    event.distX = touch.pageX - event.startX
    event.distY = touch.pageY - event.startY
    event.deltaX = touch.pageX - event.pageX
    event.deltaY = touch.pageY - event.pageY

    # Average the velocity of the last few events using a decay
    # curve to even out spurious jumps in values.
    event.velocityX = 0.3 * event.velocityX + 0.7 * event.deltaX / time
    event.velocityY = 0.3 * event.velocityY + 0.7 * event.deltaY / time
    event.pageX = touch.pageX
    event.pageY = touch.pageY
    timer.kick()
    return
  endEvent = (event, timer, fn) ->
    timer.end ->
      event.type = "moveend"
      trigger event.target, event
      fn and fn()

    return

  # jQuery special event definition
  setup = (data, namespaces, eventHandle) ->

    # Stop the node from being dragged
    #add(this, 'dragstart.move drag.move', preventDefault);

    # Prevent text selection and touch interface scrolling
    #add(this, 'mousedown.move', preventIgnoreTags);

    # Tell movestart default handler that we've handled this
    add this, "movestart.move", flagAsHandled

    # Don't bind to the DOM. For speed.
    true
  teardown = (namespaces) ->
    remove this, "dragstart drag", preventDefault
    remove this, "mousedown touchstart", preventIgnoreTags
    remove this, "movestart", flagAsHandled

    # Don't bind to the DOM. For speed.
    true
  addMethod = (handleObj) ->

    # We're not interested in preventing defaults for handlers that
    # come from internal move or moveend bindings
    return  if handleObj.namespace is "move" or handleObj.namespace is "moveend"

    # Stop the node from being dragged
    add this, "dragstart." + handleObj.guid + " drag." + handleObj.guid, preventDefault, `undefined`, handleObj.selector

    # Prevent text selection and touch interface scrolling
    add this, "mousedown." + handleObj.guid, preventIgnoreTags, `undefined`, handleObj.selector
    return
  removeMethod = (handleObj) ->
    return  if handleObj.namespace is "move" or handleObj.namespace is "moveend"
    remove this, "dragstart." + handleObj.guid + " drag." + handleObj.guid
    remove this, "mousedown." + handleObj.guid
    return
  threshold = 6
  add = jQuery.event.add
  remove = jQuery.event.remove
  trigger = (node, type, data) ->
    jQuery.event.trigger type, data, node
    return

  requestFrame = (->
    window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (fn, element) ->
      window.setTimeout (->
        fn()
        return
      ), 25
  )()
  ignoreTags =
    textarea: true
    input: true
    select: true
    button: true

  mouseevents =
    move: "mousemove"
    cancel: "mouseup dragstart"
    end: "mouseup"

  touchevents =
    move: "touchmove"
    cancel: "touchend"
    end: "touchend"

  jQuery.event.special.movestart =
    setup: setup
    teardown: teardown
    add: addMethod
    remove: removeMethod
    _default: (e) ->
      template = undefined
      data = undefined

      # If no move events were bound to any ancestors of this
      # target, high tail it out of here.
      return  unless e._handled()
      template =
        target: e.target
        startX: e.startX
        startY: e.startY
        pageX: e.pageX
        pageY: e.pageY
        distX: e.distX
        distY: e.distY
        deltaX: e.deltaX
        deltaY: e.deltaY
        velocityX: e.velocityX
        velocityY: e.velocityY
        timeStamp: e.timeStamp
        identifier: e.identifier
        targetTouches: e.targetTouches
        finger: e.finger

      data =
        event: template
        timer: new Timer((time) ->
          trigger e.target, template
          return
        )

      if e.identifier is `undefined`

        # We're dealing with a mouse
        # Stop clicks from propagating during a move
        add e.target, "click", returnFalse
        add document, mouseevents.move, activeMousemove, data
        add document, mouseevents.end, activeMouseend, data
      else

        # We're dealing with a touch. Stop touchmove doing
        # anything defaulty.
        e._preventTouchmoveDefault()
        add document, touchevents.move + "." + e.identifier, activeTouchmove, data
        add document, touchevents.end + "." + e.identifier, activeTouchend, data
      return

  jQuery.event.special.move =
    setup: ->

      # Bind a noop to movestart. Why? It's the movestart
      # setup that decides whether other move events are fired.
      add this, "movestart.move", jQuery.noop
      return

    teardown: ->
      remove this, "movestart.move", jQuery.noop
      return

  jQuery.event.special.moveend =
    setup: ->

      # Bind a noop to movestart. Why? It's the movestart
      # setup that decides whether other move events are fired.
      add this, "movestart.moveend", jQuery.noop
      return

    teardown: ->
      remove this, "movestart.moveend", jQuery.noop
      return

  add document, "mousedown.move", mousedown
  add document, "touchstart.move", touchstart

  # Make jQuery copy touch event properties over to the jQuery event
  # object, if they are not already listed. But only do the ones we
  # really need. IE7/8 do not have Array#indexOf(), but nor do they
  # have touch events, so let's assume we can ignore them.
  if typeof Array::indexOf is "function"
    ((jQuery, undefined_) ->
      props = [
        "changedTouches"
        "targetTouches"
      ]
      l = props.length
      jQuery.event.props.push props[l]  if jQuery.event.props.indexOf(props[l]) is -1  while l--
      return
    ) jQuery
  return
