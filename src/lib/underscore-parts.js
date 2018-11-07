var ArrayProto, nativeForEach, nativeIsArray, nativeMap, nativeReduce,
  __hasProp = {}.hasOwnProperty;

_ = {};

ArrayProto = Array.prototype;
nativeForEach = ArrayProto.forEach;
nativeMap = ArrayProto.map;
nativeReduce = ArrayProto.reduce;
nativeIsArray = Array.isArray;

_.isObject = function(obj) {
  var type;
  type = typeof obj;
  return type === "function" || type === "object" && !!obj;
};
_.after = function(times, func) {
  return function() {
    if (--times < 1) {
      return func.apply(this, arguments);
    }
  };
};
_.each = function(obj, iterator, context) {
  var e, i, key, val, _i, _ref;
  try {
    if (nativeForEach && obj.forEach === nativeForEach) {
      obj.forEach(iterator, context);
    } else if (_.isNumber(obj.length)) {
      for (i = _i = 0, _ref = obj.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        iterator.call(context, obj[i], i, obj);
      }
    } else {
      for (key in obj) {
        if (!__hasProp.call(obj, key)) continue;
        val = obj[key];
        iterator.call(context, val, key, obj);
      }
    }
  } catch (_error) {
    e = _error;
  }
  return obj;
};
_.map = function(obj, iterator, context) {
  var results;
  if (nativeMap && obj.map === nativeMap) {
    return obj.map(iterator, context);
  }
  results = [];
  _.each(obj, function(value, index, list) {
    return results.push(iterator.call(context, value, index, list));
  });
  return results;
};
_.reduce = function(obj, iterator, memo, context) {
  if (nativeReduce && obj.reduce === nativeReduce) {
    if (context) {
      iterator = _.bind(iterator, context);
    }
    return obj.reduce(iterator, memo);
  }
  _.each(obj, function(value, index, list) {
    return memo = iterator.call(context, memo, value, index, list);
  });
  return memo;
};
_.isArray = nativeIsArray || function(obj) {
  return !!(obj && obj.concat && obj.unshift && !obj.callee);
};
_.max = function(obj, iterator, context) {
  var result;
  if (!iterator && _.isArray(obj)) {
    return Math.max.apply(Math, obj);
  }
  result = {
    computed: -Infinity
  };
  _.each(obj, function(value, index, list) {
    var computed;
    computed = iterator ? iterator.call(context, value, index, list) : value;
    return computed >= result.computed && (result = {
      value: value,
      computed: computed
    });
  });
  return result.value;
};
_.min = function(obj, iterator, context) {
  var result;
  if (!iterator && _.isArray(obj)) {
    return Math.min.apply(Math, obj);
  }
  result = {
    computed: Infinity
  };
  _.each(obj, function(value, index, list) {
    var computed;
    computed = iterator ? iterator.call(context, value, index, list) : value;
    return computed < result.computed && (result = {
      value: value,
      computed: computed
    });
  });
  return result.value;
};
_.now = Date.now || function() {
  return new Date().getTime();
};
_.throttle = function(func, wait, options) {
  var args, context, later, previous, result, timeout;
  context = void 0;
  args = void 0;
  result = void 0;
  timeout = null;
  previous = 0;
  options || (options = {});
  later = function() {
    previous = (options.leading === false ? 0 : _.now());
    timeout = null;
    result = func.apply(context, args);
    context = args = null;
  };
  return function() {
    var now, remaining;
    now = _.now();
    if (!previous && options.leading === false) {
      previous = now;
    }
    remaining = wait - (now - previous);
    context = this;
    args = arguments;
    if (remaining <= 0) {
      clearTimeout(timeout);
      timeout = null;
      previous = now;
      result = func.apply(context, args);
      context = args = null;
    } else {
      if (!timeout && options.trailing !== false) {
        timeout = setTimeout(later, remaining);
      }
    }
    return result;
  };
};
_.debounce = function(func, wait, immediate) {
  var args, context, later, result, timeout, timestamp;
  timeout = void 0;
  args = void 0;
  context = void 0;
  timestamp = void 0;
  result = void 0;
  later = function() {
    var last;
    last = _.now() - timestamp;
    if (last < wait) {
      timeout = setTimeout(later, wait - last);
    } else {
      timeout = null;
      if (!immediate) {
        result = func.apply(context, args);
        context = args = null;
      }
    }
  };
  return function() {
    var callNow;
    context = this;
    args = arguments;
    timestamp = _.now();
    callNow = immediate && !timeout;
    if (!timeout) {
      timeout = setTimeout(later, wait);
    }
    if (callNow) {
      result = func.apply(context, args);
      context = args = null;
    }
    return result;
  };
};

module.exports = _;
