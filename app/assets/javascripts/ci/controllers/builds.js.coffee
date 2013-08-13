CI.controller 'BuildsCtrl', ['$scope', 'appMenu', 'buildStore', 'projectStore', '$routeParams',
  ($scope, menu, builds, projects, $routeParams) ->

    $scope.project = projects.one $routeParams.projectId
    $scope.builds  = builds.all $routeParams.projectId

    menu.define $scope.project, (p) ->
      menu.add p.name, "/projects/#{p.id}/builds"

    $scope.createBuild = () ->
      builds.create $routeParams.projectId

]
