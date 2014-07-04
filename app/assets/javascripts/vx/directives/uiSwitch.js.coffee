# see http://callmenick.com/tutorial-demos/css-toggle-switch/

angular.module('Vx').
  directive "uiSwitch", ['$window',
    ($window) ->

      uniqueId = 0

      restrict: 'C'
      scope:
        value: "=value",
        disabled: "=disabled"

      template: """
        <input id="{{id}}" type="checkbox" class="cmn-toggle cmn-toggle-round-flat" ng-model="value" />
        <label for="{{id}}" />
      """

      link: (scope, elem, attrs) ->

        uniqueId += 1
        scope.id = "ui-switch-#{uniqueId}"

        scope.$watch "disabled", (newVal) ->
          if newVal
            elem.find("input").attr("disabled", 'disabled')
          else
            elem.find("input").removeAttr("disabled")
  ]
