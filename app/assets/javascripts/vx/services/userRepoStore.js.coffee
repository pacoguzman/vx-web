Vx.service 'userRepoStore', ['$http',
  ($http) ->

    inSync = false
    repos  = $http.get('/api/user_repos').then (re) ->
      re.data

    subscribe = (repoId) ->
      $http.post("/api/user_repos/#{repoId}/subscribe").then (it) ->
        it.data

    unsubscribe = (repoId) ->
      $http.post("/api/user_repos/#{repoId}/unsubscribe").then (it) ->
        it.data

    sync = () ->
      inSync = true
      $http.post("/api/user_repos/sync").then (re) ->
        repos.then (its) ->
          its.length = 0
          its.push.apply(its, re.data)
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
