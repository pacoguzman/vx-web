CI.controller 'BuildCtrl', ['$scope', 'appMenu', 'Restangular', '$routeParams',
  ($scope, menu, $rest, $routeParams) ->

    $scope.build = $rest.one("api/builds", $routeParams.buildId).get().then (build) ->

      $scope.project = $rest.one("api/projects", build.project_id).get().then (project) ->

        menu.define ->
          menu.add project.name, "/projects/#{project.id}/builds"
          menu.add "Build ##{build.number}", "/builds/#{build.id}"

]
