angular.module('Vx').
  directive "appSidebar", ['currentUserStore', '$location', '$window',
    (currentUserStore, $location, $window) ->

      restrict: 'EC'
      replace: true
      scope: {
      }

      template: """
      <ul class="nav" id="side-menu">
        <li class="nav-header">
          <div class="profile-element dropdown">
            <span>
              <img ng-src="{{ user.avatar }}" style="width: 48px; height: 48px;">
            </span>

            <a class="dropdown-toggle" href="javascript://">
              <span class="clear">
                <span class="block m-t-xs">
                  <strong>{{ user.name }}</strong>
                </span>
                <span class="text-muted text-as block">
                  {{ currentCompany.name }}
                  <span class="caret" ng-if="user.companies.length > 1"></span>
                </span>
              </span>
            </a>

            <ul class="dropdown-menu animated fadeInRight" ng-if="user.companies.length > 1">
              <li ng-repeat="company in user.companies">
                <a href="javascript://" ng-click="setCompany(company)">{{ company.name }}</a>
              </li>
            </ul>
          </div>

          <div class="logo-element">
            CI
          </div>
        </li>

        <li ng-repeat="it in items" ng-class="isActive(it)" ng-if="canShow(it)">
          <a href="{{ it.href }}">
            <i class="fa fa-{{ it.logo }}"></i>
            <span class="nav-label">{{ it.title }}
          </a>
        </li>
      </ul>
      """

      link: (scope, elem) ->

        scope.user           = null
        scope.currentCompany = null

        scope.items = [
          { title: "Projects",      href: "/ui",            logo: "th-large" },
          { title: "Subscriptions", href: "/ui/user_repos", logo: "star"     },
          { title: "Users",         href: "/ui/users",      logo: "users",   admin: true }
          { title: "Billing",       href: "/ui/billing",    logo: "money",     admin: true }
          { title: "Profile",       href: "/ui/profile",    logo: "user",    admin: true }
        ]

        scope.active = 'Projects'

        scope.isActive = (it) ->
          if scope.active == it.title
            'active'

        scope.canShow  = (it) ->
          if it.admin
            scope.user and scope.user.role == 'admin'
          else
            true

        scope.setCompany = (company) ->
          if scope.currentCompany.id != company.id
            currentUserStore.setDefaultCompany(company.id).then ->
              $window.location = '/ui'

        currentUserStore.get().then (me) ->
          scope.user = me
          scope.currentCompany = _.find(me.companies, (it) -> it.id == me.current_company)

        scope.$on "$routeChangeSuccess", (ev, cur, prev) ->
          switch cur.$$route.controller
            when 'ProjectsCtrl', 'BuildsCtrl', 'BuildCtrl', 'ProjectSettingsCtrl'
              scope.active = 'Projects'
            when 'UserReposCtrl'
              scope.active = 'Subscriptions'
            when 'UsersCtrl'
              scope.active = 'Users'
            when 'UserProfileCtrl'
              scope.active = 'Profile'
            when 'BillingCtrl'
              scope.active = 'Billing'

  ]
