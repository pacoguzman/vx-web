Vx.service 'currentUserModel', ['$http', 'cacheService',
  ($http, cacheService) ->

    cache = cacheService("currentUser")

    get: () ->
      cache.fetch "me", () ->
        $http.get("/api/users/me").then (re) ->
          re.data

    signOut: () ->
      $http(
        method: "DELETE",
        url:    "/users/session"
      )

    setDefaultCompany: (companyId) ->
      $http.post("/api/companies/#{companyId}/default")
]
