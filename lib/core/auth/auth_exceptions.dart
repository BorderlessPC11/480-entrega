/// Thrown when sign-in succeeds but the account email is not verified yet.
/// The user remains signed in so [AuthGate] can show the verification screen.
class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException();

  @override
  String toString() => 'EmailNotVerifiedException';
}
