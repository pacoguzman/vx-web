CI.controller 'ProjectsCtrl', ['$scope', 'Restangular', 'appMenu',
  ($scope, $rest, appMenu) ->

    appMenu.define()

    $scope.projects = $rest.all("api/projects").getList()

]
