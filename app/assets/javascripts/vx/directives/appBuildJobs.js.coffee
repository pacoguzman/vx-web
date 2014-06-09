angular.module('Vx').
  directive "appBuildJobs", () ->

    restrict: 'EC'
    replace: true
    scope: {
      jobs: "=jobs",
    }

    template: """
    <table class='table tasks-table' ng-show="display">
      <thead>
        <th>Job</th>
        <th>Duration</th>
        <th>Finished At</th>
        <th ng-repeat='m in matrix' class="hidden-xs">
          {{m}}
        </th>
      </thead>
      <tr class='app-build-jobs-job app-task-status-class tasks-table-item'
          ng-repeat="job in jobs | orderBy:'natural_number'" status="job.status">
        <td>
          <a ng-href='/ui/jobs/{{job.id}}'>
            <i class='fa fa-circle'></i>
            <span>{{ job.number }}</span>
          </a>
        </td>
        <td class="app-task-duration" task="job"></td>
        <td class="app-task-finished" task="job"></td>
        <td ng-repeat='m in job.matrix' class="hidden-xs">
          {{ m | truncate:30 }}
        </td>
      </tr>
    </table>
    """

    link: (scope, elem, attrs) ->
      scope.matrix = []
      scope.display = false

      updateMatrix = (newVal) ->
        if newVal && newVal.length > 0
          scope.display = true
          values = _.pluck(newVal, 'matrix')
          values = _.map(values, (it) -> _.keys(it))
          scope.matrix = _.uniq _.flatten(values).sort()

      scope.$watch("jobs", updateMatrix, true)
