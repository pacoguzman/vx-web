Vx.service 'cachedFilesStore',
  ($http, $q, cacheStore) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    all = (projectId) ->
      collection(projectId).get () ->
        $http.get("/api/projects/#{projectId}/cached_files").then (re) ->
          re.data

    destroy = (file) ->
      if file
        item(file.id).remove(file.project_id)
        $http.delete("/api/cached_files/#{file.id}")

    all:     all
    destroy: destroy
