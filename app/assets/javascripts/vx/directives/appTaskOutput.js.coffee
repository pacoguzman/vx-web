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
      nbsp      = '\u00A0'
      lastChild = null
      logOutput = null

      appendToLastChild = (str) ->
        fragments = ansiparse(str)
        for fragment in fragments
          classes = []
          text = if fragment.text == "" then nbsp else fragment.text
          fragment.foreground && classes.push("ansi-fg-" + fragment.foreground)

          span = document.createElement("span")
          if classes.length > 0
            span.className = classes.join(" ")
          span.appendChild document.createTextNode(text)
          lastChild.appendChild(span)

      newEmptyElement = () ->
        lastChild = document.createElement("p")
        elem[0].appendChild lastChild
        resetLastChild()

      resetLastChild = () ->
        lastChild.innerHTML = '<a></a>'

      processFragment = (mode, line) ->
        switch mode
          when 'newline'
            newEmptyElement()
          when 'replace'
            resetLastChild()
            appendToLastChild(line)
          when 'append'
            appendToLastChild(line)

      updateLines = (newLen, unused) ->
        return unless newLen

        return if newLen == 0

        logOutput ||= new VxLib.LogOutput(scope.collection, processFragment)

        if logOutput.positionInCollection > newLen
          elem[0].innerHTML = ""
          logOutput.reset()

        logOutput.process()

      scope.$watch('collection.length', updateLines)
