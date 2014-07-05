Vx.service 'userRepoModel', ['$http',
  ($http) ->

    repos = []

    subscribe = (repo) ->
      repo.wait = true
      $http.post("/api/user_repos/#{repo.id}/subscribe")
        .then (it) ->
          angular.extend repo, it.data
        .finally ->
          repo.wait = false

    unsubscribe = (repo) ->
      repo.wait = true
      $http.post("/api/user_repos/#{repo.id}/unsubscribe")
        .then (it) ->
          repo.subscribed = false
          repo.project_id = null
        .finally ->
          repo.wait = false

    all: () ->
      $http.get('/api/user_repos').then (re) ->
        repos = re.data
        repos

    sync: () ->
      $http.post("/api/user_repos/sync")
        .then (re) ->
          repos.length = 0
          repos.push.apply(repos, re.data)

    toggle: (repo) ->
      if repo.subscribed
        subscribe(repo)
      else
        unsubscribe(repo)

]
