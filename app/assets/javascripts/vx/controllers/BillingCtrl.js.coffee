Vx.controller 'BillingCtrl', ($scope, appMenu, companyStore) ->

  $scope.companyUsage = null
  $scope.wait = true

  appMenu.define ->
    appMenu.add 'Billing', '/ui/billing'

  companyStore.usage()
    .then (usage) ->
      $scope.companyUsage = usage
    .finally ->
      $scope.wait = false
