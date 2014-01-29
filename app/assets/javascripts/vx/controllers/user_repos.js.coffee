Vx.controller 'UserReposCtrl', ['$scope', 'appMenu', 'userRepoStore'
  ($scope, menu, userRepos) ->

    menu.define ->
      menu.add 'Manage Projects', '/user_repos'

    $scope.inProgress = false
    $scope.repos      = userRepos.all()
    $scope.query      = null
    $scope.processing = {}

    $scope.changeSubscription = (repo) ->
      repo.inProgress = true
      userRepos.toggleSubscribtion(repo).finally ->
        repo.inProgress = false

    $scope.syncUserRepos = () ->
      $scope.inProgress = true
      userRepos.sync().finally ->
        $scope.inProgress = false

]
