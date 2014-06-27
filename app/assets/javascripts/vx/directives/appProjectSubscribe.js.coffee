angular.module('Vx').
  directive "appProjectSubscribe", ['currentUserStore', 'projectStore',
    (currentUserStore, projectStore) ->

      restrict: 'EC'
      replace: true
      scope: {
        project: "=project",
        title: "@title"
      }

      template: """
      <a ng-click="subscribe()" class="btn btn-primary">
        <i class="fa fa-eye" style="font-size: 1.2em"></i>
        {{title}}
      </button>
      """

      link: (scope, elem) ->

        scope.subscribed    = false
        scope.subscriptions = []

        btnClass = () ->
          if subscribed
            ''
          else
            'btn-ouline'

        subscribeToProject = () ->
          scope.subscriptions.push scope.project.id
          projectStore.subscribe scope.project.id

        unsubscribeFromProject = () ->
          idx = scope.subscriptions.indexOf(scope.project.id)
          if  idx != -1
            scope.subscriptions.splice(idx, 1)
            projectStore.unsubscribe scope.project.id

        scope.subscribe = () ->
          if scope.project.id
            if scope.subscribed
              unsubscribeFromProject()
            else
              subscribeToProject()

        updateSubscribed = (_) ->
          if scope.project
            scope.subscribed = scope.subscriptions.indexOf(scope.project.id) != -1
            if scope.subscribed
              elem.removeClass("btn-outline")
            else
              elem.addClass("btn-outline")

        scope.$watch("subscriptions", updateSubscribed, true)
        scope.$watch("project", updateSubscribed)

        currentUserStore.get().then (me) ->
          scope.subscriptions = me.project_subscriptions

  ]

