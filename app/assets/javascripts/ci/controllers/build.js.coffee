CI.controller 'BuildCtrl', ($scope, appMenu, projectStore, buildStore, jobStore, $routeParams) ->

    $scope.build  = buildStore.one $routeParams.buildId
    $scope.jobs   = jobStore.all $routeParams.buildId
    $scope.matrix = []

    $scope.build.then (build) ->
      $scope.project = projectStore.one(build.project_id)
      appMenu.define $scope.build, $scope.project, (b,p) ->
        appMenu.add p.name, "/projects/#{p.id}/builds"
        appMenu.add "Build ##{b.number}", "/builds/#{b.id}"

    $scope.$watch 'jobs', (newVal, oldVal) ->
      its =  newVal || oldVal || []
      $scope.matrix = if its[0] && its[0].matrix
        _.keys its[0].matrix
      else
        []
    , true
