Vx.service 'projectStore',
  ($http, $q,  eventSource, cacheStore) ->

    cache    = cacheStore()
    projects = cache.collection("projects")

    subscribe = (e) ->
      switch e.event
        when 'created'
          projects.addItem e.data
        when 'updated'
          cache.item(e.id).update e.data, 'projects'
        when 'destroyed'
          cache.item(e.id).remove 'projects'

    eventSource.subscribe "projects", subscribe

    all = () ->
      projects.get () ->
        $http.get("/api/projects").then (re) ->
          re.data

    one = (id) ->
      id = parseInt(id)
      all().then (its) ->
        _.find its, (it) ->
          it.id == id

    subscribeUserToProject = (projectId) ->
      $http.post("/api/projects/#{projectId}/subscription").then (re) ->
        re.data

    unsubscribeUserFromProject = (projectId) ->
      $http.delete("/api/projects/#{projectId}/subscription").then (re) ->
        re.data

    all: all
    one: one
    subscribe: subscribeUserToProject
    unsubscribe: unsubscribeUserFromProject

