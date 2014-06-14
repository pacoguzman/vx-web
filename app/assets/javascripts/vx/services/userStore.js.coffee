Vx.service 'userStore', ($http, $q) ->
  all = ->
    $http.get('/api/users').then (response) ->
      response.data

  update = (user) ->
    $http
      method: 'PATCH'
      url: "/api/users/#{ user.id }",
      data: { user: { role: user.role } }

  all: all
  update: update
