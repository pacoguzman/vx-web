Vx.controller 'UsersCtrl', ['$scope', 'userModel', 'currentUserModel', 'inviteModel', "$window",
  ($scope, userModel, currentUser, inviteModel, $window) ->

    $scope.users           = []
    $scope.currentUser     = null
    $scope.showInvitesForm = false
    $scope.invite          = { emails: null }
    $scope.wait            = true

    userModel.all()
      .then (users) ->
        $scope.users = users
      .finally ->
        $scope.wait = false

    currentUser.get().then (user) ->
      $scope.currentUser = user

    #############################################################################

    $scope.destroy = (user) ->
      if $window.confirm("Are you sure?")
        userModel.destroy(user)

    $scope.updateRole = (user, role) ->
      user.role = role
      userModel.update(user)

    $scope.cannotEdit = (user) ->
      user.id == $scope.currentUser.id

    $scope.toggleInvitesForm = () ->
      $scope.showInvitesForm = !$scope.showInvitesForm

    $scope.createInvites = () ->
      $scope.invite.wait = true
      inviteModel.create($scope.invite.emails).finally ->
        $scope.invite.emails = null
        $scope.invite.wait   = false
        $scope.toggleInvitesForm()

  ]
