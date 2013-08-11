CI.service 'buildsService', ['Restangular', "$q", "$cacheFactory"
  ($rest, $q, $cache) ->

    projectBuilds = $cache("projectBuilds")
    builds        = $cache("builds")

    cached = (cache, key, callback) ->
      unless cache.get key
        cache.put key, callback()
      cache.get key

    loadProjectBuilds = (projectId) ->
      cached projectBuilds, projectId, () ->
        $rest.one("api/projects", projectId).all("builds").getList()

    loadBuilds = (id) ->
      cached builds, id, () ->
        $rest.one("api/builds", id).get()

    {
      all: (projectId) ->
        loadProjectBuilds projectId

      find: (id) ->
        loadBuilds id

      create: (projectId) ->
        $rest.one("api/projects", projectId).all("builds").post().then (build) ->
          loadProjectBuilds(projectId).push build

    }

]
