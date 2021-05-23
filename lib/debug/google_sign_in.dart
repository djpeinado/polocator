const String kDebugGoogleSignInAuthAccessToken =
    "ya29.A0AfH6SMBkkwr8kA3n5vLmGHqI5h3GjipO1vdnoAwSif63j6eyDgJyaLEAfvvSAnuC_r_MZTiy_PP7Ic9WRYyd5sWdZ_OAPvu-eMVMsGtjw6_KlyKmqh7XfS2ZT8e2598Fu-S3cVaZ1KmuJZUW2QRa_707sYqYmx8Wof-KN3BdV3T1Qg";

const String kDebugGoogleSignInAuthIdToken =
    "eyJhbGciOiJSUzI1NiIsImtpZCI6ImQwNWVmMjBjNDUxOTFlZmY2NGIyNWQzODBkNDZmZGU1NWFjMjI5ZDEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXpwIjoiNjU5MDczNzQzNjMwLXJrZXQ4amM5bnNibDBjaGRlYWpzNDZ0ZGh1bDNmNTBhLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiYXVkIjoiNjU5MDczNzQzNjMwLXJrZXQ4amM5bnNibDBjaGRlYWpzNDZ0ZGh1bDNmNTBhLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTEzNjc2MTM3NTkyODY2OTMyMDY2IiwiZW1haWwiOiJkanBlaW5hZG9AZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJmRkVjYnFpbVUzcktpU3dGWWpfTzR3IiwibmFtZSI6IkFsYmVydG8gUGVpbmFkbyIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS0vQU9oMTRHaFZ1UG9VeDE0TW9rTlJNMlJUWjhQNk9wWVk1WGJCckVsbUtVbDdnZzQ9czk2LWMiLCJnaXZlbl9uYW1lIjoiQWxiZXJ0byIsImZhbWlseV9uYW1lIjoiUGVpbmFkbyIsImxvY2FsZSI6ImVzIiwiaWF0IjoxNjA0MjYwNzczLCJleHAiOjE2MDQyNjQzNzMsImp0aSI6ImFlNzNkMDE5ZmJlNzMwM2IzZGZiMjUzZmUxOTAwY2I2MzE4MWRjNWIifQ.EXKZzk8pgsVa0l0oUiJoCx2-rRELdZrfzuicrB7N2JDD9KchM3eMDF2L30USIb3TSiaViFAsbrOUG0UyfcHRshsDW34_QBs1BvVSBsk1Yr-gLoiuBexV3sHO0qPe42bch7pkEG5-VHYhRb4mwthOXOqSHOx8Awy3_t0NgCN8Vfyu9vakXMRN6huOkt1NLGc3cvGmsO_Gvvxw1vsU_9yLTIBw32O17DyokqfCcDTI_VDVzZmj1yUGc3tNHUZUHhSbvRmCpGMgQqjqM0kepswXE1BN0KmQ8oPJirTWOwSnzaP-rufspiEJRSSmzvdyDXJYeWBC0WWHH0UMRHSE3JHcgw";

const String kDebugGoogleSignInAuthBearerToken =
    "ya29.A0AfH6SMC7cpAIbXZUSzyc5sESEf6b46fnAEsQNHkScexYTVh2vGTyBSgLPCFIiUroY6K8Dkeo-WLX5qmBHRis7k5FG6TXk6Y5-6kD-64-BCTqA3YRerlf6sk5x413wJyxDVKrbCBAZ-EfNTTN4qJBIl8L_oK6OzVzeVNP-Am8aOHX9g";

const String kDebugGoogleSignInUserId = "30qFXAXl6vWK6nuts94SF4LzoE93";

class GoogleSignInAuthentication {
  /// An OpenID Connect ID token that identifies the user.
  String get idToken => kDebugGoogleSignInAuthIdToken;

  /// The OAuth2 access token to access Google services.
  String get accessToken => kDebugGoogleSignInAuthAccessToken;
}

class GoogleSignInAccount {
  final String id = kDebugGoogleSignInUserId;

  GoogleSignInAuthentication _authentication = new GoogleSignInAuthentication();

  Future<GoogleSignInAuthentication> get authentication async {
    return _authentication;
  }

  Future<Map<String, String>> get authHeaders async {
    final String token = kDebugGoogleSignInAuthBearerToken;
    return <String, String>{
      "Authorization": "Bearer $token",
      "X-Goog-AuthUser": "0",
    };
  }
}

class GoogleSignIn {
  GoogleSignInAccount _currentUser = new GoogleSignInAccount();
  GoogleSignInAccount get currentUser => _currentUser;

  GoogleSignIn({scopes = const <String>[]});

  Future<GoogleSignInAccount> signInSilently() async {
    return _currentUser;
  }

  Future<GoogleSignInAccount> signIn() async {
    return _currentUser;
  }

  Future<GoogleSignInAccount> signOut() async {
    return _currentUser;
  }
}
