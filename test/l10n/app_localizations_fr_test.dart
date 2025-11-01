import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/l10n/app_localizations_fr.dart';

void main() {
  group('AppLocalizationsFr duel strings', () {
    final l10n = AppLocalizationsFr();

    test('tooltips and labels are free of mojibake characters', () {
      expect(l10n.duelSkipAction, 'Passer le duel');
      expect(l10n.duelRandomAction, 'R\u00e9sultat al\u00e9atoire');
      expect(l10n.duelShowElo, 'Afficher l\u2019\u00c9lo');
      expect(l10n.duelHideElo, 'Masquer l\u2019\u00c9lo');
      expect(
        l10n.duelModeSummary('Vainqueur', 3),
        'Mode du duel : Vainqueur - 3 cartes',
      );
    });
  });
}
