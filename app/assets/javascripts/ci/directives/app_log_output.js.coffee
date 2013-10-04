angular.module('CI').
  directive "appLogOutput", () ->

    restrict: 'EA'
    replace: true
    scope: {
      object: "=object",
    }

    template:
      '<div class="job_logs"></div>'

    link: (scope, elem, attrs) ->
      console.log scope
      console.log elem

      scope.lines = []
      scope.output = ""

      updateLines = (newVal, oldVal) ->
        unsorted = []
        _.each newVal, (it) ->
          unsorted.push it
        scope.lines = _.sortBy unsorted, (it) ->
          it.tm

        container = document.createElement("div")

        _.each scope.lines, (it) ->
          line = it.data.replace(/\ /g, '\u00A0') # escape(it.data).replace(/%20/g, '&nbsp;')
          log = document.createElement("div")
          log.className = "log_line"
          logLine = document.createTextNode(line)
          log.appendChild(logLine)
          container.appendChild(log)

        elem.html container.innerHTML

      scope.$watch('object', updateLines, true)
