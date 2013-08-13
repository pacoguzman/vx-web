CI.factory 'appMenu', ($q) ->
  items = [{ title: 'Dashboard', path: '/' }]

  obj = {}

  obj.add = (title, path) ->
    items.push title: title, path: path

  obj.items = () ->
    items

  obj.define = (args...) ->
    promises = _.initial(args)
    f = _.last(args)
    items = [{ title: 'Dashboard', path: '/' }]
    if f
      $q.all(promises).then (its) ->
        f.apply(null, its)

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

