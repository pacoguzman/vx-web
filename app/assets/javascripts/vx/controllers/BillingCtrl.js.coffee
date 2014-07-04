Vx.controller 'BillingCtrl', ['$scope', 'companyModel',
  ($scope, companyModel) ->

    $scope.companyUsage = null
    $scope.wait = true

    companyModel.usage()
      .then (usage) ->
        $scope.companyUsage = usage
      .finally ->
        $scope.wait = false
]
