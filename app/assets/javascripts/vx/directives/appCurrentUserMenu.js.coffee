angular.module('Vx').
  directive "appCurrentUserMenu", (currentUserStore) ->

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
          <a href="/profile/user">User Profile</a>
          <a href="/profile/identities">User Identities</a>
        </li>
        <li class="divider"></li>
        <li>
          <a href="javascript://">Logout</a>
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
