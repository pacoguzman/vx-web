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

  $scope.update = userStore.update
  $scope.destroy = userStore.destroy

  $scope.disableEdit = (user) ->
    user.id == $scope.currentUser.id

  $scope.toggleInvitesForm = () ->
    $scope.showInvitesForm = !$scope.showInvitesForm

  $scope.createInvites = () ->
    $scope.invite.wait = true
    inviteStore.create($scope.invite.emails).finally ->
      $scope.invite.emails = null
      $scope.invite.wait   = false
      $scope.toggleInvitesForm()
