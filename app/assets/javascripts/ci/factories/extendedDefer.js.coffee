angular.module('CI').
  factory "extendedDefer", ['$q',
    ($q)->

      (deferred) ->

        _all = () ->
          deferred.promise

        _index = (id) ->
          id = parseInt(id)
          _all().then (its) ->
            its.map((it) -> it.id).indexOf(id)

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

        {
          all:    _all
          index:  _index
          find:   _find
          update: _update
          delete: _delete
          add:    _add
        }
]
