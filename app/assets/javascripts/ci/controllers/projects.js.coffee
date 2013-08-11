CI.controller 'ProjectsCtrl', ['$scope', 'projectsService', 'appMenu',

  ($scope, projects, appMenu) ->

    appMenu.define()

    $scope.projects = projects.all()

]
