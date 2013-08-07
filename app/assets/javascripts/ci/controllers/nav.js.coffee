CI.factory 'appMenu', () ->
  items = [{ title: 'Dashboard', path: '/' }]

  obj = {}

  obj.add = (title, path) ->
    items.push title: title, path: path

  obj.items = () ->
    items

  obj.define = (block) ->
    items = [{ title: 'Dashboard', path: '/' }]
    block() if block

  obj

CI.controller 'NavCtrl', ['$scope', '$location', 'appMenu',
  ($scope, $location, appMenu) ->

    $scope.menu  = appMenu
    $scope.items = appMenu.items()

    $scope.isActive = (item) ->
      item.path == $location.path()

    $scope.$watch 'menu.items()', (newVal, _) ->
      $scope.items = newVal

]

