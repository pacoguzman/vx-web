Vx.controller 'BuildCtrl', ($scope, appMenu, artifactsStore, projectStore, buildStore, jobStore, $routeParams, $timeout) ->

  $scope.build     = buildStore.one $routeParams.buildId
  $scope.jobs      = jobStore.all $routeParams.buildId
  $scope.artifacts = artifactsStore.all $routeParams.buildId

  $scope.project = $scope.build.then (it) ->
    projectStore.one it.project_id

  $scope.restartBuild = (build) ->
    buildStore.restart(build.id)

  $scope.isFinished = (build) ->
    build && ["passed", 'failed', 'errored'].indexOf(build.status) != -1

  appMenu.define $scope.build, $scope.project, (b,p) ->
    appMenu.add p.name, "/projects/#{p.id}/builds"
    appMenu.add "Build #{b.number}", "/builds/#{b.id}"
