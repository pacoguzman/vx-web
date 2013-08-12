CI.service 'projectStore', ['$http', "$q", 'extendedDefer', 'eventSource',
    ($http, $q, extendedDefer, eventSource) ->

      projects = $q.defer()
      ext      = extendedDefer(projects)

      subscribe = (e) ->
        switch e.action
          when 'created'
            ext.add e.data
          when 'updated'
            ext.update e.id, e.data
          when 'destroyed'
            ext.delete e.id

      $http.get("/api/projects").then (re) ->
        projects.resolve(re.data)
        eventSource.subscribe "events.projects", subscribe

      all:  ext.all
      find: ext.find
]
