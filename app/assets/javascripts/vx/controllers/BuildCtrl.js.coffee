Vx.controller 'BuildCtrl', ['$scope', 'projectModel', 'buildModel', 'build', 'jobModel',
  ($scope, projectModel, buildModel, build, jobModel) ->

    $scope.project     = null
    $scope.build       = build
    $scope.regularJobs = []
    $scope.deployJobs  = []

    projectModel.one(build.project_id).then (project) ->
      $scope.project = project

    jobModel.all(build.id).then (jobs) ->
      $scope.regularJobs = _.filter(jobs, (it) -> it.kind == 'regular')
      $scope.deployJobs  = _.filter(jobs, (it) -> it.kind == 'deploy')

    $scope.restart = () ->
      buildModel.restart(build)

]
