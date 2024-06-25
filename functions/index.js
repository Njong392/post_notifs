const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document("packages/{packageId}")
  .onWrite(async (change, context) => {
    const newValue = change.after.data();
    const oldValue = change.before.data();

    // New package added
    if (!oldValue && newValue) {
      await sendNotification(newValue.recipientid, "New Package Added");
    } else if (oldValue && newValue) {
      // Check for due date changes or overdue
      const isDueDatePassed =
        new Date(newValue.DueCollectionDate).getTime() < Date.now();
      if (
        oldValue.DueCollectionDate !== newValue.DueCollectionDate &&
        isDueDatePassed
      ) {
        await sendNotification(
          newValue.recipientid,
          "Package Due Date Overdue"
        );
      }

      // Check for package status change
      if (oldValue.status !== newValue.status) {
        await sendNotification(
          newValue.recipientid,
          `Package status changed to ${newValue.status}`
        );
      }
    }
  });

async function sendNotification(userId, message) {
  // Retrieve the user's FCM token
  const userDoc = await admin.firestore().collection("users").doc(userId).get();

  if (!userDoc.exists) {
    console.log(`No user found with ID: ${userId}`);
    return;
  }

  const userToken = userDoc.data().token;

  if (!userToken) {
    console.log(`No FCM token found for user: ${userId}`);
    return;
  }

  const payload = {
    notification: {
      title: "Package Update",
      body: message,
    },
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      userId: userId,
    },
  };

  admin
    .messaging()
    .sendToDevice(userToken, payload)
    .then((response) => {
      console.log("Successfully sent message:", response);
    })
    .catch((error) => {
      console.log("Error sending message:", error);
    });
}
