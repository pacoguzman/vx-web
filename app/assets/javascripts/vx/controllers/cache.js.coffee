Vx.controller 'CacheCtrl', ($scope, appMenu, projectStore, cachedFilesStore, $routeParams) ->

  $scope.project = projectStore.one $routeParams.projectId
  $scope.files   = cachedFilesStore.all $routeParams.projectId

  $scope.destroy = (file) ->
    console.log file
    cachedFilesStore.destroy(file)

  appMenu.define $scope.project, (p) ->
    appMenu.add p.name, "/projects/#{p.id}/builds"
    appMenu.add "Cache", "/projects/#{p.id}/cache"
