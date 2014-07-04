Vx.service 'userRepoStore', ['$http',
  ($http) ->

    repos  = $http.get('/api/user_repos').then (re) ->
      re.data

    subscribe = (repo) ->
      $http.post("/api/user_repos/#{repo.id}/subscribe")
        .then (it) ->
          angular.extend repo, it.data
        .finally ->
          repo.wait = false

    unsubscribe = (repo) ->
      $http.post("/api/user_repos/#{repo.id}/unsubscribe")
        .then (it) ->
          repo.subscribed = false
          repo.project_id = null
        .finally ->
          repo.wait = false

    updateSubscribtion = (repo) ->
      repo.wait = true
      if repo.subscribed
        subscribe repo
      else
        unsubscribe repo

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
    updateSubscribtion: updateSubscribtion
]
