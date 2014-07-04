Vx.controller 'ProjectSettingsCtrl', ['$scope', 'cachedFileModel', 'project', '$location',
  ($scope, cachedFileModel, project, $location) ->

    $scope.project = project

    ########################################################################

    $scope.cachedFiles            = []
    $scope.allCachedFilesSelected = false

    cachedFileModel.all(project.id)
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
      cachedFileModel.destroy files
]
