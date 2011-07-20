var client;
var subscription;


var initializeFaye(channel){
  var ch = (typeof(channel) == undefined) ? '/all' : channel;
  client = new Faye.Client('/faye');
  var subscription = client.subscribe(channel, function(message){
    console.log(message);
  });
}

$(function(){
  initializeFaye();
});