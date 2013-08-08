CI.factory "GithubRepo", ['$resource', 'apiPrefix', ($resource, apiPrefix) ->
  $resource( apiPrefix + "/github_repos/:id/:action",
    { id: '@id' },
    {
      subscribe:   { method: 'POST', params: { action: 'subscribe'   } },
      unsubscribe: { method: 'POST', params: { action: 'unsubscribe' } },
      'sync':      { method: "POST", isArray: true, params: {action: 'sync'} }
    }
  )
]

CI.controller 'GithubReposCtrl', ['$scope', 'appMenu', 'GithubRepo'
  ($scope, menu, GithubRepo) ->

    menu.define ->
      menu.add 'You Github Repos', '/github_repos'

    syncButton = $(".github-repos-sync")

    $scope.repos = GithubRepo.query()

    $scope.changeSubscription = (repo) ->
      if repo.subscribed
        repo.$subscribe()
      else
        repo.$unsubscribe()

    $scope.syncGithubRepos = () ->
      syncButton.addClass("disabled")
      GithubRepo.sync (repos)->
        $scope.repos = repos
        syncButton.removeClass("disabled")
]
