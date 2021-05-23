var functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const { google } = require('googleapis');
const people = google.people('v1');

exports.app_contacts = functions.https.onCall(async (data, context) => {
  console.log('app_contacts start');
  try {

    const token = data.token;
    const pageSize = 1000;
    var items = 0;
    var totalItems = 0;
    var pageToken = null;
    var contacts = new Array();
    do {
      const res = await people.people.connections.list(
        {
          access_token: token,
          resourceName: 'people/me',
          personFields: 'names,emailAddresses,photos',
          pageSize: pageSize,
          pageToken: pageToken
        });
      totalItems = res.data.totalItems;
      items += res.data.connections.length;
      pageToken = res.data.nextPageToken;
      res.data.connections.forEach(function (person) {
        if (person.names &&
          person.emailAddresses &&
          person.names.length > 0 &&
          person.names[0].displayName &&
          person.names[0].displayName.trim().length > 0 &&
          person.emailAddresses.length > 0 &&
          person.emailAddresses[0].value &&
          person.emailAddresses[0].value.trim().length > 0) {
          var contact = {
            'name': person.names[0].displayName.trim(),
            'email': person.emailAddresses[0].value.trim(),
            'signedIn': false
          };
          contacts.push(contact);
        }
      });
    } while (items < totalItems);
    console.log(contacts);
    return {
      'contacts': contacts
    };
    return response;
  }
  catch (error) {
    console.log('Caught an error: ' + error);
    throw new functions.https.HttpsError('unknown', error.message, error);
  }
});