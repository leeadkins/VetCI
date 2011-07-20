var client;
var subscription;

function handleMessage(message){
  var project = message.project;
  var status = message.status;
  $('#'+ project + ' .status').removeClass('running passed failed').addClass(status);
}

function initializeFaye(channel){
  console.log("Setting up faye with channel: " + channel);
  var ch = (typeof(channel) == 'undefined') ? '/all' : channel;
  client = new Faye.Client('/faye');
  var subscription = client.subscribe(ch, function(message){
    handleMessage(message);
  });
}

function setupBuildToggles(){
  $('.results_toggle').click(function(){
    $(this).siblings('.results').slideToggle();
  });
}


function setupBuildButtons(){
  $('.build_all').click(function(){
    $.post('/command/build_all');
  });
}

$(function(){
  initializeFaye();
  setupBuildToggles(); //if we're on an individual project page.
  setupBuildButtons();
});