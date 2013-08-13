CI.service 'githubRepoStore', ['$http', "$q", 'extendedDefer',
    ($http, $q, extendedDefer) ->

      repos      = $q.defer()
      collection = extendedDefer(repos)
      inSync     = false

      $http.get("/api/github_repos").then (re) ->
        repos.resolve(re.data)

      subscribe = (repoId) ->
        $http.post("/api/github_repos/#{repoId}/subscribe")

      unsubscribe = (repoId) ->
        $http.post("/api/github_repos/#{repoId}/unsubscribe")

      sync = () ->
        inSync = true
        $http.post("/api/github_repos/sync").then (re) ->
          collection.all().then (its) ->
            inSync = false
            its = re.data


      syncInProgress = () ->
        inSync


      all:            collection.all
      subscribe:      subscribe
      unsubscribe:    unsubscribe
      sync:           sync
      syncInProgress: syncInProgress
]
