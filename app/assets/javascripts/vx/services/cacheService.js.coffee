Vx.service "cacheService", ['$q', '$cacheFactory'
  ($q, $cacheFactory) ->

    (cacheId) ->

      cache = $cacheFactory(cacheId, 5)

      reject = (value) ->
        d = $q.defer()
        d.reject(value)
        d.promise

      resolve = (value) ->
        d = $q.defer()
        d.resolve value
        d.promise

      #########################################################################

      fetch: (key, fn) ->
        if val = cache.get(key)
          resolve val
        else
          if fn
            fn().then (data) ->
              cache.put(key, data)
              data
          else
            reject "key #{key} missing"

      updateAll: (key,  attributes) ->
        if collection = cache.get(key)
          angular.forEach collection, (it) ->
            if it.id == attributes.id
              angular.extend it, attributes

      updateOne: (key, attributes) ->
        if object = cache.get(key)
          angular.extend object, attributes

      removeAll: (key, objectId) ->
        if collection = cache.get(key)
          ids = collection.map (it) -> it.id
          idx = ids.indexOf(objectId)
          if idx != -1
            collection.splice(idx, 1)

      removeKey: (key) ->
        cache.remove(key)

      truncate: (key) ->
        if key = cache.get(key)
          key.length = 0

      push: (key, objects) ->
        if it = cache.get(key)
          if angular.isArray(objects)
            it.push.apply(it, objects)
          else
            it.push objects

      unshift: (key, objects) ->
        if it = cache.get(key)
          it.unshift objects
]
