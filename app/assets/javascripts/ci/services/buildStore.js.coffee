CI.service 'buildStore', ['$http', "$q", "extendedDefer", 'eventSource',
  ($http, $q, extendedDefer, eventSource) ->

    collection =
      projectId: null
      items:     null
      ext:       null

    object =
      id:        null
      item:      null
      ext:       null

    assignCollection = (projectId, re) ->
      d = $q.defer()
      d.resolve re
      collection.projectId = projectId
      collection.items     = extendedDefer d
      re

    assignCollection null, []

    assignObject = (buildId, re) ->
      d = $q.defer()
      d.resolve re
      object.id   = buildId
      object.item = extendedDefer d
      re

    assignObject null, null

    onlySameProject = (build, f) ->
      if build.project_id == collection.projectId
        f()

    onlySameModel = (buildId, f) ->
      if buildId == object.id
        f()

    subscribe = (e) ->
      switch e.action
        when 'created'
          onlySameProject e.data, ->
            collection.items.add e.data
        when 'updated'
          onlySameProject e.data, ->
            collection.items.update e.id, e.data
          onlySameModel e.id, ->
            object.item.all().then (its) ->
              angular.extend its, e.data
        when 'destroyed'
          onlySameProject e.data, ->
            collection.items.delete e.id

    eventSource.subscribe "events.builds", subscribe

    all = (projectId) ->
      projectId = parseInt(projectId)
      if projectId == collection.projectId
        collection.items.all()
      else
        $http.get("/api/projects/#{projectId}/builds").then (re) ->
          assignCollection projectId, re.data

    one = (buildId) ->
      buildId = parseInt(buildId)
      if buildId == object.id
        object.item.all()
      else
        $http.get("/api/builds/#{buildId}").then (re) ->
          assignObject buildId, re.data

    create = (projectId) ->
      $http.post("/api/projects/#{projectId}/builds")

    all:    all
    one:    one
    create: create
]
