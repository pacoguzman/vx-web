CI.controller 'BuildCtrl', ($scope, appMenu, projectStore, buildStore, jobStore, $routeParams) ->

    $scope.build   = buildStore.one $routeParams.buildId
    $scope.jobs    = jobStore.all $routeParams.buildId

    $scope.project = $scope.build.then (it) ->
      projectStore.one it.project_id

    appMenu.define $scope.build, $scope.project, (b,p) ->
      appMenu.add p.name, "/projects/#{p.id}/builds"
      appMenu.add "Build ##{b.number}", "/builds/#{b.id}"
