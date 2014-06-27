Vx.controller 'BuildCtrl', ['$scope', 'projectStore', 'buildStore', 'jobStore', '$routeParams',
  ($scope, projectStore, buildStore, jobStore, $routeParams) ->

    $scope.project     = null
    $scope.build       = null
    $scope.regularJobs = []
    $scope.deployJobs  = []

    buildStore.one($routeParams.buildId).then (build) ->
      $scope.build = build
      projectStore.one(build.project_id).then (project) ->
        $scope.project = project

    jobStore.all($routeParams.buildId).then (jobs) ->
      $scope.regularJobs = _.filter(jobs, (it) -> it.kind == 'regular')
      $scope.deployJobs  = _.filter(jobs, (it) -> it.kind == 'deploy')

    $scope.restart = () ->
      buildStore.restart($scope.build.id)

]
