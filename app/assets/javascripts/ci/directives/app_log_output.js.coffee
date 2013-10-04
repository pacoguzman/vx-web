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
        container = document.createElement("div")

        _.each newVal, (it) ->
          unsorted.push it

        scope.lines = _.sortBy unsorted, (it) ->
          it.tm

        output = ""
        _.each scope.lines, (it) ->
          output += it.data

        console.log output

        _.each output.split("\n"), (it) ->
          nbsp = '\u00A0'
          line = if it == "" then nbsp else it.replace(/\ /g, nbsp)
          log = document.createElement("div")
          log.className = "log_line"
          log.style = "min-height:1em"
          logLine = document.createTextNode(line)
          log.appendChild(logLine)
          container.appendChild(log)

        elem.html container.innerHTML

      scope.$watch('object', updateLines, true)
