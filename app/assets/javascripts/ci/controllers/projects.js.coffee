CI.controller 'ProjectsCtrl', ['$scope', 'projectsService', 'appMenu',

  ($scope, projects, appMenu) ->

    appMenu.define()

    $scope.projects = projects.all()


    listener = (e) ->
      console.log e

    eventSource = new EventSource('/events')

    eventSource.addEventListener 'events.projects', listener, false
    eventSource.addEventListener 'events.projects', listener, false

]
