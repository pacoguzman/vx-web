Vx.service 'currentUserStore', ['$http', '$q', ($http, $q) ->

    deferMe = $q.defer()
    me      = deferMe.promise
    loaded  = false

    resolve = (re) ->
      currentUser = re.data
      currentUser['isAdmin'] = currentUser.role == 'admin'
      deferMe.resolve(currentUser)

    reject  = () ->
      deferMe.reject()

    get = () ->
      unless loaded
        loaded = true
        $http.get("/api/users/me").then(resolve, reject)
      me

    signOut = () ->
      $http(
        method: "DELETE",
        url:    "/users/session"
      )

    setDefaultCompany = (companyId) ->
      $http.post("/api/companies/#{companyId}/default")

    get: get
    signOut: signOut
    setDefaultCompany: setDefaultCompany
]
