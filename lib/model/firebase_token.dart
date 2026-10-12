class FirebaseToken {
  String firebaseToken;

  FirebaseToken({
    required this.firebaseToken
  });

  Map<String, String> toJson() => {
    'firebaseToken': firebaseToken
  };
}