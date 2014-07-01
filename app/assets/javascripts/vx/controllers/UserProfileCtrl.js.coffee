Vx.controller 'UserProfileCtrl', ['$scope', 'currentUserStore', 'userStore', 'userIdentitiesStore', "$window",
  ($scope, currentUserStore, userStore, userIdentitiesStore, $window) ->

    $scope.user       = null
    $scope.identities = []

    $scope.github     = null
    $scope.newGitlab  = null
    $scope.gitlab     = null

    currentUserStore.get().then (me) ->
      $scope.user       = me
      $scope.identities = me.identities
      $scope.github     = _.find(me.identities, (it) -> it.provider == 'github' )

    $scope.updateUser = () ->
      $scope.user.wait = true
      userStore.update($scope.user).finally ->
        $scope.user.wait = false

    $scope.newGitlabForm = (st) ->
      if st
        $scope.newGitlab = {}
      else
        $scope.newGitlab = null

    $scope.editGitlabForm = (id) ->
      $scope.gitlab = id

    $scope.createGitlab = () ->
      if $scope.newGitlab
        userIdentitiesStore.gitlab.create($scope.newGitlab, $scope.identities).then (_) ->
          $scope.newGitlab = null

    $scope.updateGitlab = () ->
      if $scope.gitlab
        userIdentitiesStore.gitlab.update($scope.gitlab).then (_) ->
          $scope.gitlab = null

    $scope.destroyGitlab = () ->
      if $scope.gitlab and $window.confirm("Are you sure?")
        userIdentitiesStore.gitlab.destroy($scope.gitlab, $scope.identities).then (_) ->
          $scope.gitlab = null

]
