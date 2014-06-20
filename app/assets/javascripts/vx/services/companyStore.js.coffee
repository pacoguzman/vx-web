Vx.service 'companyStore', ($http, $q, cacheStore) ->
  USAGE_API_PATH = '/api/companies/usage'

  usage: ->
    $http.get(USAGE_API_PATH).then (response) ->
      response.data
