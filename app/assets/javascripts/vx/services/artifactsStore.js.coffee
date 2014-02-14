Vx.service 'artifactsStore',
  ($http, $q, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    subscribe = (e) ->
      buildId    = e.data.build_id
      artifactId = e.id
      value      = e.data

      switch e.event
        when 'created'
          collection(buildId).addItem value
        when 'updated'
          item(artifactId).update value, buildId

    eventSource.subscribe "artifacts", subscribe

    all = (buildId) ->
      collection(buildId).get () ->
        $http.get("/api/builds/#{buildId}/artifacts").then (re) ->
          re.data

    all: all
