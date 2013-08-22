CI.service 'jobLogStore',
  ($http, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection

    subscribe = (e) ->
      jobId   = e.data.job_id
      value   = e.data
      switch e.action
        when 'created'
          collection(jobId).addItem value

    eventSource.subscribe "events.job_logs", subscribe

    all = (jobId) ->
      collection(jobId).get () ->
        $http.get("/api/jobs/#{jobId}/logs").then (re) ->
          re.data

    all:    all
