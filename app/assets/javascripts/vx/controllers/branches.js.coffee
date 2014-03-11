Vx.controller 'BranchesCtrl', ($scope, appMenu, buildStore, projectStore, $routeParams, $location) ->

  $scope.project = projectStore.one $routeParams.projectId
  $scope.builds  = buildStore.branches $routeParams.projectId

  appMenu.define $scope.project, (p) ->
    appMenu.add p.name, "/projects/#{p.id}/builds"
    appMenu.add "Branches", "/projects/#{p.id}/branches"

