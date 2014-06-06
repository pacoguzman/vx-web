Vx.controller 'UsersCtrl', ($scope, appMenu, userStore, currentUserStore, inviteStore) ->
  appMenu.define ->
    appMenu.add 'Users', '/ui/users'

  $scope.update = userStore.update
  $scope.users = userStore.all()

  currentUserStore.get().then (currentUser) ->
    $scope.currentUser = currentUser

  #############################################################################

  $scope.submitForm = () ->
    if $scope.inviteForm.$valid
      inviteStore.create($scope.inviteForm.emails).success ->
        $scope.notice = "Your invite for #{ $scope.inviteForm.emails } was successfully send"

  $scope.showInviteLink = -> $scope.isVisibleInviteLink = true
  $scope.hideInviteLink = -> $scope.isVisibleInviteLink = false
  $scope.canShowInviteLink = -> $scope.isVisibleInviteLink

  $scope.showInviteForm = -> $scope.isVisibleInviteForm = true
  $scope.hideInviteForm = -> $scope.isVisibleInviteForm = false
  $scope.canShowInviteForm = -> $scope.isVisibleInviteForm

  $scope.hideNotice = -> $scope.notice = null
  $scope.canShowNotice = -> $scope.notice && !$scope.canShowInviteForm() && $scope.hideInviteLink

  $scope.showInviteLink()
