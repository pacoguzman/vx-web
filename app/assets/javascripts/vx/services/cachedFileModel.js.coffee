Vx.service 'cachedFileModel', ['$http', 'cacheService', 'eventSource',
  ($http, cacheService, eventSource) ->

    cache = cacheService("cachedFile")

    eventSource.subscribe "cached_file:created", (payload) ->
      cache.push "all:#{payload.project_id}", payload

    eventSource.subscribe "cached_file:updated", (payload) ->
      cache.updateAll "all:#{payload.project_id}", payload

    ###########################################################################

    all: (projectId) ->
      cache.fetch "all:#{projectId}", () ->
        $http.get("/api/projects/#{projectId}/cached_files").then (re) ->
          re.data

    destroy: (files) ->
      projectId = files[0] && files[0].project_id
      ids = _.map(files, (it) -> it.id)
      $http.post("/api/projects/#{projectId}/cached_files/mass_destroy", ids: ids).then (_) ->
        angular.forEach files, (file) ->
          cache.removeAll("all:#{file.project_id}", file.id)
]
