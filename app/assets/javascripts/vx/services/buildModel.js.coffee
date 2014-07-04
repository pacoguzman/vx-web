Vx.service "buildModel", ['$http', 'cacheService', 'eventSource',
  ($http, cacheService, eventSource) ->

    cache = cacheService("build")

    eventSource.subscribe "build:created", (payload) ->
      cache.unshift("all:#{payload.project_id}", payload)

    eventSource.subscribe "build:updated", (payload) ->
      cache.updateAll("all:#{payload.project_id}", payload)
      cache.updateOne("one:#{payload.id}", payload)


    all = (projectId) ->
      cache.fetch "all:#{projectId}", () ->
        $http.get("/api/projects/#{projectId}/builds").then (re) ->
          re.data

    ###########################################################################

    all: all

    one: (id) ->
      cache.fetch "one:#{id}", () ->
        $http.get("/api/builds/#{id}").then (re) ->
          re.data

    restart: (build) ->
      $http.post("/api/builds/#{build.id}/restart").then (re) ->
        cache.updateAll("all:#{build.projectId}", re.data)
        cache.updateOne("one:#{build.id}", re.data)
        re.data

    loadMore: (projectId) ->
      all(projectId).then (builds) ->
        lastBuild = _.last(builds)
        $http.get("/api/projects/#{projectId}/builds?from=#{lastBuild.number}").then (re) ->
          cache.push("all:#{projectId}", re.data)
          re.data
]
