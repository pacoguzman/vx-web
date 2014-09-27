Vx.service "invoiceModel", ['$http', '$window', 'currentUserModel', '$q'
  ($http, $window, currentUserModel, $q) ->

    all: () ->
      $http.get("/api/invoices").then (re) ->
        re.data

]
