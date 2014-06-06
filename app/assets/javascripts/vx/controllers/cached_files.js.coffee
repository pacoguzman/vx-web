Vx.controller 'CachedFilesCtrl', ($scope, appMenu, projectStore, cachedFilesStore, $routeParams) ->

  $scope.project = projectStore.one $routeParams.projectId
  $scope.files   = cachedFilesStore.all $routeParams.projectId

  $scope.destroy = (file) ->
    cachedFilesStore.destroy(file)

  appMenu.define $scope.project, (p) ->
    appMenu.add p.name, "/ui/projects/#{p.id}/builds"
    appMenu.add "Cached Files", "/ui/projects/#{p.id}/cached_files"
