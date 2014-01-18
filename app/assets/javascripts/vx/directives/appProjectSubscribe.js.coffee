angular.module('Vx').
  directive "appProjectSubscribe", (currentUserStore, projectStore) ->

    restrict: 'EC'
    replace: true
    scope: {
      project: "=project",
    }

    template: """
    <label ng-show="display">
      <input type="checkbox" ng-model="subscribed" ng-change="subscribe()">
      Watch
    </label>
    """

    link: (scope, elem) ->

      subscribeToProject = () ->
        scope.subscriptions.push scope.project.id
        projectStore.subscribe scope.project.id

      unsubscribeFromProject = () ->
        idx = scope.subscriptions.indexOf(scope.project.id)
        if idx != -1
          scope.subscriptions.splice(idx, 1)
        projectStore.unsubscribe scope.project.id

      scope.display       = false
      scope.subscribed    = false
      scope.subscriptions = []

      scope.subscribe = () ->
        if scope.project.id
          if scope.subscribed
            subscribeToProject()
          else
            unsubscribeFromProject()

      updateSubscribed = (_) ->
        if scope.subscriptions && scope.project
          scope.display = true
          scope.subscribed = scope.subscriptions.indexOf(scope.project.id) != -1

      scope.$watch("subscriptions", updateSubscribed, true)
      scope.$watch("project", updateSubscribed)

      currentUserStore.get().then (me) ->
        scope.subscriptions = me.project_subscriptions

