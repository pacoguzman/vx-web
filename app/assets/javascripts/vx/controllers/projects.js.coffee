Vx.controller 'ProjectsCtrl', ['$scope', 'projectStore', 'buildStore', 'appMenu',

  ($scope, projects, builds, appMenu) ->

    appMenu.define()

    $scope.projects = projects.all()
    $scope.builds = builds.queued()
]
