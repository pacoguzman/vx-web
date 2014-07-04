angular.module('Vx').
  directive "appSignOut", ['currentUserModel', '$window',
    (currentUser, $window) ->

      restrict: 'EC'
      replace: false
      transinclude: true

      link: (scope, elem) ->
        elem.bind 'click', (e) ->
          currentUser.signOut().then ->
            $window.location = '/ui'
  ]
