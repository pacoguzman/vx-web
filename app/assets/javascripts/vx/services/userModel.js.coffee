Vx.service 'userModel', ['$http', 'cacheService',
  ($http, cacheService) ->

    cache = cacheService("user")

    all: () ->
      cache.fetch "all", () ->
        $http.get("/api/users").then (re) ->
          re.data

    update: (user) ->

      attrs =
        name:  user.name
        email: user.email
      attrs.role = user.role if user.role

      $http
        method: 'PATCH'
        url: "/api/users/#{ user.id }"
        data: { user: attrs }

    destroy: (user) ->
      $http.delete("/api/users/#{ user.id }").then (re) ->
        cache.removeAll "all", user.id
]
