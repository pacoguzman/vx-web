Vx.controller 'GithubReposCtrl', ['$scope', 'appMenu', 'githubRepoStore'
  ($scope, menu, githubRepo) ->

    menu.define ->
      menu.add 'You Github Repos', '/github_repos'

    $scope.inSync = githubRepo.syncInProgress
    $scope.repos  = githubRepo.all()
    $scope.query  = null

    $scope.changeSubscription = (repo) ->
      if repo.subscribed
        githubRepo.subscribe repo.id
      else
        githubRepo.unsubscribe repo.id

    $scope.syncGithubRepos = githubRepo.sync

]
