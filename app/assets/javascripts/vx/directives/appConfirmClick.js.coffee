angular.module('Vx').
  directive 'appConfirmClick', ->
    priority: 1
    terminal: true
    link: (scope, element, attrs) ->
      element.bind 'click', (e) ->
        clickAction = attrs.ngClick
        message = attrs.appConfirmClick
        if message and confirm(message)
          scope.$eval(clickAction)


