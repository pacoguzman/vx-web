CI.service 'githubRepoStore', ['$http', "$q", 'extendedDefer',
    ($http, $q, extendedDefer) ->

      repos      = null
      collection = null
      inSync     = false

      assignCollection = (re) ->
        repos      = $q.defer()
        repos.resolve re
        collection = extendedDefer(repos)
        re

      assignCollection []

      $http.get("/api/github_repos").then (re) ->
        assignCollection re.data

      subscribe = (repoId) ->
        $http.post("/api/github_repos/#{repoId}/subscribe").then (it) ->
          it.data

      unsubscribe = (repoId) ->
        $http.post("/api/github_repos/#{repoId}/unsubscribe").then (it) ->
          it.data

      sync = () ->
        inSync = true
        $http.post("/api/github_repos/sync").then (re) ->
          inSync = false
          assignCollection re.data

      all = () ->
        collection.all()

      syncInProgress = () ->
        inSync

      all:            all
      subscribe:      subscribe
      unsubscribe:    unsubscribe
      sync:           sync
      syncInProgress: syncInProgress
]
