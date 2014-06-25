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

    attrs =
      name:  user.name,
      email: user.email
    attrs.role = user.role if user.role

    $http
      method: 'PATCH'
      url: "#{ API_PATH }/#{ user.id }",
      data: { user: attrs }

  destroy: (user) ->
    $http.delete("#{ API_PATH }/#{ user.id }").success (response) ->
      cache.item(user.id).remove(CACHE_ID)
