(function(){
  "use strict";

  // These codes are only for demo (changing theme skin or effects dynamically)
  // They are safe to remove
  $('.btn-dark').click( function() {
  	$('link[href="css/dash-light.css"]').attr('href', 'css/dash.css');
  });

  $('.btn-light').click( function() {
  	$('link[href="css/dash.css"]').attr('href', 'css/dash-light.css');
  });
  

})();