angular.module('Vx').
  directive "appBuildJobs", ['$location',
    ($location) ->

      restrict: 'EC'
      replace: true
      scope: {
        jobs: "=jobs",
      }

      template: """
      <table class='table jobs-table table-hover'>
        <thead>
          <th>Status</th>
          <th>Job</th>
          <th>Duration</th>
          <th>Finished At</th>
          <th ng-repeat='m in matrix' class="hidden-xs">
            {{m}}
          </th>
        </thead>
        <tr ng-repeat="job in jobs | orderBy:'natural_number'" status="job.status"
            ng-click="go(job)" style="cursor: pointer">
          <td>
            <span class="app-task-status" task="job"></span>
          </td>
          <td>
            <span>\#{{ job.number }}</span>
          </td>
          <td class="app-task-duration" task="job"></td>
          <td class="app-task-finished-at" task="job"></td>
          <td ng-repeat='m in matrix' class="hidden-xs">
            {{ job.matrix[m] | truncate:30 }}
          </td>
        </tr>
      </table>
      """

      link: (scope, elem, attrs) ->
        scope.matrix = []

        scope.go = (job) ->
          $location.path("/ui/jobs/#{job.id}")

        updateMatrix = (newVal) ->

          if newVal && newVal.length > 0

            if scope.matrix.length == 0
              values = _.pluck(newVal, 'matrix')
              values = _.map(values, (it) -> _.keys(it))
              scope.matrix = _.uniq _.flatten(values).sort()

            scope.jobs = newVal

        scope.$watch("jobs", updateMatrix, true)
  ]
