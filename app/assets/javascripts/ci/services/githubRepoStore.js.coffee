CI.service 'githubRepoStore', ['$http', "$q", 'extendedDefer',
    ($http, $q, extendedDefer) ->

      inSync = false
      repos  = []

      $http.get('/api/github_repos').then (re) ->
        repos.push.apply(repos, re.data)

      subscribe = (repoId) ->
        $http.post("/api/github_repos/#{repoId}/subscribe").then (it) ->
          it.data

      unsubscribe = (repoId) ->
        $http.post("/api/github_repos/#{repoId}/unsubscribe").then (it) ->
          it.data

      sync = () ->
        inSync = true
        $http.post("/api/github_repos/sync").then (re) ->
          console.log re
          repos.length = 0
          repos.push.apply(repos, re.data)
          inSync = false

      all = () ->
        repos

      syncInProgress = () ->
        inSync

      all:            all
      subscribe:      subscribe
      unsubscribe:    unsubscribe
      sync:           sync
      syncInProgress: syncInProgress
]
