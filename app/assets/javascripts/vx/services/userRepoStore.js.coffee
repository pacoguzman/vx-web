Vx.service 'userRepoStore', ['$http',
  ($http) ->

    repos  = $http.get('/api/user_repos').then (re) ->
      re.data

    subscribe = (repoId) ->
      $http.post("/api/user_repos/#{repoId}/subscribe").then (it) ->
        it.data

    unsubscribe = (repoId) ->
      $http.post("/api/user_repos/#{repoId}/unsubscribe").then (it) ->
        it.data

    toggleSubscribtion = (repo) ->
      if repo.subscribed
        subscribe repo.id
      else
        unsubscribe repo.id

    sync = () ->
      $http.post("/api/user_repos/sync")
        .then (re) ->
          repos.then (its) ->
            its.length = 0
            its.push.apply(its, re.data)

    all = () ->
      repos

    all:                all
    sync:               sync
    toggleSubscribtion: toggleSubscribtion
]
