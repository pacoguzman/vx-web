Vx.controller 'UsersCtrl', ($scope, appMenu, userStore, currentUserStore, inviteStore) ->

  appMenu.define ->
    appMenu.add 'Users', '/ui/users'

  $scope.users           = []
  $scope.currentUser     = null
  $scope.showInvitesForm = false
  $scope.invite          = { wait: false, emails: null }
  $scope.wait            = true

  userStore.all()
    .then (users) ->
      $scope.users = users
    .finally ->
      $scope.wait = false

  currentUserStore.get().then (user) ->
    $scope.currentUser = user

  #############################################################################

  $scope.destroy = userStore.destroy

  $scope.updateRole = (user, role) ->
    user.role = role
    userStore.update(user)

  $scope.disableEditRole = (user, role) ->
    (user.id == $scope.currentUser.id) ||
      (user.role == role)

  $scope.disableEdit = (user) ->
    user.id == $scope.currentUser.id

  $scope.classForRole = (user, role) ->
    if user.role == role
      'btn-primary'
    else
      'btn-default'

  $scope.toggleInvitesForm = () ->
    $scope.showInvitesForm = !$scope.showInvitesForm

  $scope.createInvites = () ->
    $scope.invite.wait = true
    inviteStore.create($scope.invite.emails).finally ->
      $scope.invite.emails = null
      $scope.invite.wait   = false
      $scope.toggleInvitesForm()
