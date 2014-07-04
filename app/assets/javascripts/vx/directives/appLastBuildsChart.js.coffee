angular.module('Vx').
  directive "appLastBuildsChart", ['$window', '$timeout', "$location"
    ($window, $timeout, $location) ->

      restrict: 'EC'
      scope: {
        project: "=project",
      }

      link: (scope, elem) ->

        scope.builds   = []
        d3             = $window.d3
        moment         = $window.moment
        redrawInterval = 5000
        redrawPromise  = null

        svg = d3.select(elem[0])
                .append("svg")
                .style("width", "100%")
                .style("height", "100%")
                .append("g")
                .attr("scale", "(0,0)")

        hasStartedBuilds = () ->
          _.find(scope.builds, (it) -> it.status == 2)

        pointDuration = (p) ->
          if p.status == 2 # started
            st = moment(p.started_at)
            fn = moment()
            d = fn.diff(st) / 1000
            d
          else
            p.duration

        pointHeight = (x) ->
          (val) ->
            v = x(val.duration)
            if v < 10
              "10%"
            else
              "#{Math.round v}%"

        pointY = (x) ->
          (val) ->
            v = x(val.duration)
            if v < 10
              v = 10
            (100 - Math.round(v)) + "%"

        xScale = (data) ->
          durations = _.pluck(data, 'duration')
          d3.scale.linear()
            .domain([0, d3.max(durations)])
            .range([0, 100])

        toD3Data = () ->
          _.map scope.builds, (it) ->
            {
              duration: pointDuration(it),
              status:   it.status
            }

        redrawChart = () ->
          data = toD3Data()
          x    = xScale(data)

          svg.selectAll("rect")
             .data(toD3Data())
             .attr("y", pointY(x))
             .attr("height", pointHeight(x))

          if hasStartedBuilds()
            redrawPromise = $timeout(redrawChart, redrawInterval)

        drawChart = () ->
          data = toD3Data()
          x    = xScale(data)

          step = 100.0 / scope.builds.length
          if scope.builds.length < 10
            step = 10.0

          fillMap =
            0: 'rgb(209,218,222)' # init
            2: 'rgb(238,183,34)'  # start
            3: 'rgb(35,198,200)'  # pass
            4: 'rgb(239,83,82)'   # fail
            5: 'rgb(239,83,82)'   # error
            6: 'rgb(238,183,34)'  # deploy

          pointFill = (val) ->
            fillMap[val.status]

          svg.selectAll("rect").remove()

          svg.selectAll()
             .data(toD3Data())
             .enter()
             .append("rect")
             .attr("x", (_, i) -> "#{90 - (i * step)}%" )
             .attr("y", pointY(x))
             .attr("height", pointHeight(x))
             .attr("fill", pointFill)
             .attr("width", () -> step + "%" )

          if hasStartedBuilds()
            if redrawPromise
              $timeout.cancel(redrawPromise)
            redrawPromise = $timeout(redrawChart, redrawInterval)

        loadBuilds = (newVal) ->
          return if _.isUndefined(newVal)
          scope.builds = newVal
          drawChart()

        scope.$watch("project.last_builds", loadBuilds, true)
  ]

