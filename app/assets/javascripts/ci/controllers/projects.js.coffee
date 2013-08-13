CI.controller 'ProjectsCtrl', ['$scope', 'projectStore', 'appMenu',

  ($scope, projects, appMenu) ->

    appMenu.define()

    $scope.projects = projects.all()
]
