angular.module('Vx').
  factory "cacheStore", ($q, $cacheFactory) ->

    _id = -1

    (collectionLimit = 2, itemsLimit = 2) ->

      _id++

      collectionsCache = $cacheFactory("collections.#{_id}", capacity: collectionLimit)
      itemsCache       = $cacheFactory("items.#{_id}", capacity: itemsLimit)

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
              if _.pluck(its, "id").indexOf(it.id) == -1
                its.push it
              it
          else
            d = $q.defer()

            if value.id
              if _.pluck(its, "id").indexOf(value.id) == -1
                its.push value
            else
              its.push value
            d.resolve value
            d.promise

      findInCollections = (id, collectionId, f) ->
        if collectionId
          ival         = parseInt(id)
          collectionId = collectionId.toString()
          collection   = collectionsCache.get(collectionId)
          if collection
            ids = collection.map((it) -> it.id)
            idx = ids.indexOf(ival)
            if idx >= 0
              f(idx, collection)

      removeItem = (id, collectionId) ->
        it = itemsCache.get(id.toString())
        removed = null
        if it
          itemsCache.remove(id.toString())
          removed = it
        if collectionId
          findInCollections id, collectionId, (idx, its) ->
            removed = its[idx]
            its.splice(idx, 1)
        d = $q.defer()
        if removed
          d.resolve removed
        else
          d.reject id.toString()
        d.promise

      truncateCollection = (collectionId) ->
        collection = collectionsCache.get(collectionId)
        collection.length = 0 if collection

      updateItem = (id, collectionId, newVal) ->
        it = itemsCache.get(id.toString())
        updated = null
        if it
          angular.extend it, newVal
          updated = it
        if collectionId
          findInCollections id, collectionId, (idx, its) ->
            angular.extend its[idx], newVal
            updated = its[idx]
        d = $q.defer()
        if updated
          d.resolve updated
        else
          d.reject id.toString()
        d.promise

      collection = (id) ->

        put: (values) ->
          addTo(id, values, collectionsCache)

        get: (f = null) ->
          getFrom(id, f, collectionsCache)

        addItem: (value) ->
          addItemToCollection(id, value)

        truncate: ()->
          truncateCollection(id)

      item = (id) ->
        put: (value) ->
          addTo(id, value, itemsCache)

        get: (f = null) ->
          getFrom(id, f, itemsCache)

        update: (newVal, collectionId) ->
          updateItem(id, collectionId, newVal)

        remove: (collectionId) ->
          removeItem(id, collectionId)


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

