Vx.controller 'PullRequestsCtrl', ['$scope', 'projectStore', 'buildStore', '$routeParams', '$location',
  ($scope, projectStore, buildStore, $routeParams, $location) ->

    $scope.project = null
    $scope.builds = []

    projectStore.one($routeParams.projectId).then (project) ->
      $scope.project = project

    buildStore.pullRequests($routeParams.projectId).then (builds) ->
      $scope.builds = builds

    $scope.go = (build) ->
      $location.path("/ui/builds/#{build.id}")
]
