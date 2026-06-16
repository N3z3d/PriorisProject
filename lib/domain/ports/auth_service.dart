abstract class IAuthService {
  bool get isSignedIn;
  String? get currentUserId;
  String? get currentUserEmail;
}

class NullAuthService implements IAuthService {
  const NullAuthService();
  @override
  bool get isSignedIn => false;
  @override
  String? get currentUserId => null;
  @override
  String? get currentUserEmail => null;
}
