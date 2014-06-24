Vx.service 'userStore', ($http, $q, cacheStore) ->
  API_PATH = '/api/users'
  CACHE_ID = 'users'

  cache = cacheStore()
  cachedUsers = cache.collection(CACHE_ID)

  all: ->
    cachedUsers.get ->
      $http.get(API_PATH).then (response) ->
        response.data

  update: (user) ->
    $http
      method: 'PATCH'
      url: "#{ API_PATH }/#{ user.id }",
      data: { user: { role: user.role, id: user.id } }

  destroy: (user) ->
    $http.delete("#{ API_PATH }/#{ user.id }").success (response) ->
      cache.item(user.id).remove(CACHE_ID)
