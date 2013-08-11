CI.service 'projectsService', ['Restangular', "$q"
  ($rest, $q) ->

    projects = null;

    loadProjects = () ->
      unless projects
        projects = $rest.all("api/projects").getList()

    {
      all: () ->
        loadProjects()
        projects

      find: (id) ->
        id = parseInt(id)
        deferred = $q.defer()
        loadProjects()
        projects.then (its) ->
          project = _.find its, (it) ->
            it.id == id
          deferred.resolve project

        deferred.promise
    }

]
