CI.controller 'JobCtrl',
  ($scope, appMenu, projectStore, buildStore, jobStore, $routeParams) ->

    $scope.job = jobStore.one($routeParams.jobId)

    $scope.build = $scope.job.then (job) ->
      buildStore.one(job.build_id)

    $scope.project = $scope.job.then (job) ->
      projectStore.one(job.project_id)

    appMenu.define $scope.job, $scope.build, $scope.project, (j,b,p) ->
      appMenu.add p.name, "/projects/#{p.id}/builds"
      appMenu.add "Build #{b.number}", "/builds/#{b.id}"
      appMenu.add "Job #{b.number}.#{j.number}", "/jobs/#{j.id}"
