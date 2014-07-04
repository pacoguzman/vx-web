Vx.service 'companyStore', ($http, $q, cacheStore) ->
  usage: ->
    $http.get('/api/companies/usage').then (response) ->
      response.data

