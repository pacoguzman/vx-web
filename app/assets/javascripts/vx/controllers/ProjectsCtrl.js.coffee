Vx.controller 'ProjectsCtrl', ['$scope', 'projectStore', '$location',

  ($scope, projects, $location) ->

    $scope.projects = []

    projects.all().then (items) ->
      $scope.projects = items
      if items.length == 0
        $location.path("/ui/user_repos")

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

    $scope.projectCssClass = (project) ->
      if project.last_build
        "project-with-builds"

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

]

