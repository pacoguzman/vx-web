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
      scope.lines  = []
      scope.output = ""
      nbsp         = '\u00A0'
      currentIndex = 0

      updateLines = (newLen, oldLen) ->
        return if _.isUndefined(newLen)
        elem.removeClass("hidden")

        newVal = scope.collection

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

        elem[0].innerHTML = container.innerHTML

      elem.addClass("hidden")

      scope.$watch('collection.length', updateLines)
