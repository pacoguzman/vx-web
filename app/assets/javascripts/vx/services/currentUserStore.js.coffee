Vx.service 'currentUserStore',
  ($http, $q) ->

    deferMe = $q.defer()
    me      = deferMe.promise
    loaded  = false

    resolve = (re) ->
      deferMe.resolve(re.data)

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
        url:    "/auth/session"
      )

    get: get
    signOut: signOut
