CI.service 'projectsService', ['$resource', "$q", '$rootScope', 'extendedDefer'
  ($resource, $q, $scope, extendedDefer) ->

    Project = $resource("/api/projects/:id.json")

    projects = $q.defer()
    ext      = extendedDefer(projects)

    Project.query (its) ->
      projects.resolve(its)

    {
      all:  ext.all
      find: ext.find
    }

]
