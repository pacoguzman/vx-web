Vx.service "invoiceModel", ['$http', '$window', 'currentUserModel', '$q'
  ($http, $window, currentUserModel, $q) ->

    payInvoice = (nonce, deferred, payment) ->
      $http.post("/api/invoices/#{payment.id}/pay", nonce: nonce)
        .then (re) ->
          deferred.resolve(re)
        .catch (re) ->
          if re && re.data && re.data.errors
            deferred.reject(re.data.errors)
          else
            deferred.reject([re])
        .finally () ->
          payment.wait = false

    braintreeCallback = (deferred, payment) ->
      (err, nonce) ->
        if err
          payment.wait = false
          deferred.reject([err])
        else
          payInvoice(nonce, deferred, payment)

    all: () ->
      $http.get("/api/invoices").then (re) ->
        re.data

    pay: (payment) ->
      deferrred = $q.defer()

      if $window.braintree
        currentUserModel.get().then (me) ->
          if me.braintree_token
            payment.wait = true

            client = new $window.braintree.api.Client(clientToken: me.braintree_token)
            client.tokenizeCard(
              {
                number:          payment.card,
                expirationMonth: payment.month,
                expirationYear:  payment.year,
                cardholderName:  payment.name,
                cvv:             payment.cvv
              },
              braintreeCallback(deferrred, payment)
            )

      deferrred.promise

]
