angular.module('Vx').
  directive 'appSidebarControl', ['$window', 'localStorageService',
    ($window, localStorage) ->
      restrict: 'EC'

      link: (scope, element, attrs) ->

        collapsed = (localStorage.get("vx.sidebar.collapsed") == 'true') || false
        smallBody = false

        toggleNav = () ->
          $body = angular.element($window.document.body)
          if collapsed
            $body.addClass("mini-navbar")
          else
            $body.removeClass("mini-navbar")
          localStorage.set("vx.sidebar.collapsed", collapsed)

        toggleNav()

        toggleSmall = () ->
          $body = angular.element($window.document.body)
          if smallBody
            $body.addClass("body-small")
          else
            $body.removeClass("body-small")

        resizeBody = () ->
          w = $window.innerWidth
          smallBody = (w < 768)
          toggleSmall()

        element.bind 'click', (e) ->
          collapsed = !collapsed
          toggleNav()

        angular.element($window).bind 'resize', (e) ->
          resizeBody()

        angular.element($window).bind 'load', (e) ->
          resizeBody()
  ]
