CI.controller 'BuildCtrl', ['$scope', 'appMenu', 'projectStore', 'buildStore', '$routeParams',
  ($scope, menu, projects, builds, $routeParams) ->

    $scope.build = builds.one $routeParams.buildId

    $scope.build.then (build) ->
      $scope.project = projects.one(build.project_id)
      menu.define $scope.build, $scope.project, (b,p) ->
        menu.add p.name, "/projects/#{p.id}/builds"
        menu.add "Build ##{b.number}", "/builds/#{b.id}"

]
