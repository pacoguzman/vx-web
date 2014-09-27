Vx.service "creditCardModel", ['$http', '$window', '$q'
  ($http, $window, $q) ->

    submitCard = (nonce, deferred, card) ->
      $http.post("/api/credit_card", nonce: nonce)
        .then (re) ->
          deferred.resolve(re.data)
        .catch (re) ->
          if re && re.data && re.data.errors
            deferred.reject(re.data.errors)
          else
            deferred.reject([re])
        .finally () ->
          card.wait = false

    braintreeCallback = (deferred, card) ->
      (err, nonce) ->
        if err
          card.wait = false
          deferred.reject([err])
        else
          submitCard(nonce, deferred, card)

    find: () ->
      $http.get("/api/credit_card").then (re) ->
        re.data

    create: (card, token) ->
      deferrred = $q.defer()

      if $window.braintree and token
            card.wait = true

            client = new $window.braintree.api.Client(clientToken: token)
            client.tokenizeCard(
              {
                number:          card.card,
                expirationMonth: card.month,
                expirationYear:  card.year,
                cardholderName:  card.name,
                cvv:             card.cvv
              },
              braintreeCallback(deferrred, card)
            )

      deferrred.promise

]
