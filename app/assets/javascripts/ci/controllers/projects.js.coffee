CI.controller 'ProjectsCtrl', ['$scope', 'Restangular', 'appMenu', '$location'
  ($scope, $rest, appMenu, $location) ->

    appMenu.define()
    $scope.projects = $rest.one("api/projects").getList()

]
