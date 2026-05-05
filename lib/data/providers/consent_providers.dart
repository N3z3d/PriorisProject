import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/services/core/consent_service.dart';

final consentServiceProvider = Provider<ConsentService>((ref) => ConsentService());

class ConsentNotifier extends StateNotifier<AsyncValue<bool>> {
  ConsentNotifier(this._service) : super(const AsyncValue.loading()) {
    _load();
  }

  final ConsentService _service;

  Future<void> _load() async {
    try {
      final accepted = await _service.hasAcceptedConsent();
      if (mounted) state = AsyncValue.data(accepted);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> accept() async {
    try {
      await _service.acceptConsent();
      if (mounted) state = const AsyncValue.data(true);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> revoke() async {
    try {
      await _service.revokeConsent();
      if (mounted) state = const AsyncValue.data(false);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }
}

final consentProvider =
    StateNotifierProvider.autoDispose<ConsentNotifier, AsyncValue<bool>>((ref) {
  return ConsentNotifier(ref.watch(consentServiceProvider));
});
