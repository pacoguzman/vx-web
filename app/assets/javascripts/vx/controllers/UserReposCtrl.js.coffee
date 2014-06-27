Vx.controller 'UserReposCtrl', ['$scope', 'userRepoStore',
  ($scope, userRepos) ->

    $scope.wait       = true
    $scope.repos      = []
    $scope.query      = null
    $scope.processing = {}

    userRepos.all()
      .then (repos) ->
        $scope.repos = repos
      .finally ->
        $scope.wait = false

    $scope.changeSubscription = (repo) ->
      repo.wait = true
      repo.subscribed = !repo.subscribed
      userRepos.toggleSubscribtion(repo).finally ->
        repo.wait = false

    $scope.sync = () ->
      $scope.wait = true
      userRepos.sync().finally ->
        $scope.wait = false

]
