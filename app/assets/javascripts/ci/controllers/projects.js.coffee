CI.factory "Project", ['$resource', 'apiPrefix', ($resource, apiPrefix) ->
  $resource(apiPrefix + "/projects/:id", id: '@id')
]

CI.factory "GithubRepo", ['$resource', 'apiPrefix', ($resource, apiPrefix) ->
  $resource(apiPrefix + "/github_repos/:id", id: '@id')
]

CI.controller 'ProjectsCtrl', ['$scope', 'Project', 'appMenu',
  ($scope, Project, appMenu) ->

    appMenu.define()
    $scope.projects = Project.query()
]

CI.controller 'NewProjectCtrl', ['$scope', 'appMenu', 'GithubRepo'
  ($scope, menu, GithubRepo) ->

    menu.define ->
      menu.add 'New Project', '/projects/new'

    $scope.repos = GithubRepo.query()

    $scope.changeSubscription = (value) ->
      console.log value
]
