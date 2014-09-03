Vx.service 'jobLogModel', ['$http', 'cacheService', 'eventSource',
  ($http, cacheService, eventSource) ->

    cache = cacheService('jobLog')

    eventSource.subscribe "job_log:created", (payload) ->
      cache.push "all:#{payload.job_id}", payload.log

    eventSource.subscribe "job:logs_truncated", (payload) ->
      cache.truncate "all:#{payload.id}"

    all: (jobId) ->
      cache.fetch "all:#{jobId}", () ->
        $http.get("/api/jobs/#{jobId}/logs").then (re) ->
          _.map re.data, (it) -> it.log
]
