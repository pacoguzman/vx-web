Vx.service 'userIdentitiesStore', [ "$http",
  ($http) ->

    req = (identity, method, url) ->
      data =
        user_identity:
          login:    identity.login || "",
          password: identity.password || "",
          url:      identity.url || ""

      $http(
        method: method,
        url: url,
        data: data
      )

    updateGitlab = (identity) ->
      identity.wait = true
      req(identity, "PATCH", "/api/user_identities/gitlab/#{identity.id}")
        .success (data) ->
          identity.editable = false
          identity.wait = false
          identity.error = false
        .error (data) ->
          identity.error = "Authentication Failed"
          identity.wait = false

    createGitlab = (identity) ->
      identity.wait = true
      req(identity, "POST", "/api/user_identities/gitlab")
        .success (data) ->
          identity.editable = false
          identity.wait = false
          identity.error = false
          angular.extend identity, data
        .error (data) ->
          identity.error = "Authentication Failed"
          identity.wait = false

    destroyGitlab = (identity, collection) ->
      identity.wait = true
      $http.delete("/api/user_identities/gitlab/#{identity.id}")
        .success (data) ->
          identity.wait = false
          idx = _.indexOf collection, identity
          unless idx < 0
            collection.splice(idx, 1)
        .error (data) ->
          identity.wait = false

    gitlab:
      update: updateGitlab
      create: createGitlab
      destroy: destroyGitlab
  ]
