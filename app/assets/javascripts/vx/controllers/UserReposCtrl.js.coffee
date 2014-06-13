Vx.controller 'UserReposCtrl', ['$scope', 'appMenu', 'userRepoStore'
  ($scope, menu, userRepos) ->

    menu.define ->
      menu.add 'Manage Projects', '/ui/user_repos'

    $scope.inProgress = false
    $scope.repos      = userRepos.all()
    $scope.query      = null
    $scope.processing = {}

    $scope.changeSubscription = (repo) ->
      repo.wait = true
      userRepos.toggleSubscribtion(repo).finally ->
        repo.wait = false

    $scope.syncUserRepos = () ->
      $scope.inProgress = true
      userRepos.sync().finally ->
        $scope.inProgress = false

]
