CI.controller 'BuildsCtrl', ($scope, appMenu, buildStore, projectStore, $routeParams, $location) ->

  $scope.project = projectStore.one $routeParams.projectId
  $scope.builds  = buildStore.all $routeParams.projectId

  appMenu.define $scope.project, (p) ->
    appMenu.add p.name, "/projects/#{p.id}/builds"

  $scope.projectSubscribeClass = (project) ->
    if project && project.subscribed
      'fa-star'
    else
      'fa-star-o'

  $scope.changeProjectSubscription = (project) ->
    project.subscribed = !project.subscribed
    if project.subscribed
      projectStore.subscribe(project.id)
    else
      projectStore.unsubscribe(project.id)
