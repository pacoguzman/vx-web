Vx.service "buildModel", ['$http', 'cacheService', 'eventSource',
  ($http, cacheService, eventSource) ->

    cache = cacheService("build")

    eventSource.subscribe "build:created", (payload) ->
      cache.unshift("all:#{payload.project_id}", payload)
      cache.unshift("all:#{payload.project_id}:branch:#{payload.branch}", payload)

    eventSource.subscribe "build:updated", (payload) ->
      cache.updateAll("all:#{payload.project_id}", payload)
      cache.updateAll("all:#{payload.project_id}:branch:#{payload.branch}", payload)
      cache.updateOne("one:#{payload.id}", payload)

    all = (projectId, branch) ->
      url = "/api/projects/#{projectId}/builds"
      key = "all:#{projectId}"

      if branch
        url = "#{url}?branch=#{branch}"
        key = "#{key}:branch:#{branch}"

      cache.fetch key, () ->
        $http.get(url).then (re) ->
          re.data

    ###########################################################################

    all: all

    one: (id) ->
      cache.fetch "one:#{id}", () ->
        $http.get("/api/builds/#{id}").then (re) ->
          re.data

    restart: (build) ->
      $http.post("/api/builds/#{build.id}/restart").then (re) ->
        cache.updateAll("all:#{build.projectId}", re.data)
        cache.updateOne("one:#{build.id}", re.data)
        re.data

    loadMore: (projectId, branch) ->
      all(projectId, branch).then (builds) ->
        lastBuild = _.last(builds)
        url = "/api/projects/#{projectId}/builds?from=#{lastBuild.number}"
        if branch
          url = "#{url}&branch=#{branch}"

        $http.get(url).then (re) ->
          cache.push("all:#{projectId}", re.data)
          if branch
            cache.push("all:#{projectId}:branch:#{branch}", re.data)
          re.data
]
