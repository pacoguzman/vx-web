CI.controller 'JobCtrl',
  ($scope, appMenu, projectStore, buildStore, jobStore, $routeParams) ->

    succ = (args...) ->
      console.log "succ"
      console.log args

    fail = (args...) ->
      console.log 'fail'
      console.log args

    $scope.job = jobStore.one($routeParams.jobId).then (job) ->
      $scope.build = buildStore.one(job.build_id).then (build) ->
        $scope.project = projectStore.one(build.project_id).then (project) ->

          appMenu.define job, build, project, (j,b,p) ->
            appMenu.add p.name, "/projects/#{p.id}/builds"
            appMenu.add "Build ##{b.number}", "/builds/#{b.id}"
            appMenu.add "Job ##{b.number}.#{j.number}", "/jobs/#{j.id}"
