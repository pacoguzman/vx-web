Vx.controller 'UsersCtrl', ['$scope', 'userStore', 'currentUserStore', 'inviteStore', "$window",
  ($scope, userStore, currentUserStore, inviteStore, $window) ->

    $scope.users           = []
    $scope.currentUser     = null
    $scope.showInvitesForm = false
    $scope.invite          = { wait: true, emails: null }
    $scope.wait            = true

    userStore.all()
      .then (users) ->
        $scope.users = users
      .finally ->
        $scope.wait = false

    currentUserStore.get().then (user) ->
      $scope.currentUser = user

    #############################################################################

    $scope.destroy = (user) ->
      if $window.confirm("Are you sure?")
        userStore.destroy(user)

    $scope.updateRole = (user, role) ->
      user.role = role
      userStore.update(user)

    $scope.cannotEdit = (user) ->
      user.id == $scope.currentUser.id

    $scope.toggleInvitesForm = () ->
      $scope.showInvitesForm = !$scope.showInvitesForm

    $scope.createInvites = () ->
      $scope.invite.wait = true
      inviteStore.create($scope.invite.emails).finally ->
        $scope.invite.emails = null
        $scope.invite.wait   = false
        $scope.toggleInvitesForm()

  ]
