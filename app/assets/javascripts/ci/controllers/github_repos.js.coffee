CI.controller 'GithubReposCtrl', ['$scope', 'appMenu', 'Restangular'
  ($scope, menu, $rest) ->

    menu.define ->
      menu.add 'You Github Repos', '/github_repos'

    syncButton = $(".github-repos-sync")

    $scope.repos = $rest.one("api/github_repos").getList()
    $scope.query = null

    $scope.changeSubscription = (repo) ->
      if repo.subscribed
        $rest.one("api/github_repos", repo.id).post("subscribe")
      else
        $rest.one("api/github_repos", repo.id).post("unsubscribe")

    $scope.syncGithubRepos = () ->
      syncButton.addClass("disabled")
      $rest.one("api/github_repos").post("sync").then (repos) ->
        $scope.repos = repos
        syncButton.removeClass("disabled")
]
