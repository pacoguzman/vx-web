Vx.controller 'UserRepoCtrl', ['$scope', 'userRepoModel',
  ($scope, repos) ->

    $scope.changeSubscription = (newVal, oldVal) ->
      if oldVal != newVal
        repo = $scope.repo
        repos.toggle(repo).catch (e) ->
          repo.subscribed = !repo.subscribed

    $scope.$watch 'repo.subscribed', $scope.changeSubscription
]

Vx.controller 'UserReposCtrl', ['$scope', 'userRepoModel',
  ($scope, userRepos) ->

    $scope.wait           = true
    $scope.repos          = []
    $scope.query          = null
    $scope.reposLimit     = 30
    $scope.onlySubscribed = false

    userRepos.all()
      .then (repos) ->
        $scope.repos = repos
      .finally ->
        $scope.wait = false

    $scope.subscribeFilter = (repo) ->
      if $scope.onlySubscribed
        repo.mark
      else
        true

    $scope.sync = () ->
      $scope.wait = true
      userRepos.sync().finally ->
        $scope.wait = false

    $scope.loadMore = () ->
      $scope.reposLimit += 30

    markSubscribed = (newVal, oldVal) ->
      _.each $scope.repos, (repo) ->
        repo.mark = newVal && repo.subscribed && !repo.disabled

    $scope.$watch('onlySubscribed', markSubscribed)
]
