Vx.controller 'UserIdentitiesCtrl', ['$scope', 'appMenu', 'currentUserStore',
  "userIdentitiesStore",
  ($scope, appMenu, currentUserStore, userIdentitiesStore) ->

    $scope.user              = null
    $scope.github_identity   = null
    $scope.gitlab_identities = []
    $scope.newGitlab         = {}

    currentUserStore.get().then (me) ->
      $scope.user = me

      $scope.github_identity = _(me.identities).find (it) ->
        it.provider == 'github'

      $scope.gitlab_identities = _(me.identities).filter (it) ->
        it.provider == 'gitlab'

    $scope.updateGitlab = (identity) ->
      userIdentitiesStore.gitlab.update(identity)

    $scope.createGitlab = () ->
      userIdentitiesStore.gitlab.create($scope.newGitlab).success (data) ->
        identity = _.clone($scope.newGitlab)
        $scope.gitlab_identities.push identity
        $scope.newGitlab = {}

    $scope.edit = (identity) ->
      identity.error = false
      identity.editable = true

    $scope.cancel = (identity) ->
      identity.editable = false

    $scope.destroy = (identity) ->
      userIdentitiesStore.gitlab.destroy(identity, $scope.gitlab_identities)

    appMenu.define ->
      appMenu.add "Services", "/ui/profile/identities"
  ]
