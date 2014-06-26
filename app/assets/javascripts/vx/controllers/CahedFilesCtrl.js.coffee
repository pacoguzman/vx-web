Vx.controller 'CachedFilesCtrl', ($scope, appMenu, projectStore, cachedFilesStore, $routeParams) ->

  $scope.wait      = true
  $scope.files     = []
  $scope.selectAll = false
  $scope.project   = projectStore.one $routeParams.projectId

  cachedFilesStore.all($routeParams.projectId)
    .then (files) ->
      $scope.files = files
    .finally ->
      $scope.wait = false

  $scope.selectFile = (file) ->
    file.destroy = true

  $scope.toggleAllFiles = () ->
    $scope.selectAll = !$scope.selectAll
    _($scope.files).each (file) ->
      file.destroy = $scope.selectAll

  $scope.anyFileSelected = () ->
    _.some $scope.files, (file) ->
      file.destroy

  $scope.destroy = () ->
    _.each $scope.files, (file) ->
      if file.destroy
        cachedFilesStore.destroy(file)

  appMenu.define $scope.project, (p) ->
    appMenu.add p.name, "/ui/projects/#{p.id}/builds"
    appMenu.add "Cached Files", "/ui/projects/#{p.id}/cached_files"
