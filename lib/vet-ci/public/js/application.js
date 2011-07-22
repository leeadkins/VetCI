var client;
var subscription;

function handleMessage(message){
  var project = message.project;
  var status = message.status;
  $('#'+ project + ' .status').removeClass('running passed failed').addClass(status);
}

function initializeFaye(channel){
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
  
  $('.build_project').click(function(){
    var project = $(this).closest('.project').attr('id');
    if(typeof(project) != 'undefined'){
      $.post('/' + project + '/build');
    }
  });
}

function linkProjectCells(){
  $('.project').click(function(){
    var project = $(this).attr('id');
    if(typeof(project) != 'undefined'){
      window.location = "/" + project;
    }
  });
}

$(function(){
  initializeFaye();
  setupBuildToggles(); //if we're on an individual project page.
  setupBuildButtons();
});