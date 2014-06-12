Vx.controller 'BuildCtrl', ($scope, appMenu, projectStore, buildStore, jobStore, $routeParams) ->

  $scope.waitJobs  = true

  $scope.build     = buildStore.one($routeParams.buildId)
  $scope.jobs      = jobStore.all($routeParams.buildId).finally ->
    $scope.waitJobs = false

  $scope.project = $scope.build.then (it) ->
    projectStore.one it.project_id

  $scope.restartBuild = (build) ->
    buildStore.restart(build.id)

  $scope.isFinished = (build) ->
    build && ["passed", 'failed', 'errored'].indexOf(build.status) != -1

  appMenu.define $scope.build, $scope.project, (b,p) ->
    appMenu.add p.name, "/ui/projects/#{p.id}/builds"
    appMenu.add "Build #{b.number}", "/ui/builds/#{b.id}"
