CI.controller 'JobCtrl',
  ($scope, appMenu, projectStore, buildStore, jobStore, jobLogStore, $routeParams) ->

    $scope.job = jobStore.one($routeParams.jobId)

    $scope.build = $scope.job.then (job) ->
      buildStore.one(job.build_id)

    $scope.project = $scope.job.then (job) ->
      projectStore.one(job.project_id)

    $scope.logs = $scope.job.then (job) ->
      jobLogStore.all(job.id)

    appMenu.define $scope.job, $scope.build, $scope.project, (j,b,p) ->
      appMenu.add p.name, "/projects/#{p.id}/builds"
      appMenu.add "Build #{b.number}", "/builds/#{b.id}"
      appMenu.add "Job #{j.number}", "/jobs/#{j.id}"
