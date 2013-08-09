CI.controller 'BuildsCtrl', ['$scope', 'appMenu', 'Restangular', '$routeParams',
  ($scope, menu, $rest, $routeParams) ->

    name = _.compact([$routeParams.aname, $routeParams.bname]).join("/")

    $rest.one("api/projects", name).get().then (project) ->
      $scope.project = project
      $scope.builds  = project.all("builds").getList()

      menu.define ->
        menu.add project.id, "/projects/#{project.id}/builds"

    $scope.createBuild = () ->
      $scope.project.all("builds").post().then (build) ->
        $scope.builds.push build

]
