angular.module('CI').
  factory "cacheStore", ($q, $cacheFactory) ->

    (collectionLimit = 2, itemsLimit = 2) ->

      collectionsCache = $cacheFactory('collections', capacity: collectionLimit)
      itemsCache       = $cacheFactory('items', capacity: itemsLimit)

      addTo = (id, values, cache) ->
        id = id.toString()
        if values.then
          values.then (its) ->
            cache.put id, its
            its
        else
          d = $q.defer()
          cache.put id, values
          d.resolve values
          d.promise

      getFrom = (id, f, cache) ->
        id = id.toString()
        value = cache.get(id)
        if value
          d = $q.defer()
          d.resolve value
          d.promise
        else
          if f
            addTo id, f(), cache
          else
            d = $q.defer()
            d.reject id
            d.promise

      addItemToCollection = (id, value) ->
        getFrom(id, null, collectionsCache).then (its) ->
          if value.then
            value.then (it) ->
              its.push it
              it
          else
            d = $q.defer()
            its.push value
            d.resolve value
            d.promise

      findInCollections = (id, f) ->
        ival = parseInt(id)
        info = collectionsCache.info()
        keys = _.keys info
        for key in keys
          info[key].then (its) ->
            ids = its.map((it) -> it.id)
            idx = ids.indexOf ival
            if idx >= 0
              f idx, its

      removeItem = (id) ->
        getFrom(id, null, itemsCache).then (it) ->
          itemsCache.remove(id.toString())
        findInCollections id, (idx, its) ->
          its.splice(idx, 1)

      updateItem = (id, newVal) ->
        getFrom(id, null, itemsCache).then (it) ->
          angular.extend it, newVal
        findInCollections id, (idx, its) ->
          angular.extend its[idx], newVal

      getItem = (id, f = null) ->
        succ = (idx, its) ->
          its[idx]
        fail = () ->
          getFrom(id, f, itemsCache)
        findInCollections succ, fail

      collection = (id) ->

        put: (values) ->
          addTo(id, values, collectionsCache)

        get: (f = null) ->
          getFrom(id, f, collectionsCache)

        addItem: (value) ->
          addItemToCollection(id, value)

      item = (id) ->
        put: (value) ->
          addTo(id, value, itemsCache)

        get: (f = null) ->
          getItem(id, f)

        update: (newVal) ->
          updateItem(id, newVal)

        remove: () ->
          removeItem(id)


      collection:  collection
      item:        item
      cache:
        collections: collectionsCache
        items:       itemsCache

      # imap.collection('posts').get () ->
      #   $http.get('/posts').then (re) ->
      #     re.data
      #
      # imap.collection('posts').add newPost
      #
      # imap.item(postId).update newVal
      #
      # imap.item(postId).delete()

