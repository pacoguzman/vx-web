Vx.controller 'UserReposCtrl', ['$scope', 'appMenu', 'userRepoStore'
  ($scope, menu, userRepos) ->

    menu.define ->
      menu.add 'Manage Projects', '/user_repos'

    $scope.inSync = userRepos.syncInProgress
    $scope.repos  = userRepos.all()
    $scope.query  = null

    $scope.changeSubscription = (repo) ->
      if repo.subscribed
        userRepos.subscribe repo.id
      else
        userRepos.unsubscribe repo.id

    $scope.syncUserRepos = userRepos.sync

]
