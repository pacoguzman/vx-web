Vx.controller 'ProjectsCtrl', ['$scope', 'projectModel', '$location',

  ($scope, projects, $location) ->

    $scope.projects = []

    projects.all().then (items) ->
      $scope.projects = items
      if items.length == 0
        $location.path("/ui/user_repos")

    $scope.projectAuthor = (project) ->
      if project.last_build_at
        project.last_builds[0].author
      else
        project.owner.name

    $scope.projectEventName = (project) ->
      if project.last_build_at
        "#{project.last_builds[0].author} commited"
      else
        "created by #{project.owner.name}"

    $scope.projectLastActionAt = (project) ->
      project.last_build_at || project.created_at

    $scope.projectOrderBy = (project) ->
      if project.last_build_at
        project.last_build_at
      else
        project.created_at

]

