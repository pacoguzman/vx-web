Vx.controller 'ProfileCtrl', ['$scope', 'appMenu', 'currentUserStore',
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

    $scope.updateGitlabIdentity = (identity) ->
      userIdentitiesStore.gitlab.update(identity)

    $scope.createGitlabIdentity = () ->
      identity = _.clone($scope.newGitlab)
      userIdentitiesStore.gitlab.create(identity).success (data) ->
        gitlab_identities.push identity
        $scope.newGitlab = {}

    $scope.edit = (identity) ->
      identity.error = false
      identity.editable = true

    $scope.cancel = (identity) ->
      identity.editable = false

    appMenu.define ->
      appMenu.add "Profile", "/profile"
  ]
