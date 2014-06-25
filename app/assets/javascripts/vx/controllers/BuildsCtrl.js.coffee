Vx.controller 'BuildsCtrl', [ '$scope', 'buildStore', 'projectStore', '$routeParams', '$location'
  ($scope, buildStore, projectStore, $routeParams, $location) ->

    $scope.wait    = true
    $scope.project = null
    $scope.builds  = []

    projectStore.one($routeParams.projectId).then (project) ->
      $scope.project = project

    buildStore.all($routeParams.projectId)
      .then (builds) ->
        $scope.builds = builds
      .finally ->
        $scope.wait = false

    $scope.go = (build) ->
      $location.path("/ui/builds/#{build.id}")
]
