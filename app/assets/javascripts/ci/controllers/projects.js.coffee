CI.factory "Project", ['$resource', 'apiPrefix', ($resource, apiPrefix) ->
  $resource(apiPrefix + "/projects/:id", id: '@id')
]

CI.controller 'ProjectsCtrl', ['$scope', 'Project', 'Navigation',
  ($scope, Project, nav) ->
    nav.set()
    $scope.projects = Project.query()
]

CI.controller 'NewProjectCtrl', ['$scope', 'Navigation'
  ($scope, nav) ->
    nav.set(
      ['New Project', '/projects/new']
    )
]
