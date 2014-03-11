Vx.service 'buildStore',
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
          if value.pull_request_id
            collection("pulls" + projectId).addItem value
        when 'updated'
          item(buildId).update value, projectId
        when 'destroyed'
          item(buildId).remove projectId

    eventSource.subscribe "builds", subscribe

    all = (projectId) ->
      collection(projectId).get () ->
        $http.get("/api/projects/#{projectId}/builds").then (re) ->
          re.data

    pullRequests = (projectId) ->
      collection("pulls" + projectId).get () ->
        $http.get("/api/projects/#{projectId}/pull_requests").then (re) ->
          re.data

    one = (buildId) ->
      item(buildId).get () ->
        $http.get("/api/builds/#{buildId}").then (re) ->
          re.data

    create = (projectId) ->
      $http.post("/api/projects/#{projectId}/builds").then (re) ->
        re.data

    restart = (buildId) ->
      $http.post("/api/builds/#{buildId}/restart").then (re) ->
        item(buildId).update re.data, re.data.project_id
        re.data

    all:          all
    pullRequests: pullRequests
    one:          one
    create:       create
    restart:      restart

