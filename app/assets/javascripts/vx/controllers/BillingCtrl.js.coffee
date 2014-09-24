Vx.controller 'BillingCtrl', ['$scope', 'companyModel', 'invoiceModel', '$window', 'currentUserModel'
  ($scope, companyModel, invoiceModel, $window, currentUserModel) ->

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

    braintreeCallback = (err, nonce) ->
      console.log err
      console.log nonce

    $scope.pay =  (invoice) ->
      $scope.payInvoice = invoice

    $scope.cancelPayInvoice = () ->
      $scope.payInvoice = null

    $scope.makePayment = () ->
      if $window.braintree
        currentUserModel.get().then (me) ->
          client = new $window.braintree.api.Client(clientToken: me.braintree_token)
          p = $scope.payInvoice
          client.tokenizeCard(
            {
              number: p.card,
              expirationDate: p.expired,
              cardholderName: p.name,
              cvv: p.cvv
            },
            braintreeCallback
          )
]

