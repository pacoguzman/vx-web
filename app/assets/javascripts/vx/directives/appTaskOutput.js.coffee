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

      colorize = (str) ->
        html = ""
        fragments = ansiparse(str)
        for fragment in fragments
          classes = []
          text = if fragment.text == "" then nbsp else fragment.text
          #fragment.bold && classes.push("ansi-bold")
          fragment.foreground && classes.push("ansi-fg-" + fragment.foreground)
          #fragment.background && classes.push("ansi-bg-" + fragment.background)

          if classes.length > 0
            html += "<span class=\"#{classes.join ' '}\">#{text}</span>"
          else
            html += "<span>#{text}</span>"
        html

      addLineToDom = (line) ->
        el = document.createElement("p")
        el.innerHTML = "<a></a>#{line}"

        elem[0].appendChild el
        el

      processFragment = (mode, line) ->
        line = colorize(line)

        switch mode
          when 'replace'
            lastChild.innerHTML = "<a></a>#{line}"
          when 'append'
            lastChild.innerHTML = lastChild.innerHTML + line
          else
            lastChild = addLineToDom(line)


      updateLines = (newLen, unused) ->
        return unless newLen

        elem.removeClass("hidden")

        return if newLen == 0

        logOutput ||= new VxLib.LogOutput(scope.collection, processFragment)

        if logOutput.positionInCollection > newLen
          elem[0].innerHTML = ""
          logOutput.reset()

        logOutput.process()

      elem.addClass("hidden")

      scope.$watch('collection.length', updateLines)
