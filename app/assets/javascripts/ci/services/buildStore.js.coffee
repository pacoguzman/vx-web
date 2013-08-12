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

    subscribe = (e) ->
      switch e.action
        when 'created'
          if collection.projectId == e.data.project_id
            collection.items.add e.data

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
