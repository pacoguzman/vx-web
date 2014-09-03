Vx.controller 'BillingCtrl', ['$scope', 'companyModel', 'invoiceModel'
  ($scope, companyModel, invoiceModel) ->

    $scope.companyUsage = null
    $scope.invoices     = []
    $scope.payInvoice   = null
    $scope.wait         = true

    companyModel.usage()
      .then (usage) ->
        $scope.companyUsage = usage
      .finally ->
        $scope.wait = false

    invoiceModel.all().then (re) ->
      $scope.invoices = re

    $scope.pay =  (invoice) ->
      $scope.payInvoice = invoice

    $scope.cancelPayInvoice = () ->
      $scope.payInvoice = null
]

