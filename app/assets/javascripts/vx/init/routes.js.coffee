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
    when('/projects/:projectId/cached_files',
      templateUrl: "cached_files/index.html",
      controller: "CachedFilesCtrl"
    ).
    when('/user_repos',
      templateUrl: "user_repos/index.html",
      controller: "UserReposCtrl"
    ).
    when("/profile",
      templateUrl: "profile/show.html",
      controller: "ProfileCtrl"
    ).
    when('/',
      templateUrl: "projects/index.html",
      controller: "ProjectsCtrl"
    )

  $locationProvider.html5Mode true
