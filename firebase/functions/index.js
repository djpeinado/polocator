/* eslint-disable no-await-in-loop */
var functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const { google } = require("googleapis");
const people = google.people("v1");

/**
 * Get all contacts (with not empty name & email) from google account by token
 */
exports.getContacts = functions.https.onCall(async (data, context) => {
  console.log("getContacts start");
  try {
    const token = data.token;
    const pageSize = 1000;
    var items = 0;
    var totalItems = 0;
    var pageToken = null;
    var contacts = new Array();
    do {
      const res = await people.people.connections.list({
        access_token: token,
        resourceName: "people/me",
        personFields: "names,emailAddresses",
        pageSize: pageSize,
        pageToken: pageToken,
      });
      totalItems = res.data.totalItems;
      items += res.data.connections.length;
      pageToken = res.data.nextPageToken;
      res.data.connections.forEach((person) => {
        if (
          person.names &&
          person.emailAddresses &&
          person.names.length > 0 &&
          person.names[0].displayName &&
          person.names[0].displayName.trim().length > 0 &&
          person.emailAddresses.length > 0 &&
          person.emailAddresses[0].value &&
          person.emailAddresses[0].value.trim().length > 0
        ) {
          var contact = {
            name: person.names[0].displayName.trim(),
            email: person.emailAddresses[0].value.trim(),
            signedIn: false,
          };
          contacts.push(contact);
        }
      });
    } while (items < totalItems);
    console.log(contacts);
    return {
      contacts: contacts,
    };
  } catch (error) {
    console.log("Caught an error: " + error);
    throw new functions.https.HttpsError("unknown", error.message, error);
  }
});

function sendNotif(pushNotificationId, data) {
  console.log("Sending to " + pushNotificationId + " data: " + data);
  const message = {
    data: data,
    token: pushNotificationId,
  };

  admin
    .messaging()
    .send(message)
    .then((_) => {
      return true;
    })
    .catch((error) => {
      console.log(error);
      return false;
    });
}

/**
 * Request location
 */
exports.requestLocation = functions.https.onCall(async (data, context) => {
  console.log("requestLocation start");
  try {
    const emailTarget = data.emailTarget;
    const email = data.email;
    const encKeyPub = data.keyPublic;
    // Check that email is allowed for emailTarget
    const querySnapshotUser = await admin
      .firestore()
      .collection("users")
      .where("email", "==", emailTarget)
      .get();
    allowed = false;
    if (querySnapshotUser.size > 0) {
      const docUser = querySnapshotUser.docs[0];
      const querySnapshotConnections = await admin
        .firestore()
        .collection("users/" + docUser.id + "/connections")
        .get();
      querySnapshotConnections.forEach((doc) => {
        if (doc.id === email && doc.get("status") === "ALLOWED") {
          allowed = true;
        }
      });
      if (allowed) {
        var pushNotificationId = docUser.data()["pushNotificationId"];
        if (pushNotificationId) {
          const notifDataMap = {
            op: "sendLocation",
            email: email,
            keyPublic: encKeyPub,
          };
          return sendNotif(pushNotificationId, notifDataMap);
        } else {
          console.log(
            "Cannot get pushNotificationId for email: " + emailTarget
          );
          return false;
        }
      }
    }
    return true;
  } catch (error) {
    console.log("Caught an error: " + error);
    throw new functions.https.HttpsError("unknown", error.message, error);
  }
});

/**
 * Send location
 */
exports.sendLocation = functions.https.onCall(async (data, context) => {
  console.log("sendLocation start");
  try {
    const emailTarget = data.emailTarget;
    const email = data.email;
    const encKeyPub = data.keyPublic;
    const notifData = data.data;
    var pushNotificationId = null;
    const querySnapshotPushNotifId = await admin
      .firestore()
      .collection("users")
      .where("email", "==", emailTarget)
      .select("pushNotificationId")
      .get();
    querySnapshotPushNotifId.forEach((doc) => {
      pushNotificationId = doc.get("pushNotificationId");
    });
    if (pushNotificationId) {
      const notifDataMap = {
        op: "responseLocation",
        email: email,
        emailTarget: emailTarget,
        keyPublic: encKeyPub,
        data: notifData,
      };
      return sendNotif(pushNotificationId, notifDataMap);
    } else {
      console.log("Cannot get pushNotificationId for email: " + emailTarget);
      return false;
    }
  } catch (error) {
    console.log("Caught an error: " + error);
    throw new functions.https.HttpsError("unknown", error.message, error);
  }
});
