// [Bulkrax v8.2.3 Override]: Bulkrax is still holding onto Turbolinks--we've moved on (L#3).

$( document ).on('DOMContentLoaded', function() {
  
  $( "button#entry_error" ).click(function() {
    $( "#error_trace" ).toggle();
  });

  $( "button#raw_button" ).click(function() {
    $( "#raw_metadata" ).toggle();
  });

  $( "button#parsed_button" ).click(function() {
    $( "#parsed_metadata" ).toggle();
  });
  
})
