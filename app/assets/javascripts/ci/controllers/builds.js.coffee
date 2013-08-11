CI.controller 'BuildsCtrl', ['$scope', 'appMenu', 'Restangular', '$routeParams',
  ($scope, menu, $rest, $routeParams) ->

    #$scope.eventSource = new EventSource("/events/projects_1")

    callback = (e) ->
      b = JSON.parse(e.data)
      $scope.builds.forEach (it, idx) ->
        if it.id == b.id
          $scope.builds[idx] = angular.copy b


    project = $rest.one("api/projects", $routeParams.projectId)

    $scope.project = project.get()
    $scope.builds  = project.all("builds").getList()

    $scope.project.then (project) ->
      menu.define ->
        menu.add project.name, "/projects/#{project.id}/builds"

    $scope.createBuild = () ->
      project.all("builds").post().then (build) ->
        $scope.builds.push build

]
