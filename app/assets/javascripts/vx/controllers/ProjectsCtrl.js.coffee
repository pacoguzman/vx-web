Vx.controller 'ProjectsCtrl', ['$scope', 'projectStore', 'buildStore', '$location',

  ($scope, projects, builds, $location) ->

    $scope.projects = []
    $scope.builds = []

    projects.all().then (projects) ->
      $scope.projects = projects

    builds.queued().then (builds) ->
      $scope.builds = builds

    $scope.projectAvatar = (project) ->
      switch
        when project.last_build
          project.last_build.author_avatar
        when project.owner
          project.owner.avatar

    $scope.projectAuthor = (project) ->
      switch
        when project.last_build
          project.last_build.author
        when project.owner
          project.owner.name

    $scope.projectLastAction = (project) ->
      switch
        when project.last_build
          "commited to"
        else
          "creates"

    $scope.projectLastActionAt = (project) ->
      switch
        when project.last_build
          project.last_build_at
        else
          project.created_at

    $scope.projectOrderBy = (project) ->
      if project.last_build
        project.last_build.created_at
      else
        project.created_at

    $scope.go = (project) ->
      if project.last_build
        $location.path("/ui/builds/#{project.last_build.id}")

    $scope.goBuild = (build) ->
      $location.path("/ui/builds/#{build.id}")

]
