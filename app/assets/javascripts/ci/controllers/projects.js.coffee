CI.factory "Project", ['$resource', 'apiPrefix', ($resource, apiPrefix) ->
  $resource(apiPrefix + "/projects/:id", id: '@id')
]

CI.controller 'ProjectsCtrl', ['$scope', 'Project', 'appMenu',
  ($scope, Project, appMenu) ->
    appMenu.define()
    $scope.projects = Project.query()
]

CI.controller 'NewProjectCtrl', ['$scope', 'appMenu'
  ($scope, menu) ->
    menu.define ->
      menu.add 'New Project', '/projects/new'

]
