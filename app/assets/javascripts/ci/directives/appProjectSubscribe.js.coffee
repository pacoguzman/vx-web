angular.module('CI').
  directive "appProjectSubscribe", (currentUserStore, projectStore) ->

    restrict: 'EC'
    replace: true
    scope: {
      project: "=project",
    }

    template: """
    <a class="project-subscribe" href="javascript://" ng-click="subscribe()">
      <i class="fa fa-2x" ng-class="subscriptionClass()" />
    </a>
    """

    link: (scope, elem) ->

      isSubscribed = () ->
        scope.subscriptions.indexOf(scope.project.id) != -1

      subscribeToProject = () ->
        scope.subscriptions.push scope.project.id
        projectStore.subscribe scope.project.id

      unsubscribeFromProject = () ->
        idx = scope.subscriptions.indexOf(scope.project.id)
        if idx != -1
          scope.subscriptions.splice(idx, 1)
        projectStore.unsubscribe scope.project.id

      scope.subscriptions = []

      scope.subscriptionClass = () ->
        if scope.project
          if isSubscribed()
            'fa-star'
          else
            'fa-star-o'

      scope.subscribe = () ->
        if scope.project
          if isSubscribed()
            unsubscribeFromProject()
          else
            subscribeToProject()

      currentUserStore.get().then (me) ->
        scope.subscriptions = me.project_subscriptions

