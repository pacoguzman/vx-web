Vx.controller 'NavCtrl', ['$scope', '$location', 'appMenu',
  ($scope, $location, appMenu) ->

    $scope.menu  = appMenu
    $scope.items = []

    $scope.isActive = (item) ->
      item.path == $location.path()

    $scope.$watch 'menu.items()', (newVal, _) ->
      $scope.items = newVal.map (menuItem) ->
        menuItem.active = (menuItem.path == $location.path())
        menuItem

]

