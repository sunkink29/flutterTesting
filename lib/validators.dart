String validateEmail(String email) {
  bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  if (!emailValid) {
    return "Enter a Valid Email";
  }
  return null;
}

String validatePassword(String password) {
  if (password.length < 6) {
    return "Enter a Password longer than 6 Characters";
  }
  return null;
}