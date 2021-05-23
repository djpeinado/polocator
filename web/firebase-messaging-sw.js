// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here, other Firebase libraries
// are not available in the service worker.
importScripts('utils.js');
importScripts('config-private.js');
importScripts('config.js');
importScripts(getFirebaseJSModuleURL(FIREBASE_JS_VERSION, 'app'));
importScripts(getFirebaseJSModuleURL(FIREBASE_JS_VERSION, 'messaging'));

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();