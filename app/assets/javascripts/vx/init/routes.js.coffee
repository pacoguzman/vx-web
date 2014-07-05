Vx.config ($routeProvider, $locationProvider) ->

  p = "/ui"

  $routeProvider.
    when(p + '/jobs/:jobId',
      templateUrl: "jobs/show.html",
      controller: "JobCtrl",
      resolve:
        job: ['jobModel', '$route',
          (job, $route) ->
            job.one($route.current.params.jobId)
        ]
    ).
    when(p + '/builds/:buildId',
      templateUrl: "builds/show.html",
      controller: "BuildCtrl",
      resolve:
        build: ['buildModel', '$route'
          (build, $route) ->
            build.one($route.current.params.buildId)
        ]
    ).
    when(p + '/projects/:projectId/builds',
      templateUrl: "builds/index.html",
      controller: "BuildsCtrl"
      resolve:
        project: ['projectModel', '$route',
          (project, $route) ->
            project.one($route.current.params.projectId)
        ]
    ).
    when(p + '/projects/:projectId/pull_requests',
    templateUrl: "pull_requests/index.html",
    controller: "PullRequestsCtrl"
    ).
    when(p + '/projects/:projectId/branches',
    templateUrl: "branches/index.html",
    controller: "BranchesCtrl"
    ).
    when(p + '/projects/:projectId/settings',
      templateUrl: "projects/settings.html",
      controller: "ProjectSettingsCtrl"
      resolve:
        project: ['projectModel', '$route',
          (project, $route) ->
            project.one($route.current.params.projectId)
        ]
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
