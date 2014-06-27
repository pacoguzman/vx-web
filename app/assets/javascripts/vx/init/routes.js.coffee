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
    when(p + '/projects/:projectId/settings',
      templateUrl: "projects/settings.html",
      controller: "ProjectSettingsCtrl"
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
    when(p + "/profile",
      templateUrl: "user/profile.html",
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
