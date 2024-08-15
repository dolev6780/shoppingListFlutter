
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNewListNotification = functions.firestore
  .document('users/{userId}/lists/{listId}')
  .onCreate((snap, context) => {
    const newValue = snap.data(); // Get the data from the newly created document
    const userId = context.params.userId; // Extract the userId from the context parameters

    // Retrieve the FCM token for the user
    return admin.firestore().collection('users').doc(userId).get().then(userDoc => {
      const fcmToken = userDoc.data().fcmToken;

      // Define the notification payload
      const payload = {
        notification: {
          title: "New Shopping List",
          body: `You've received a new list from ${newValue.createdBy}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK", // Action to handle on the client side
          listId: context.params.listId,
          createdBy: newValue.createdBy,
        }
      };

      // Send the notification to the user's device using the FCM token
      return admin.messaging().sendToDevice(fcmToken, payload);
    }).catch(error => {
      console.error('Error sending notification:', error);
    });
  });
