Vx.controller 'BillingCtrl', ['$scope', 'companyModel', 'invoiceModel',
  ($scope, companyModel, invoiceModel) ->

    $scope.companyUsage   = null
    $scope.invoices       = []
    $scope.payment        = null
    $scope.wait           = true

    companyModel.usage()
      .then (usage) ->
        $scope.companyUsage = usage
      .finally ->
        $scope.wait = false

    invoiceModel.all().then (re) ->
      $scope.invoices = re

    $scope.payInvoice = (invoice) ->
      $scope.payment = invoice

    $scope.cancelPayment = () ->
      $scope.payment = null

    $scope.makePayment = () ->
      invoiceModel.pay($scope.payment)
        .then (re) ->
          oldInvoice = _.findWhere $scope.invoices, id: re.data.id
          if oldInvoice
            angular.extend oldInvoice, re.data
          $scope.payment.success = true
        .catch (err) ->
          $scope.payment.errors = err
]

