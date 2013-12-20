angular.module('Vx').
  directive "appTaskOutput", ($window) ->

    restrict: 'EC'
    replace: true
    scope: {
      collection: "=collection",
    }

    template:
      '<div></div>'

    link: (scope, elem, attrs) ->
      scope.lines = []
      scope.output = ""
      nbsp = '\u00A0'
      firstRun = true

      updateLines = (newVal) ->
        return unless newVal

        elem.removeClass("hidden")

        container = document.createElement("div")

        output = _.map(newVal, (it) -> it.data).join("").split("\n")

        _.each output, (it, idx) ->
          numEl = document.createElement("a")
          numEl.className = 'app-tack-output-line-number'
          numEl.href = "#L#{idx + 1}"

          node = document.createElement("span")
          node.appendChild document.createTextNode(if it == "" then nbsp else it)

          lineEl = document.createElement("div")
          lineEl.className = "app-task-output-line"

          lineEl.appendChild numEl
          lineEl.appendChild node

          container.appendChild(lineEl)

        # TODO: avoid html copy
        elem.html container.innerHTML

        unless firstRun
          window.scrollTo 0, elem[0].scrollHeight

        firstRun = false

      elem.addClass("hidden")

      scope.$watch('collection', updateLines, true)
