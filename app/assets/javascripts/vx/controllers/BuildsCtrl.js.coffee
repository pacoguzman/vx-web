Vx.controller 'BuildsCtrl', [ '$scope', 'buildStore', 'projectStore', '$routeParams', '$location', 'localStorage'
  ($scope, buildStore, projectStore, $routeParams, $location, storage) ->

    projectId        = $routeParams.projectId
    $scope.wait      = true
    $scope.project   = null
    $scope.builds    = []
    $scope.displayAs = storage.get("vx.builds.display_as") || 'feed'

    projectStore.one(projectId).then (project) ->
      $scope.project = project

    buildStore.all($routeParams.projectId)
      .then (builds) ->
        $scope.builds = builds
      .finally ->
        $scope.wait = false

    $scope.go = (build) ->
      $location.path("/ui/builds/#{build.id}")

    $scope.setDisplayAs = (newVal) ->
      $scope.displayAs = newVal
      storage.set('vx.builds.display_as', newVal)

    $scope.loadMoreBuilds = () ->
      $scope.wait = true
      lastBuild = _.last($scope.builds)
      buildStore.loadMore(projectId, lastBuild.number).finally () ->
        $scope.wait = false
]
