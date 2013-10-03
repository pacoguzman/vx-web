CI.service 'buildStore',
  ($http, $q, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    subscribe = (e) ->
      projectId = e.data.project_id
      buildId   = e.id
      value     = e.data

      switch e.event
        when 'created'
          collection(projectId).addItem value
        when 'updated'
          item(buildId).update value, projectId
        when 'destroyed'
          item(buildId).remove projectId

    eventSource.subscribe "builds", subscribe

    all = (projectId) ->
      collection(projectId).get () ->
        $http.get("/api/projects/#{projectId}/builds").then (re) ->
          re.data

    one = (buildId) ->
      item(buildId).get () ->
        $http.get("/api/builds/#{buildId}").then (re) ->
          re.data

    create = (projectId) ->
      $http.post("/api/projects/#{projectId}/builds").then (re) ->
        re.data

    all:    all
    one:    one
    create: create
