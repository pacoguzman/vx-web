CI.factory "Project", ['$resource', 'apiPrefix', ($resource, apiPrefix) ->
  $resource(apiPrefix + "/projects/:id", id: '@id')
]

CI.controller 'ProjectsCtrl', ['$scope', 'Project', 'appMenu', '$location'
  ($scope, Project, appMenu, $location) ->

    appMenu.define()
    $scope.projects = Project.query()

]
