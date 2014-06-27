Vx.controller 'ProjectSettingsCtrl', ['$scope', 'projectStore', 'cachedFilesStore', '$routeParams', '$location'
  ($scope, projectStore, cachedFilesStore, $routeParams, $location) ->

    $scope.project                = null
    $scope.pubKey                 = null

    projectStore.one($routeParams.projectId).then (project) ->
      $scope.project = project
      $scope.pubKey  = "#{$location.protocol()}://#{$location.host()}/api/projects/#{project.id}/key.txt"


    ########################################################################

    $scope.cachedFiles            = []
    $scope.allCachedFilesSelected = false

    cachedFilesStore.all($routeParams.projectId)
      .then (files) ->
        $scope.cachedFiles = files

    $scope.anyCachedFileSelected = () ->
      _.some $scope.cachedFiles, (file) ->
        file.selected

    $scope.toggleSelectAllCachedFiles = () ->
      $scope.allCachedFilesSelected = !$scope.allCachedFilesSelected
      _($scope.cachedFiles).each (file) ->
        file.selected = $scope.allCachedFilesSelected

    $scope.destroySelectedCachedFiles = () ->
      files = _.filter($scope.cachedFiles, (it) -> it.selected)
      cachedFilesStore.destroy files
  ]
