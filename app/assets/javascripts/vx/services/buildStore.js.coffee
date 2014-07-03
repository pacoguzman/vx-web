Vx.service 'buildStore',
  ($http, $q, cacheStore, eventSource, $rootScope) ->

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

    loadMore = (projectId, fromNumber) ->
      $http.get("/api/projects/#{projectId}/builds?from=#{fromNumber}").then (re) ->
        collection(projectId).get().then (c) ->
          c.push.apply(c, re.data)

    all:     all
    one:     one
    create:  create
    restart: restart
    loadMore: loadMore

