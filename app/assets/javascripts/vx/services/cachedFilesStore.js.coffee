Vx.service 'cachedFilesStore',
  ($http, $q, cacheStore, eventSource) ->

    cache      = cacheStore()
    collection = cache.collection
    item       = cache.item

    subscribe = (e) ->
      projectId = e.data.project_id
      fileId    = e.id
      value     = e.data

      switch e.event
        when 'created'
          collection(projectId).addItem value
        when 'updated'
          item(fileId).update value, projectId

    eventSource.subscribe "cached_files", subscribe

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
