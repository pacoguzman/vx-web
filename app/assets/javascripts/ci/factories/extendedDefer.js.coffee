angular.module('CI').
  factory "extendedDefer", ['$q',
    ($q)->

      (deferred) ->

        throw "is not a defer object: #{deferred.toString()}" unless deferred.promise

        _all = () ->
          deferred.promise


        _index = (id) ->
          id = parseInt(id)
          if id
            _all().then (its) ->
              i = its.map((it) -> it.id).indexOf(id)
          else
            d = $q.defer()
            d.reject()
            d.promise


        _find = (id) ->
          $q.all([_index(id), _all()]).then ([i,its]) ->
            its[i]


        _update = (id, newVal) ->
          $q.all([_index(id), _all()]).then ([i,its]) ->
            angular.extend its[i], newVal


        _delete = (id) ->
          $q.all([_index(id), _all()]).then ([i,its]) ->
            its.splice(i,1)


        _add = (newVal) ->
          _all().then (its) ->
            its.push newVal


        _flatMap = (f) ->
          promise = _all()
          d       = $q.defer()

          reject = (args...) ->
            d.reject.apply(d, args)
          success = (args...) ->
            d.resolve.apply(d, args)
          resolve = (args...) ->
            newPromise = f.apply(null, args)
            newPromise.then success, reject
          promise.then resolve, reject
          d.promise


        {
          all:     _all
          index:   _index
          find:    _find
          update:  _update
          delete:  _delete
          add:     _add
          flatMap: _flatMap
        }
]
