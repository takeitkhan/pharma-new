/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, set the maximum number of containers.
setGlobalOptions({ maxInstances: 10 });

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Send notification for "notice" collection
 */
exports.sendNoticeNotification = onDocumentCreated("notice/{docId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }
  const data = snapshot.data();

  const postTitle = data.postTitle || "New Notice";
  const postText = data.postText || "You have a new notice.";
  // It's more reliable to get the ID from the event parameters
  const noticeId = event.params.docId;

  console.log("Notice Data:", { postTitle, postText, noticeId });

  const message = {
    topic: "notice",
    notification: {
      title: postTitle,
      body: postText,
    },
    data: {
      title: postTitle,
      body: postText,
      noticeId: noticeId,
      databaseName: "notice", // Added for client-side routing
    },
    android: {
      priority: "high",
      notification: {
        channelId: "high_priority_notifications",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    },
    apns: {
      headers: {
        "apns-priority": "10",
      },
      payload: {
        aps: {
          sound: "default",
          alert: {
            title: postTitle,
            body: postText,
          },
        },
      },
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("FCM response:", response);
  } catch (error) {
    console.error("FCM send error:", error);
  }
});

/**
 * Send notification for "contractorNotice" collection
 */
exports.sendContractorNoticeNotification = onDocumentCreated("contractorNotice/{docId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }
  const data = snapshot.data();

  const postTitle = data.postTitle || "New Contractor Notice";
  const postText = data.postText || "You have a new contractor notice.";
  const noticeId = event.params.docId;

  console.log("Contractor Notice Data:", { postTitle, postText, noticeId });

  const message = {
    topic: "contractorNotice",
    notification: {
      title: postTitle,
      body: postText,
    },
    data: {
      title: postTitle,
      body: postText,
      noticeId: noticeId,
      databaseName: "contractorNotice", // Added for client-side routing
    },
    android: {
      priority: "high",
      notification: {
        channelId: "high_priority_notifications",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    },
    apns: {
      headers: {
        "apns-priority": "10",
      },
      payload: {
        aps: {
          sound: "default",
          alert: {
            title: postTitle, // Corrected from "New Notice"
            body: postText,
          },
        },
      },
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("FCM response:", response);
  } catch (error) {
    console.error("FCM send error:", error);
  }
});
