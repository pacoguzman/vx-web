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
        <td ng-repeat='m in matrix' class="hidden-xs">
          {{ job.matrix[m] | truncate:30 }}
        </td>
      </tr>
    </table>
    """

    link: (scope, elem, attrs) ->
      scope.matrix      = []
      scope.display     = false

      updateMatrix = (newVal) ->
        if newVal && newVal.length > 0

          if scope.matrix.length == 0
            values = _.pluck(newVal, 'matrix')
            values = _.map(values, (it) -> _.keys(it))
            scope.matrix = _.uniq _.flatten(values).sort()

          if scope.matrix[0] != 'deploy'
            deployJobs  = _.filter(newVal, (it) -> it.kind == 'deploy')
            if deployJobs.length > 0
              _.each(deployJobs, (it) -> it.matrix['deploy'] = 'Yes')
              scope.matrix.unshift 'deploy'

          scope.display = true


      scope.$watch("jobs", updateMatrix, true)
