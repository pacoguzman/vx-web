CI.factory 'Navigation', () ->
  items = [{ title: 'Dashboard', path: '/' }]

  set: (values) ->
    items = [{ title: 'Dashboard', path: '/' }]
    if values
      console.log values
      $.each values, (idx,it) ->
        items.push title: it[0], path: it[1]

  list: () ->
    items

CI.controller 'NavCtrl', ['$scope', '$location', 'Navigation',
  ($scope, $location, nav) ->

    $scope.navigation = nav

    console.log nav.list()

    $scope.isActive = (item) ->
      item.path == $location.path()

    $scope.$watch 'navigation'

]

