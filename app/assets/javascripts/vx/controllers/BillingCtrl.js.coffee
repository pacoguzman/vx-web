Vx.controller 'BillingCtrl', ['$scope', 'companyStore',
  ($scope, companyStore) ->

    $scope.companyUsage = null
    $scope.wait = true

    companyStore.usage()
      .then (usage) ->
        $scope.companyUsage = usage
      .finally ->
        $scope.wait = false
]
