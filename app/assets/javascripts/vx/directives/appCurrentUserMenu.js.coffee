angular.module('Vx').
  directive "appCurrentUserMenu", (currentUserStore) ->

    restrict: 'EC'
    replace: true

    template: """
    <div ng-show="display" class="dropdown">
      <a ng-click="togglePopup()" role="button" class="app-title" href="javascript://">
        {{title}}
        <span class="caret"></span>
      </a>

      <ul class="dropdown-menu app-popup" role="menu" ng-show="isPopup">
        <li>
          <a role="menuitem" href="/profile">Profile</a>
        </li>
        <li class="divider"></li>
        <li>
          <a role="menuitem" href="javascript://">Logout</a>
        </li>
      </ul>
    </div>
    """

    link: (scope, elem) ->

      scope.display       = true
      scope.title         = 'aaaa'
      scope.user          = null
      scope.isPopup       = false

      scope.togglePopup = () ->
        scope.isPopup = !scope.isPopup

      currentUserStore.get().then (me) ->
        scope.user = me
        scope.title = me.name
