Vx.service 'jobLogStore',
  ($http, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection

    eventSource.subscribe "job_log:created", (payload) ->
      collection(payload.job_id).addItem payload.log

    eventSource.subscribe "job:logs_truncated", (payload) ->
      collection(payload.id).truncate()

    all = (jobId) ->
      collection(jobId).get () ->
        $http.get("/api/jobs/#{jobId}/logs").then (re) ->
          _.map re.data, (it) -> it.log

    all: all
