CI.controller 'BuildCtrl', ['$scope', 'appMenu', 'projectsService', 'buildsService', '$routeParams',
  ($scope, menu, projects, builds, $routeParams) ->

    $scope.build = builds.find $routeParams.buildId

    $scope.build.then (build) ->
      $scope.project = projects.find(build.project_id).then (project) ->
        menu.define ->
          menu.add project.name, "/projects/#{project.id}/builds"
          menu.add "Build ##{build.number}", "/builds/#{build.id}"

]
