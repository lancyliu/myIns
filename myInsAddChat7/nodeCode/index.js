var firebase = require('firebase-admin');
var request = require('request');

var API_KEY = "AAAAlL6NN_A:APA91bE4pya88QFIgwb1fQPVMTtYTLKA2SJ4Q5EqAZxic5a7BJwNxHGO2qRgwYkavp-by7kI0PUEnOh15uEYT18VT_0VoLIiA8TyD1pPVtLbxfPIE5JMh0yz-3jJiqYidippjHJckgeS";

var serviceAccount = require("./meta.json");

firebase.initializeApp({
	credential: firebase.credential.cert(serviceAccount),
	databaseURL: "https://myinstagram-de3d7.firebaseio.com/"
});
ref = firebase.database().ref();

function listenForNotificationRequests() {
  var requests = ref.child('notificationRequests');
  requests.on('child_added', function(requestSnapshot) {
    var request = requestSnapshot.val();
      sendNotificationToUser(
      request.username, 
      request.message,
	request.sender,
      function() {
        requestSnapshot.ref.remove();
      }
    );
  }, function(error) {
    console.error(error);
  });
};

function sendNotificationToUser(username, message, sender, onSuccess) {
  request({
    url: 'https://fcm.googleapis.com/fcm/send',
    method: 'POST',
    headers: {
      'Content-Type' :' application/json',
      'Authorization': 'key='+API_KEY
    },
    body: JSON.stringify({
      notification: {
        title: "Connect App Notification!",
	text: message,
	sender: sender,
	username: username
      },
      to : "/topics/"+username
      //data: {rideInfo: rideinfo}
    })
  }, function(error, response, body) {
    if (error) { console.error(error); }
    else if (response.statusCode >= 400) { 
      console.error('HTTP Error: '+response.statusCode+' - '+response.statusMessage); 
    }
    else {
      onSuccess();
    }
  });
}

// start listening
listenForNotificationRequests();
