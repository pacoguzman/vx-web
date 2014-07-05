Vx.controller 'BuildsCtrl', [ '$scope', 'buildModel', 'project', '$location', 'localStorageService'
  ($scope, buildModel, project, $location, storage) ->

    $scope.wait      = true
    $scope.project   = project
    $scope.builds    = []
    $scope.displayAs = storage.get("vx.builds.display_as") || 'feed'
    $scope.noMore    = false

    truncateBuilds = () ->
      if $scope.builds.length > 30
        $scope.builds.length = 30

    buildModel.all(project.id)
      .then (builds) ->
        $scope.builds = builds
        truncateBuilds()
      .finally ->
        $scope.wait = false

    ###########################################################################

    $scope.go = (build) ->
      $location.path("/ui/builds/#{build.id}")

    $scope.setDisplayAs = (newVal) ->
      $scope.displayAs = newVal
      storage.set('vx.builds.display_as', newVal)

    $scope.loadMoreBuilds = () ->
      $scope.wait = true
      buildModel.loadMore(project.id)
        .then (re) ->
          $scope.noMore = re.length == 0
        .finally () ->
          $scope.wait = false
]
