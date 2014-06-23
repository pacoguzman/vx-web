Vx.service 'buildStore',
  ($http, $q, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    eventSource.subscribe "build:created", (payload) ->
      collection(payload.project_id).addItem(payload)
      _onBranchesForCreate(payload.project_id, payload.id, payload)
      collection("queued").addItem payload
      _onPullRequestsForCreate(payload.project_id, payload.id, payload)

    eventSource.subscribe "build:updated", (payload) ->
      item(payload.id).update payload, payload.project_id
      item(payload.id).update payload, "branches" + payload.project_id
      if !payload.finished_at # still pending
        item(payload.id).update payload, "queued"
      else
        item(payload.id).remove "queued"
    
    # FIXME This is not in master anymore
    eventSource.subscribe "build:destroyed", (payload) ->
      item(payload.id).remove payload.project_id
      item(payload.id).remove "branches" + payload.project_id
      item(payload.id).remove "queued"

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

