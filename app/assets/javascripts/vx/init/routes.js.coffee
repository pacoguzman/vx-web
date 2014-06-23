Vx.config ($routeProvider, $locationProvider) ->

  p = "/ui"

  $routeProvider.
    when(p + '/jobs/:jobId',
      templateUrl: "jobs/show.html",
      controller: "JobCtrl"
    ).
    when(p + '/builds/:buildId',
      templateUrl: "builds/show.html",
      controller: "BuildCtrl"
    ).
    when(p + '/projects/:projectId/builds',
      templateUrl: "builds/index.html",
      controller: "BuildsCtrl"
    ).
    when(p + '/projects/:projectId/pull_requests',
    templateUrl: "pull_requests/index.html",
    controller: "PullRequestsCtrl"
    ).
    when(p + '/projects/:projectId/branches',
    templateUrl: "branches/index.html",
    controller: "BranchesCtrl"
    ).
    when(p + '/projects/:projectId/cached_files',
      templateUrl: "cached_files/index.html",
      controller: "CachedFilesCtrl"
    ).
    when(p + '/user_repos',
      templateUrl: "user_repos/index.html",
      controller: "UserReposCtrl"
    ).
    when(p + '/users',
      templateUrl: 'users/index.html',
      controller: 'UsersCtrl'
    ).
    when(p + '/billing',
      templateUrl: 'billing/index.html',
      controller: 'BillingCtrl'
    ).
    when(p + "/profile/user",
      templateUrl: "profile/user.html",
      controller: "UserProfileCtrl"
    ).
    when(p + "/profile/identities",
      templateUrl: "profile/identities.html",
      controller: "UserIdentitiesCtrl"
    ).
    when(p + '/',
      templateUrl: "projects/index.html",
      controller: "ProjectsCtrl"
    )

  $locationProvider.html5Mode true
