angular.module('Vx').
  directive "appBuildHttpUrl", () ->

    restrict: 'EC'
    replace: true
    scope: {
      build: "=build",
      branch: "@branch"
    }

    link: (scope, elem, attrs) ->
      scope.matrix = []

      updateUrl = (newVal, _) ->
        if newVal
          sha  = newVal.sha.substring(0,8)
          html = ""
          if newVal.http_url
            html = "<a href=\"#{newVal.http_url}\" target=\"_blank\">#{sha}</a>"
          else
            html = sha
          if scope.branch
            html = "#{html} (#{newVal.branch})"

          elem.html(html)

      scope.$watch("build", updateUrl, true)
