Vx.service 'jobStore',
  ($http, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    eventSource.subscribe "job:created", (payload) ->
      collection(payload.build_id).addItem payload

    eventSource.subscribe "job:updated", (payload) ->
      item(payload.id).update payload, payload.build_id

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
