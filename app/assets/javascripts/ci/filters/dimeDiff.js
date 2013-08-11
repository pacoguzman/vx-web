angular.module('CI').
  filter('timeDiff', function() {
    return function(dateString1, dateString2) {
      if (dateString1 && dateString2) {
        a = moment(dateString1)
        b = moment(dateString2)
        return b.from(a)
      }
    };
});
