angular.module('Vx').
  directive "appSignOut", ['currentUserStore', '$window',
    (currentUserStore, $window) ->

      restrict: 'EC'
      replace: false
      transinclude: true

      link: (scope, elem) ->
        elem.bind 'click', (e) ->
          currentUserStore.signOut().then ->
            $window.location = '/ui'
  ]
