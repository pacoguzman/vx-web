Vx.service 'cachedFilesStore',
  ($http, $q, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    eventSource.subscribe "cached_file:created", (payload) ->
      collection(payload.project_id).addItem payload

    all = (projectId) ->
      collection(projectId).get () ->
        $http.get("/api/projects/#{projectId}/cached_files").then (re) ->
          re.data

    destroy = (files) ->
      project_id = files[0] && files[0].project_id
      ids = _.map(files, (it) -> it.id)
      $http.post("/api/projects/#{project_id}/cached_files/mass_destroy", ids: ids).then (_) ->
        angular.forEach files, (file) ->
          item(file.id).remove file.project_id


    all:     all
    destroy: destroy
