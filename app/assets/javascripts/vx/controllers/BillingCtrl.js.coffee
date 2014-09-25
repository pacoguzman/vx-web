Vx.controller 'BillingCtrl', ['$scope', 'companyModel', 'invoiceModel', 'creditCardModel',
  ($scope, companyModel, invoiceModel, creditCardModel) ->

    $scope.companyUsage   = null
    $scope.wait           = true
    $scope.creditCard     = { wait: true }
    $scope.newCreditCard  = {}

    creditCardModel.find().then (re) ->
      $scope.creditCard = re
      $scope.creditCard.wait = false

    companyModel.usage()
      .then (usage) ->
        $scope.companyUsage = usage
      .finally ->
        $scope.wait = false

    $scope.editCreditCard = () ->
      $scope.creditCard.edit = true

    $scope.cancelEditCreditCard = () ->
      $scope.creditCard.edit = false

    $scope.createCreditCard = () ->
      creditCardModel.create($scope.newCreditCard, $scope.creditCard.client_token)
        .then (re) ->
          angular.extend $scope.creditCard,re
          $scope.newCreditCard = {}
          $scope.creditCard.edit = false
        .catch (re) ->
          $scope.newCreditCard.errors = re
]

