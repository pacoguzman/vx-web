CI.controller 'BuildsCtrl', ['$scope', 'appMenu', 'buildsService', 'projectsService', '$routeParams',
  ($scope, menu, builds, projects, $routeParams) ->

    #$scope.eventSource = new EventSource("/events/projects_1")

    callback = (e) ->
      b = JSON.parse(e.data)
      $scope.builds.forEach (it, idx) ->
        if it.id == b.id
          $scope.builds[idx] = angular.copy b

    $scope.project = projects.find $routeParams.projectId
    $scope.builds  = builds.all $routeParams.projectId

    $scope.project.then (project) ->
      menu.define ->
        menu.add project.name, "/projects/#{project.id}/builds"

    $scope.createBuild = () ->
      builds.create $routeParams.projectId

]
