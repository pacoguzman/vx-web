angular.module('Vx').
  factory 'appMenu', ($q) ->
    items = []

    obj = {}

    obj.add = (title, path) ->
      items.push title: title, path: path

    obj.items = () ->
      items

    obj.reset = () ->
      items = [{ title: 'Dashboard', path: '/ui/' }]

    obj.define = (args...) ->
      promises = _.initial(args)
      f = _.last(args)
      if f
        if promises && !_.isEmpty(promises) && promises[0].then
          $q.all(promises).then (its) ->
            obj.reset()
            f.apply(null, its)
        else
          obj.reset()
          f.apply null, promises
      else
        obj.reset()

    obj

