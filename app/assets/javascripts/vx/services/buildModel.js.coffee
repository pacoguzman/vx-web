Vx.service "buildModel", ['$http', 'cacheService', 'eventSource',
  ($http, cacheService, eventSource) ->

    cache = cacheService("build")

    eventSource.subscribe "build:created", (payload) ->
      cache.unshift("all:#{payload.project_id}", payload)

      _onBranchesForCreate(payload.project_id, payload.id, payload)
      cache.unshift("queued", payload)
      _onPullRequestsForCreate(payload.project_id, payload.id, payload)

    eventSource.subscribe "build:updated", (payload) ->
      cache.updateAll("all:#{payload.project_id}", payload)
      cache.updateOne("one:#{payload.id}", payload)

      cache.updateAll("branches:#{payload.project_id}", payload)

      if !payload.finished_at # still pending
        cache.updateAll("queued", payload)
      else
        cache.removeAll("queued", payload.id)

    _onBranchesForCreate = (projectId, buildId, value) ->
      if value.branch
        if collection = cache.cache.get("branches:#{projectId}")
          idx = _.pluck(collection, "branch").indexOf(value.branch)
          if idx >= 0
            collection.splice(idx, 1)

          collection.push value
          cache.resolve(value)

    _onPullRequestsForCreate = (projectId, buildId, value) ->
      if value.pull_request_id
        if collection = cache.cache.get("pull_requests:#{projectId}")
          idx = _.pluck(collection, "pull_request_id").indexOf(value.pull_request_id)
          if idx >= 0
            collection.splice(idx, 1)

          collection.push value
          cache.resolve(value)

    all = (projectId) ->
      cache.fetch "all:#{projectId}", () ->
        $http.get("/api/projects/#{projectId}/builds").then (re) ->
          re.data

    pullRequests = (projectId) ->
      cache.fetch "pulls:#{projectId}", () ->
        $http.get("/api/projects/#{projectId}/pull_requests").then (re) ->
          re.data

    branches = (projectId) ->
      cache.fetch "branches:#{projectId}", () ->
        $http.get("/api/projects/#{projectId}/branches").then (re) ->
          re.data

    queued = () ->
      cache.fetch "queued", () ->
        $http.get("/api/builds/queued").then (re) ->
          re.data

    ###########################################################################

    all: all
    pullRequests: pullRequests
    branches:     branches
    queued:       queued

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
