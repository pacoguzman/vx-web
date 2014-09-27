Vx.controller 'BuildsCtrl', [ '$scope', 'buildModel', 'projectModel', 'project', '$location', 'localStorageService'
  ($scope, buildModel, projectModel, project, $location, storage) ->

    $scope.wait           = true
    $scope.project        = project
    $scope.builds         = []
    $scope.displayAs      = storage.get("vx:builds:display:as") || 'table'
    $scope.noMore         = false
    $scope.branches       = []
    $scope.selectedBranch = storage.get("vx:builds:branch:#{project.id}") || null
    $scope.buildHeadCommitWait = false

    truncateBuilds = () ->
      if $scope.builds.length > 30
        $scope.builds.length = 30
      else
        $scope.noMore = $scope.builds.length < 29

    loadBuilds = () ->
      buildModel.all(project.id, $scope.selectedBranch)
        .then (builds) ->
          $scope.builds = builds
          truncateBuilds()
        .finally ->
          $scope.wait = false

    projectModel.branches(project.id).then (branches) ->
      $scope.branches = branches

    updateSelectedBranch = (newVal) ->
      if newVal
        storage.set("vx:builds:branch:#{project.id}", newVal)
      else
        storage.del("vx:builds:branch:#{project.id}")
      $scope.selectedBranch = newVal
      loadBuilds()

    $scope.$watch "selectedBranch", updateSelectedBranch

    ###########################################################################

    $scope.buildHeadCommit = () ->
      $scope.buildHeadCommitWait = true
      projectModel.buildHeadCommit($scope.project.id)
        .finally () ->
          $scope.buildHeadCommitWait = false

    $scope.selectBranch = (branch) ->
      $scope.selectedBranch = branch

    $scope.go = (build) ->
      $location.path("/ui/builds/#{build.id}")

    $scope.setDisplayAs = (newVal) ->
      $scope.displayAs = newVal
      storage.set('vx.builds.display_as', newVal)

    $scope.loadMoreBuilds = () ->
      $scope.wait = true
      buildModel.loadMore(project.id, $scope.selectedBranch)
        .then (re) ->
          $scope.noMore = re.length == 0
        .finally () ->
          $scope.wait = false
]
