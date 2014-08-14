# Underscore.js 1.6.0
# http://underscorejs.org
# (c) 2009-2014 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
# Underscore may be freely distributed under the MIT license.

if not _?
  @_ = {}

  ArrayProto    = Array.prototype

  nativeForEach = ArrayProto.forEach
  nativeMap     = ArrayProto.map
  nativeReduce  = ArrayProto.reduce
  nativeIsArray = Array.isArray

  _.each = (obj, iterator, context) ->
    try
      if nativeForEach and obj.forEach is nativeForEach
        obj.forEach iterator, context
      else if _.isNumber obj.length
        iterator.call context, obj[i], i, obj for i in [0...obj.length]
      else
        iterator.call context, val, key, obj  for own key, val of obj
    catch e
    obj

  _.map = (obj, iterator, context) ->
    return obj.map(iterator, context) if nativeMap and obj.map is nativeMap
    results = []
    _.each obj, (value, index, list) ->
      results.push iterator.call context, value, index, list
    results

  _.reduce = (obj, iterator, memo, context) ->
    if nativeReduce and obj.reduce is nativeReduce
      iterator = _.bind iterator, context if context
      return obj.reduce iterator, memo
    _.each obj, (value, index, list) ->
      memo = iterator.call context, memo, value, index, list
    memo

  _.isArray = nativeIsArray or (obj) -> !!(obj and obj.concat and obj.unshift and not obj.callee)

  _.max = (obj, iterator, context) ->
    return Math.max.apply(Math, obj) if not iterator and _.isArray(obj)
    result = computed: -Infinity
    _.each obj, (value, index, list) ->
      computed = if iterator then iterator.call(context, value, index, list) else value
      computed >= result.computed and (result = {value: value, computed: computed})
    result.value

  _.min = (obj, iterator, context) ->
    return Math.min.apply(Math, obj) if not iterator and _.isArray(obj)
    result = computed: Infinity
    _.each obj, (value, index, list) ->
      computed = if iterator then iterator.call(context, value, index, list) else value
      computed < result.computed and (result = {value: value, computed: computed})
    result.value

  _.now = Date.now or -> new Date().getTime()

  _.throttle = (func, wait, options) ->
    context = undefined
    args = undefined
    result = undefined
    timeout = null
    previous = 0
    options or (options = {})
    later = ->
      previous = (if options.leading is false then 0 else _.now())
      timeout = null
      result = func.apply(context, args)
      context = args = null
      return

    ->
      now = _.now()
      previous = now  if not previous and options.leading is false
      remaining = wait - (now - previous)
      context = this
      args = arguments
      if remaining <= 0
        clearTimeout timeout
        timeout = null
        previous = now
        result = func.apply(context, args)
        context = args = null
      else timeout = setTimeout(later, remaining)  if not timeout and options.trailing isnt false
      result

  _.debounce = (func, wait, immediate) ->
    timeout = undefined
    args = undefined
    context = undefined
    timestamp = undefined
    result = undefined
    later = ->
      last = _.now() - timestamp
      if last < wait
        timeout = setTimeout(later, wait - last)
      else
        timeout = null
        unless immediate
          result = func.apply(context, args)
          context = args = null
      return

    ->
      context = this
      args = arguments
      timestamp = _.now()
      callNow = immediate and not timeout
      timeout = setTimeout(later, wait)  unless timeout
      if callNow
        result = func.apply(context, args)
        context = args = null
      result
