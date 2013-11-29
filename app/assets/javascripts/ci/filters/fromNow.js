angular.module('CI').
  filter('fromNow', function () {
      return function (tm) {
        if (tm) {
          return moment(tm).fromNow();
        } else {
          return "- ; -";
        }
      };
  });
