angular.module('Vx').
  directive "appCurrentUserMenu", (currentUserStore, $window) ->

    restrict: 'EC'
    replace: true
    scope: {}

    template: """
    <div class="dropdown">
      <a role="button" class="app-title dropdown-toggle" href="javascript://">
        {{title}}
        <span class="caret"></span>
      </a>

      <ul class="dropdown-menu app-popup">
        <li>
          <a href="/ui/profile/user">Account Information</a>
          <a href="/ui/profile/identities">Services</a>
        </li>
        <li class="divider"></li>
        <li>
          <a ng-click="signOut()" href="javascript://">Sign Out</a>
        </li>
      </ul>
    </div>
    """

    link: (scope, elem) ->

      scope.title         = null
      scope.user          = null

      currentUserStore.get().then (me) ->
        scope.user = me
        scope.title = me.name

      scope.signOut = () ->
        currentUserStore.signOut().success (data) ->
          $window.location.href = data.location

