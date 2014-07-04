Vx.controller 'ProjectsCtrl', ['$scope', 'projectStore', '$location',

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

    $scope.projectLastAction = (project) ->
      if project.last_build_at
        "commited to"
      else
        "creates"

    $scope.projectEventName = (project) ->
      if project.last_build_at
        "#{project.last_builds[0].author} commited"
      else
        "creaated by #{project.owner.name}"

    $scope.projectLastActionAt = (project) ->
      project.last_build_at || project.created_at

    $scope.projectOrderBy = (project) ->
      if project.last_build_at
        project.last_build_at
      else
        project.created_at

    $scope.projectGotoUrl = (project) ->
      if project.last_build_at
        "/ui/builds/#{project.last_builds[0].id}"
      else
        "/ui/projects/#{project.id}"
]

