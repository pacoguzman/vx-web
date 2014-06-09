Vx.controller 'UsersCtrl', ($scope, appMenu, userStore, currentUserStore) ->
  appMenu.define ->
    appMenu.add 'Manage Users', '/ui/users'

  $scope.update = userStore.update

  $scope.users = userStore.all()

  currentUserStore.get().then (current_user) ->
    $scope.current_user = current_user
