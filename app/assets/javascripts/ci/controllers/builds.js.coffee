CI.controller 'BuildsCtrl', ($scope, appMenu, buildStore, projectStore, $routeParams, $location) ->

  $scope.project = projectStore.one $routeParams.projectId
  $scope.builds  = buildStore.all $routeParams.projectId

  appMenu.define $scope.project, (p) ->
    appMenu.add p.name, "/projects/#{p.id}/builds"

  $scope.createBuild = () ->
    buildStore.create($routeParams.projectId).then (build) ->
      $location.path "/builds/#{build.id}"

  $scope.changeProjectSubscription = (project) ->
    if project.subscribed
      projectStore.subscribe(project.id)
    else
      projectStore.unsubscribe(project.id)
