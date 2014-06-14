angular.module('Vx').
  directive "appCurrentUserMenu", (currentUserStore, $window, $http) ->

    restrict: 'EC'
    replace: true
    scope: {}

    template: """
    <div class="dropdown">
      <a role="button" class="app-title dropdown-toggle" href="javascript://">
        {{title}}
        <span class="caret"></span>
      </a>

      <ul class="dropdown-menu app-popup" role="menu">
        <li role="presentation">
          <a href="/ui/profile/user">Account Information</a>
          <a href="/ui/profile/identities">Services</a>
          <a href="/ui/users" ng-show="user.isAdmin">Users</a>
        </li>
        <li role="presentation" class="divider" ng-show="companies"></li>
        <li role="presentation" class="dropdown-header" ng-show="companies">Companies</li>
        <li role="presentation" ng-repeat="company in companies">
          <a ng-click="setCompany(company)" href="javascript://">{{ company.name }}</a>
        </li>
        <li role="presentation" class="divider"></li>
        <li role="presentation">
          <a ng-click="signOut()" href="javascript://">Sign Out</a>
        </li>
      </ul>
    </div>
    """

    link: (scope, elem) ->

      scope.title         = null
      scope.user          = null
      scope.companies     = null

      currentUserStore.get().then (me) ->
        scope.user          = me
        scope.title         = me.name

        if me.companies.length > 1
          scope.companies = _.map me.companies, (it) ->
            it.active = (it.id == me.default_company)
            it

      scope.setCompany = (company) ->
        unless company.active
          $http.post("/api/companies/#{company.id}/default").success ->
            $window.location = "/ui"

      scope.signOut = () ->
        currentUserStore.signOut().success (data) ->
          $window.location.href = data.location

