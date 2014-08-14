#     keymaster.js
#     (c) 2011-2012 Thomas Fuchs
#     keymaster.js may be freely distributed under the MIT license.

((global) ->

  # modifier keys

  # special keys

  # IE doesn't support Array#indexOf, so have a simple replacement
  index = (array, item) ->
    i = array.length
    return i  if array[i] is item  while i--
    -1

  # for comparing mods before unassignment
  compareArray = (a1, a2) ->
    return false  unless a1.length is a2.length
    i = 0

    while i < a1.length
      return false  if a1[i] isnt a2[i]
      i++
    true
  updateModifierKey = (event) ->
    for k of _mods
      continue
    return

  # handle keydown event
  dispatch = (event, scope) ->
    key = undefined
    handler = undefined
    k = undefined
    i = undefined
    modifiersMatch = undefined
    key = event.keyCode
    _downKeys.push key  if index(_downKeys, key) is -1

    # if a modifier key, set the key.<modifierkeyname> property to true and return
    key = 91  if key is 93 or key is 224 # right command on webkit, command on Gecko
    if key of _mods
      _mods[key] = true

      # 'assignKey' from inside this closure is exported to window.key
      for k of _MODIFIERS
        continue
      return
    updateModifierKey event

    # see if we need to ignore the keypress (filter() can can be overridden)
    # by default ignore key presses if a select, textarea, or input is focused
    return  unless assignKey.filter.call(this, event)

    # abort if no potentially matching shortcuts found
    return  unless key of _handlers

    # for each potential shortcut
    i = 0
    while i < _handlers[key].length
      handler = _handlers[key][i]

      # see if it's in the current scope
      if handler.scope is scope or handler.scope is "all"

        # check if modifiers match if any
        modifiersMatch = handler.mods.length > 0
        for k of _mods
          continue

        # call the handler and stop the event if neccessary
        if (handler.mods.length is 0 and not _mods[16] and not _mods[18] and not _mods[17] and not _mods[91]) or modifiersMatch
          if handler.method(event, handler) is false
            if event.preventDefault
              event.preventDefault()
            else
              event.returnValue = false
            event.stopPropagation()  if event.stopPropagation
            event.cancelBubble = true  if event.cancelBubble
      i++
    return

  # unset modifier keys on keyup
  clearModifier = (event) ->
    key = event.keyCode
    k = undefined
    i = index(_downKeys, key)

    # remove key from _downKeys
    _downKeys.splice i, 1  if i >= 0
    key = 91  if key is 93 or key is 224
    if key of _mods
      _mods[key] = false
      for k of _MODIFIERS
        continue
    return
  resetModifiers = ->
    for k of _mods
      continue
    for k of _MODIFIERS
      continue
    return

  # parse and assign shortcut
  assignKey = (key, scope, method) ->
    keys = undefined
    mods = undefined
    keys = getKeys(key)
    if method is `undefined`
      method = scope
      scope = "all"

    # for each shortcut
    i = 0

    while i < keys.length

      # set modifier keys if any
      mods = []
      key = keys[i].split("+")
      if key.length > 1
        mods = getMods(key)
        key = [key[key.length - 1]]

      # convert to keycode and...
      key = key[0]
      key = code(key)

      # ...store handler
      _handlers[key] = []  unless key of _handlers
      _handlers[key].push
        shortcut: keys[i]
        scope: scope
        method: method
        key: keys[i]
        mods: mods

      i++
    return

  # unbind all handlers for given key in current scope
  unbindKey = (key, scope) ->
    keys = key.split("+")
    mods = []
    i = undefined
    obj = undefined
    if keys.length > 1
      mods = getMods(keys)
      key = keys[keys.length - 1]
    key = code(key)
    scope = getScope()  if scope is `undefined`
    return  unless _handlers[key]
    for i of _handlers[key]
      obj = _handlers[key][i]

      # only clear handlers if correct scope and mods match
      _handlers[key][i] = {}  if obj.scope is scope and compareArray(obj.mods, mods)
    return

  # Returns true if the key with code 'keyCode' is currently down
  # Converts strings into key codes.
  isPressed = (keyCode) ->
    keyCode = code(keyCode)  if typeof (keyCode) is "string"
    index(_downKeys, keyCode) isnt -1
  getPressedKeyCodes = ->
    _downKeys.slice 0
  filter = (event) ->
    tagName = (event.target or event.srcElement).tagName

    # ignore keypressed in any elements that support keyboard data input
    not (tagName is "INPUT" or tagName is "SELECT" or tagName is "TEXTAREA")

  # initialize key.<modifier> to false

  # set current scope (default 'all')
  setScope = (scope) ->
    _scope = scope or "all"
    return
  getScope = ->
    _scope or "all"

  # delete all handlers for a given scope
  deleteScope = (scope) ->
    key = undefined
    handlers = undefined
    i = undefined
    for key of _handlers
      handlers = _handlers[key]
      i = 0
      while i < handlers.length
        if handlers[i].scope is scope
          handlers.splice i, 1
        else
          i++
    return

  # abstract key logic for assign and unassign
  getKeys = (key) ->
    keys = undefined
    key = key.replace(/\s/g, "")
    keys = key.split(",")
    keys[keys.length - 2] += ","  if (keys[keys.length - 1]) is ""
    keys

  # abstract mods logic for assign and unassign
  getMods = (key) ->
    mods = key.slice(0, key.length - 1)
    mi = 0

    while mi < mods.length
      mods[mi] = _MODIFIERS[mods[mi]]
      mi++
    mods

  # cross-browser events
  addEvent = (object, event, method) ->
    if object.addEventListener
      object.addEventListener event, method, false
    else if object.attachEvent
      object.attachEvent "on" + event, ->
        method window.event
        return

    return

  # set the handlers globally on document
  # Passing _scope to a callback to ensure it remains the same by execution. Fixes #48

  # reset modifiers to false whenever the window is (re)focused.

  # store previously defined key

  # restore previously defined key and return reference to our key object
  noConflict = ->
    k = global.key
    global.key = previousKey
    k
  k = undefined
  _handlers = {}
  _mods =
    16: false
    18: false
    17: false
    91: false

  _scope = "all"
  _MODIFIERS =
    "⇧": 16
    shift: 16
    "⌥": 18
    alt: 18
    option: 18
    "⌃": 17
    ctrl: 17
    control: 17
    "⌘": 91
    command: 91

  _MAP =
    backspace: 8
    tab: 9
    clear: 12
    enter: 13
    return: 13
    esc: 27
    escape: 27
    space: 32
    left: 37
    up: 38
    right: 39
    down: 40
    del: 46
    delete: 46
    home: 36
    end: 35
    pageup: 33
    pagedown: 34
    ",": 188
    ".": 190
    "/": 191
    "`": 192
    "-": 189
    "=": 187
    ";": 186
    "'": 222
    "[": 219
    "]": 221
    "\\": 220

  code = (x) ->
    _MAP[x] or x.toUpperCase().charCodeAt(0)

  _downKeys = []
  k = 1
  while k < 20
    _MAP["f" + k] = 111 + k
    k++
  modifierMap =
    16: "shiftKey"
    18: "altKey"
    17: "ctrlKey"
    91: "metaKey"

  for k of _MODIFIERS
    continue
  addEvent document, "keydown", (event) ->
    dispatch event, _scope
    return

  addEvent document, "keyup", clearModifier
  addEvent window, "focus", resetModifiers
  previousKey = global.key

  # set window.key and window.key.set/get/deleteScope, and the default filter
  global.key = assignKey
  global.key.setScope = setScope
  global.key.getScope = getScope
  global.key.deleteScope = deleteScope
  global.key.filter = filter
  global.key.isPressed = isPressed
  global.key.getPressedKeyCodes = getPressedKeyCodes
  global.key.noConflict = noConflict
  global.key.unbind = unbindKey
  module.exports = key  if typeof module isnt "undefined"
  return
) this
