Vx.controller 'JobCtrl', ['$scope', 'projectModel', 'buildModel', 'jobModel', 'jobLogModel', 'job',
  ($scope, projectModel, buildModel, jobModel, jobLogModel, job) ->

    $scope.job     = job
    $scope.build   = null
    $scope.project = null
    $scope.logs    = null
    $scope.matrix = { keys: [], values: [] }

    $scope.waitLogs = true

    $scope.matrix.keys   = _.keys(job.matrix)
    $scope.matrix.values = _.values(job.matrix)

    buildModel.one(job.build_id).then (build) ->
      $scope.build = build

    projectModel.one(job.project_id).then (project) ->
      $scope.project = project

    jobLogModel.all(job.id).then (logs) ->
      $scope.logs = logs
      $scope.waitLogs = false

]
