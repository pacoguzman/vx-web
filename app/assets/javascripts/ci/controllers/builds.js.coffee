CI.controller 'BuildsCtrl', ['$scope', 'appMenu', 'Restangular', '$routeParams',
  ($scope, menu, $rest, $routeParams) ->

    name = _.compact([$routeParams.aname, $routeParams.bname]).join("/")
    $scope.eventSource = new EventSource("/events/projects_1")

    callback = (e) ->
      b = JSON.parse(e.data)
      $scope.builds.forEach (it, idx) ->
        if it.id == b.id
          $scope.builds[idx] = angular.copy b


    base = $rest.one("api/projects", name)

    $scope.project = base.get()
    $scope.builds  = base.all("builds").getList()

    $scope.project.then (project) ->
      menu.define ->
        menu.add project.id, "/projects/#{project.id}/builds"

    $scope.createBuild = () ->
      base.all("builds").post().then (build) ->
        $scope.builds.push build

    console.log $scope.eventSource

]
