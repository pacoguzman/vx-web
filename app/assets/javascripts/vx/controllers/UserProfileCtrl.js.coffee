Vx.controller 'UserProfileCtrl', ['$scope', 'appMenu', 'currentUserStore',
  ($scope, appMenu, currentUserStore) ->

    $scope.user              = null

    currentUserStore.get().then (me) ->
      $scope.user = me

    appMenu.define ->
      appMenu.add "Account Information", "/ui/profile/user"
  ]
