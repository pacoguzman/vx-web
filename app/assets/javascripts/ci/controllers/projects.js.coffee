CI.factory "Project", ['$resource', 'apiPrefix', ($resource, apiPrefix) ->
  $resource(apiPrefix + "/projects/:id", id: '@id')
]

CI.controller 'ProjectsCtrl', ['$scope', 'Project',
  ($scope, Project) ->
    $scope.projects = Project.query()
]
