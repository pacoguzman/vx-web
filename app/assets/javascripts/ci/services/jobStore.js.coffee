CI.service 'jobStore',
  ($http, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    subscribe = (e) ->
      buildId = e.data.build_id
      jobId   = e.id
      value   = e.data
      switch e.action
        when 'created'
          collection(buildId).addItem value
        when 'updated'
          item(jobId).update value, buildId
        when 'destroyed'
          item(jobId).remove buildId

    eventSource.subscribe "events.jobs", subscribe

    all = (buildId) ->
      collection(buildId).get () ->
        $http.get("/api/builds/#{buildId}/jobs").then (re) ->
          re.data

    one = (jobId) ->
      item(jobId).get () ->
        $http.get("/api/jobs/#{jobId}").then (re) ->
          re.data

    all:    all
    one:    one
