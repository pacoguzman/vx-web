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

    applyCollection = (projectId, re) ->
      d = $q.defer()
      d.resolve re.data

      collection.projectId = projectId
      collection.items     = extendedDefer d
      re.data

    applyObject = (buildId, re) ->
      d = $q.defer()
      d.resolve re.data
      object.id   = buildId
      object.item = extendedDefer d
      re.data

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

    _all = (projectId) ->
      projectId = parseInt(projectId)
      if projectId == collection.projectId
        collection.items.all()
      else
        $http.get("/api/projects/#{projectId}/builds").then (re) ->
          applyCollection projectId, re

    _one = (buildId) ->
      buildId = parseInt(buildId)
      if buildId == object.id
        object.item.all()
      else
        $http.get("/api/builds/#{buildId}").then (re) ->
          applyObject buildId, re

    all: _all
    one: _one
]
