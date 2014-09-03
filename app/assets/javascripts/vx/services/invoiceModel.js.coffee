Vx.service "invoiceModel", ['$http',
  ($http) ->

    all: () ->
      $http.get("/api/invoices").then (re) ->
        re.data
]
