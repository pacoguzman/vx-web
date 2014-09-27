Vx.service 'projectModel', ['$http', 'cacheService', 'eventSource',
  ($http, cacheService, eventSource) ->

    cache = cacheService("project")
    branchesCache = cacheService("project:branches")

    all = () ->
      cache.fetch "all", () ->
        $http.get("/api/projects").then (re) ->
          re.data

    eventSource.subscribe "project:created", (payload) ->
      cache.push("all", payload)

    eventSource.subscribe "project:updated", (payload) ->
      cache.updateAll("all", payload)

    all: all

    one: (id) ->
      all().then (re) ->
        _.find re, (it) -> it.id == id

    buildHeadCommit: (id) ->
      $http.post("/api/projects/#{id}/build_head").then (re) ->
        re.data

    subscribe: (id) ->
      $http.post("/api/projects/#{id}/subscription").then (re) ->
        re.data

    unsubscribe: (id) ->
      $http.delete("/api/projects/#{id}/subscription").then (re) ->
        re.data

    branches: (id) ->
      branchesCache.fetch id, () ->
        $http.get("/api/projects/#{id}/branches").then (re) ->
          re.data
]
