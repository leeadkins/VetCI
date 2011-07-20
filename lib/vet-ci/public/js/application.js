var client;
var subscription;


function initializeFaye(channel){
  console.log("Setting up faye with channel: " + channel);
  var ch = (typeof(channel) == 'undefined') ? '/all' : channel;
  client = new Faye.Client('/faye');
  var subscription = client.subscribe(ch, function(message){
    console.log(message);
  });
}

function setupBuildToggles(){
  $('.results_toggle').siblings('.results').slideToggle();
}

$(function(){
  initializeFaye();
  setupBuildToggles(); //if we're on an individual project page.
});