Vx.controller 'BuildsCtrl', ($scope, appMenu, buildStore, projectStore, $routeParams, $location) ->

  $scope.project = projectStore.one $routeParams.projectId
  $scope.builds  = buildStore.all $routeParams.projectId

  appMenu.define $scope.project, (p) ->
    appMenu.add p.name, "/ui/projects/#{p.id}/builds"

