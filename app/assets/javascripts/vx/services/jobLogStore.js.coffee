Vx.service 'jobLogStore',
  ($http, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection

    subscribe = (e) ->
      jobId   = e.data.job_id
      value   = e.data
      switch e.event
        when 'created'
          collection(jobId).addItem value
        when "truncate"
          collection(jobId).truncate()

    eventSource.subscribe "job_logs", subscribe

    all = (jobId) ->
      collection(jobId).get () ->
        $http.get("/api/jobs/#{jobId}/logs").then (re) ->
          re.data

    all: all
