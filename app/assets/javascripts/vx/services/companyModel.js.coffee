Vx.service 'companyModel', ['$http',
  ($http) ->
    usage: ->
      $http.get('/api/companies/usage').then (re) ->
        re.data
]

