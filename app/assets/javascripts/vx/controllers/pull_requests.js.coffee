Vx.controller 'PullRequestsCtrl', ($scope, appMenu, buildStore, projectStore, $routeParams, $location) ->

  $scope.project = projectStore.one $routeParams.projectId
  $scope.builds  = buildStore.pullRequests $routeParams.projectId

  appMenu.define $scope.project, (p) ->
    appMenu.add p.name, "/projects/#{p.id}/builds"
    appMenu.add "Pull Requests", "/projects/#{p.id}/pull_requests"

