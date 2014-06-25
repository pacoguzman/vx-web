Vx.controller 'JobCtrl', ['$scope', 'projectStore', 'buildStore', 'jobStore', 'jobLogStore', '$routeParams',
  ($scope, projectStore, buildStore, jobStore, jobLogStore, $routeParams) ->

    $scope.job     = null
    $scope.build   = null
    $scope.project = null
    $scope.logs    = null
    $scope.matrix = { keys: [], values: [] }

    jobStore.one($routeParams.jobId).then (job) ->
      $scope.job = job

      $scope.matrix.keys   = _.keys(job.matrix)
      $scope.matrix.values = _.values(job.matrix)


      buildStore.one(job.build_id).then (build) ->
        $scope.build = build
      projectStore.one(job.project_id).then (project) ->
        $scope.project = project
      jobLogStore.all(job.id).then (logs) ->
        $scope.logs = logs

]
