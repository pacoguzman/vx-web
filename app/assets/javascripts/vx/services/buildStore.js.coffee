Vx.service 'buildStore',
  ($http, $q, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    eventSource.subscribe "build:created", (payload) ->
      collection(payload.project_id).addItem(payload)

    eventSource.subscribe "build:updated", (payload) ->
      item(payload.id).update payload, payload.project_id

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

    restart = (buildId) ->
      $http.post("/api/builds/#{buildId}/restart").then (re) ->
        item(buildId).update re.data, re.data.project_id
        re.data

    all:     all
    one:     one
    create:  create
    restart: restart

