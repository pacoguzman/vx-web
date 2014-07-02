Vx.controller 'UserRepoCtrl', ['$scope', 'userRepoStore', '$timeout',
  ($scope, userRepos, $timeout) ->

    $scope.changeSubscription = (newVal, oldVal) ->
      if oldVal != newVal
        repo = $scope.repo
        userRepos.updateSubscribtion(repo).catch (e) ->
          repo.subscribed = !repo.subscribed

    $scope.$watch 'repo.subscribed', $scope.changeSubscription
]

Vx.controller 'UserReposCtrl', ['$scope', 'userRepoStore',
  ($scope, userRepos) ->

    $scope.wait  = true
    $scope.repos = []
    $scope.query = null

    userRepos.all()
      .then (repos) ->
        $scope.repos = repos
      .finally ->
        $scope.wait = false

    $scope.sync = () ->
      $scope.wait = true
      userRepos.sync().finally ->
        $scope.wait = false
]
