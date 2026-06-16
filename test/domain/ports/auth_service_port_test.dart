import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/ports/auth_service.dart';

class FakeAuthService implements IAuthService {
  final bool _signedIn;
  final String? _userId;
  final String? _email;

  FakeAuthService({bool signedIn = false, String? userId, String? email})
      : _signedIn = signedIn,
        _userId = userId,
        _email = email;

  @override
  bool get isSignedIn => _signedIn;

  @override
  String? get currentUserId => _userId;

  @override
  String? get currentUserEmail => _email;
}

void main() {
  group('IAuthService port', () {
    test('FakeAuthService implémente IAuthService', () {
      final IAuthService fake =
          FakeAuthService(signedIn: true, userId: 'u1', email: 'a@b.com');
      expect(fake.isSignedIn, isTrue);
      expect(fake.currentUserId, equals('u1'));
      expect(fake.currentUserEmail, equals('a@b.com'));
    });

    test('isSignedIn retourne false par défaut', () {
      final fake = FakeAuthService();
      expect(fake.isSignedIn, isFalse);
    });

    test('currentUserId reflète la valeur configurée', () {
      final fake = FakeAuthService(userId: 'user-123');
      expect(fake.currentUserId, equals('user-123'));
    });

    test('currentUserEmail reflète la valeur configurée', () {
      final fake = FakeAuthService(email: 'test@example.com');
      expect(fake.currentUserEmail, equals('test@example.com'));
    });

    test('currentUserId est null par défaut', () {
      final fake = FakeAuthService();
      expect(fake.currentUserId, isNull);
    });

    test('currentUserEmail est null par défaut', () {
      final fake = FakeAuthService();
      expect(fake.currentUserEmail, isNull);
    });
  });
}
