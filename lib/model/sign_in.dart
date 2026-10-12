class SignIn {
  String? email;
  String? password;

  SignIn({
    this.email,
    this.password
  });

  Map<String, dynamic> toJson() => {
    'username': email,
    'password': password,
  };
}