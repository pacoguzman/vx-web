Vx.config ($routeProvider, $locationProvider) ->

  $routeProvider.
    when('/jobs/:jobId',
      templateUrl: "jobs/show.html",
      controller: "JobCtrl"
    ).
    when('/builds/:buildId',
      templateUrl: "builds/show.html",
      controller: "BuildCtrl"
    ).
    when('/projects/:projectId/builds',
      templateUrl: "builds/index.html",
      controller: "BuildsCtrl"
    ).
    when('/projects/:projectId/pull_requests',
    templateUrl: "pull_requests/index.html",
    controller: "PullRequestsCtrl"
    ).
    when('/projects/:projectId/branches',
    templateUrl: "branches/index.html",
    controller: "BranchesCtrl"
    ).
    when('/projects/:projectId/cached_files',
      templateUrl: "cached_files/index.html",
      controller: "CachedFilesCtrl"
    ).
    when('/user_repos',
      templateUrl: "user_repos/index.html",
      controller: "UserReposCtrl"
    ).
    when("/profile/user",
      templateUrl: "profile/user.html",
      controller: "UserProfileCtrl"
    ).
    when("/profile/identities",
      templateUrl: "profile/identities.html",
      controller: "UserIdentitiesCtrl"
    ).
    when('/',
      templateUrl: "projects/index.html",
      controller: "ProjectsCtrl"
    )

  $locationProvider.html5Mode true
