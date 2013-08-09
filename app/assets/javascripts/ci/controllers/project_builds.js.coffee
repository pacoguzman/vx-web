CI.controller 'ProjectBuildsCtrl', ['$scope', 'appMenu', 'Restangular', '$routeParams',
  ($scope, menu, $rest, $routeParams) ->

    name = [$routeParams.aname, $routeParams.bname].join("/")

    $rest.one("api/projects", name).get().then (p) ->
      menu.define ->
        console.log p
        menu.add p.name, "/projects/#{p.name}/builds"
]
