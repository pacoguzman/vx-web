Vx.service "jobModel", ['$http', 'cacheService', 'eventSource',
  ($http, cacheService, eventSource) ->

    cache = cacheService("job")

    eventSource.subscribe "job:created", (payload) ->
      cache.push("all:#{payload.build_id}", payload)

    eventSource.subscribe "job:updated", (payload) ->
      cache.updateAll("all:#{payload.build_id}", payload)
      cache.updateOne("one:#{payload.id}", payload)

    all: (buildId) ->
      cache.fetch "all:#{buildId}", () ->
        $http.get("/api/builds/#{buildId}/jobs").then (re) ->
          re.data

    one: (id) ->
      cache.fetch "one:#{id}", () ->
        $http.get("/api/jobs/#{id}").then (re) ->
          re.data
]
