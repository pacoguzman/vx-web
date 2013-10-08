angular.module('CI').
  directive "appBuildJobs", () ->

    restrict: 'EC'
    replace: true
    scope: {
      jobs: "=jobs",
    }

    template: """
    <table class='table tasks-table'>
      <thead>
        <th>Job</th>
        <th>Duration</th>
        <th>Finished At</th>
        <th ng-repeat='m in matrix' class="hidden-xs hidden-sm">
          {{m}}
        </th>
      </thead>
      <tr class='app-build-jobs-job app-task-status-class tasks-table-item'
          ng-repeat="job in jobs | orderBy:'number'" status="job.status">
        <td>
          <a ng-href='/jobs/{{job.id}}'>
            <i class='icon-circle'></i>
            <span>{{ job.number }}</span>
          </a>
        </td>
        <td class="app-task-duration" task="job"></td>
        <td class="app-task-finished" task="job"></td>
        <td ng-repeat='m in job.matrix' class="hidden-xs hidden-sm">
          {{ m }}
        </td>
      </tr>
    </table>
    """

    link: (scope, elem, attrs) ->
      scope.matrix = []

      updateMatrix = (newVal) ->
        if newVal
          values = _.pluck(newVal, 'matrix')
          values = _.map(values, (it) -> _.keys(it))
          scope.matrix = _.uniq _.flatten(values).sort()

      scope.$watch("jobs", updateMatrix, true)
