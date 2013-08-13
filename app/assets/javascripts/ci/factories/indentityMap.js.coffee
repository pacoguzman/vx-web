angular.module('CI').
  factory "identityMap", ($q, $cacheFactory) ->

    (collectionLimit = 2, itemsLimit = 2) ->

      collectionsCache = $cacheFactory('collections', capacity: collectionLimit)
      itemsCache       = $cacheFactory('items', capacity: itemsLimit)

      addTo = (id, values, cache) ->
        id = id.toString()
        cache.put id, values
        values

      getFrom = (id, f, cache) ->
        id = id.toString()
        value = cache.get(id)
        if !value
          if f
            value = addTo id, f(), cache
          else
            d = $q.defer()
            d.reject id
            value = d.promise
        value

      addItemToCollection = (id, value) ->
        getFrom(id, null, collectionsCache).then (its) ->
          its.push value
          value

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

      collection = (id) ->

        put: (values) ->
          addTo(id, values, collectionsCache)

        get: (f = null) ->
          getFrom(id, f, collectionsCache)

        add: (value) ->
          addItemToCollection(id, value)

      item = (id) ->
        put: (value) ->
          addTo(id, value, itemsCache)

        get: (f = null) ->
          getFrom(id, f, itemsCache)

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

