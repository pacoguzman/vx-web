Vx.controller 'BuildsCtrl', ($scope, appMenu, buildStore, projectStore, $routeParams, $location) ->

  $scope.waitBuilds = true
  $scope.project    = projectStore.one $routeParams.projectId
  $scope.builds     = buildStore.all($routeParams.projectId).finally ->
    $scope.waitBuilds = false

  appMenu.define $scope.project, (p) ->
    appMenu.add p.name, "/ui/projects/#{p.id}/builds"

