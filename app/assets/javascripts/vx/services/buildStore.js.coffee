Vx.service 'buildStore',
  ($http, $q, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    subscribe = (e) ->
      projectId = e.data.project_id
      buildId   = e.id
      value     = e.data

      switch e.event
        when 'created'
          collection(projectId).addItem value
          _onBranchesForCreate(projectId, e.data.id, value)
          collection("queued").addItem value
          _onPullRequestsForCreate(projectId, e.data.id, value)
        when 'updated'
          item(buildId).update value, projectId
          item(buildId).update value, "branches" + projectId
          if !value.finished_at # still pending
            item(buildId).update value, "queued"
          else
            item(buildId).remove "queued"
        when 'destroyed'
          item(buildId).remove projectId
          item(buildId).remove "branches" + projectId
          item(buildId).remove "queued"

    _onBranchesForCreate = (projectId, buildId, value) ->
      if value.branch
        collection("branches" + projectId).get().then (its) ->
          d = $q.defer()

          idx = _.pluck(its, "branch").indexOf(value.branch)
          if idx >= 0
            its.splice(idx, 1)

          its.push value
          d.resolve value
          d.promise

    _onPullRequestsForCreate = (projectId, buildId, value) ->
      if value.pull_request_id
        collection("pulls" + projectId).get().then (its) ->
          d = $q.defer()

          idx = _.pluck(its, "pull_request_id").indexOf(value.pull_request_id)
          if idx >= 0
            its.splice(idx, 1)

          its.push value
          d.resolve value
          d.promise

    eventSource.subscribe "builds", subscribe

    all = (projectId) ->
      collection(projectId).get () ->
        $http.get("/api/projects/#{projectId}/builds").then (re) ->
          re.data

    pullRequests = (projectId) ->
      collection("pulls" + projectId).get () ->
        $http.get("/api/projects/#{projectId}/pull_requests").then (re) ->
          re.data

    branches = (projectId) ->
      collection("branches" + projectId).get () ->
        $http.get("/api/projects/#{projectId}/branches").then (re) ->
          re.data

    queued = () ->
      collection("queued").get () ->
        $http.get("/api/builds/queued").then (re) ->
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

    all:          all
    pullRequests: pullRequests
    branches:     branches
    queued:       queued
    one:          one
    create:       create
    restart:      restart

