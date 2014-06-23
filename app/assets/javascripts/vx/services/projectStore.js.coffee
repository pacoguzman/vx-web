Vx.service 'projectStore',
  ($http, $q,  eventSource, cacheStore) ->

    cache    = cacheStore()
    projects = cache.collection("projects")

    eventSource.subscribe "project:created", (payload) ->
      projects.addItem payload

    eventSource.subscribe "project:updated", (payload) ->
      cache.item(payload.id).update payload, 'projects'

    eventSource.subscribe "project:destroyed", (payload) ->
      cache.item(payload.id).remove 'projects'

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

