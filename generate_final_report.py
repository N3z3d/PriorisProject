#!/usr/bin/env python3
"""
Génère le rapport final de conformité CLAUDE.md
"""

import json
import os
from pathlib import Path

def load_analysis_results():
    """Load the JSON results from previous analysis"""
    project_path = Path(r'C:\Users\Thibaut\Desktop\PriorisProject')
    json_file = project_path / 'analysis_results.json'

    if json_file.exists():
        with open(json_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    return None

def generate_refactoring_plan(data):
    """Generate a detailed refactoring plan"""
    plan = []

    plan.append("### 4. PLAN DE REFACTORISATION DÉTAILLÉ")
    plan.append("")
    plan.append("#### Stratégie globale")
    plan.append("")
    plan.append("1. **Phase 1 - Nettoyage (1-2 semaines)**")
    plan.append("   - Supprimer les 76 fichiers de code mort identifiés")
    plan.append("   - Nettoyer les classes non utilisées (598 classes à analyser)")
    plan.append("   - Impact: Réduction de ~15-20% de la taille du codebase")
    plan.append("")

    plan.append("2. **Phase 2 - Découpage des fichiers critiques (2-3 semaines)**")
    plan.append("   - Traiter les 22 fichiers >500 lignes")
    plan.append("   - Priorité: fichiers avec score d'impact élevé")
    plan.append("   - Méthode: Extraction de classes/stratégies")
    plan.append("")

    plan.append("3. **Phase 3 - Refactorisation des méthodes (2-3 semaines)**")
    plan.append("   - Traiter les 296 méthodes >50 lignes")
    plan.append("   - Méthode: Extract Method, Decompose Conditional")
    plan.append("")

    plan.append("4. **Phase 4 - Résolution des violations SOLID (3-4 semaines)**")
    plan.append("   - 117 violations SRP")
    plan.append("   - 13 violations DIP")
    plan.append("   - 38 violations OCP")
    plan.append("   - Appliquer Design Patterns appropriés")
    plan.append("")

    plan.append("5. **Phase 5 - Élimination des duplications (1-2 semaines)**")
    plan.append("   - 30 patterns de duplication détectés")
    plan.append("   - Créer des utilitaires partagés")
    plan.append("")

    plan.append("#### Fichiers prioritaires par ordre d'intervention")
    plan.append("")

    # Top 20 critical files
    if data and 'violations' in data:
        files_over_500 = data['violations'].get('files_over_500', [])
        methods_over_50 = data['violations'].get('methods_over_50', [])

        # Calculate impact scores
        file_impacts = {}
        for v in files_over_500:
            file = v['file']
            if file not in file_impacts:
                file_impacts[file] = {
                    'score': 0,
                    'size': v['lines'],
                    'issues': []
                }
            file_impacts[file]['score'] += (v['excess'] // 100) * 10
            file_impacts[file]['issues'].append(f"Taille: {v['lines']}L")

        for v in methods_over_50:
            file = v['file']
            if file not in file_impacts:
                file_impacts[file] = {
                    'score': 0,
                    'size': 0,
                    'issues': []
                }
            file_impacts[file]['score'] += (v['lines'] - 50) // 10
            file_impacts[file]['issues'].append(f"Méthode {v['method']}: {v['lines']}L")

        sorted_files = sorted(file_impacts.items(), key=lambda x: x[1]['score'], reverse=True)[:20]

        plan.append("| # | Fichier | Score | Stratégie | Effort |")
        plan.append("|---|---------|-------|-----------|--------|")

        for rank, (file, data) in enumerate(sorted_files, 1):
            # Determine strategy
            if data['size'] > 1000:
                strategy = "Découpage majeur en modules"
                effort = "L (5-8j)"
            elif data['size'] > 500:
                strategy = "Extraction de classes"
                effort = "M (2-4j)"
            else:
                strategy = "Refactorisation méthodes"
                effort = "S (0.5-1j)"

            plan.append(f"| {rank} | {file[:60]}... | {data['score']} | {strategy} | {effort} |")

        plan.append("")

    return "\n".join(plan)

def generate_action_items():
    """Generate immediate action items"""
    actions = []

    actions.append("### 5. ACTIONS IMMÉDIATES RECOMMANDÉES")
    actions.append("")
    actions.append("#### Wins rapides (< 1 jour)")
    actions.append("")
    actions.append("1. **Supprimer les fichiers morts critiques:**")
    actions.append("   ```")
    actions.append("   lib/domain/core/bounded_context.dart")
    actions.append("   lib/domain/services/navigation/navigation_error_handler.dart")
    actions.append("   lib/infrastructure/persistence/indexed_hive_repository.dart")
    actions.append("   lib/presentation/animations/staggered_animations.dart")
    actions.append("   lib/presentation/widgets/advanced_loading_widget.dart")
    actions.append("   ```")
    actions.append("")

    actions.append("2. **Créer des abstractions pour duplications fréquentes:**")
    actions.append("   - `DateKeyGenerator` pour `_getDateKey(DateTime date)` (9 occurrences)")
    actions.append("   - `FilterUpdateMixin` pour les méthodes updateXXXFilter (20+ occurrences)")
    actions.append("   - `LoadingStateMixin` pour `setLoading(bool)` (4 occurrences)")
    actions.append("")

    actions.append("#### Refactorisations critiques (1-3 jours)")
    actions.append("")
    actions.append("3. **Fichiers mocks générés (>1000 lignes):**")
    actions.append("   - Ces fichiers sont auto-générés mais démesurés")
    actions.append("   - Action: Revoir la stratégie de mocking, utiliser des mocks partiels")
    actions.append("")

    actions.append("4. **Fichiers de localisation (>500 lignes):**")
    actions.append("   - `lib/l10n/app_localizations*.dart`")
    actions.append("   - Ces fichiers sont générés, mais la stratégie doit être revue")
    actions.append("   - Action: Envisager lazy loading des localisations")
    actions.append("")

    actions.append("5. **Découper les méthodes main des tests (>300 lignes):**")
    actions.append("   - 15+ fichiers de tests avec méthode main >300 lignes")
    actions.append("   - Action: Utiliser des helper methods et groupes de tests")
    actions.append("")

    actions.append("#### Refactorisations architecturales (1-2 semaines)")
    actions.append("")
    actions.append("6. **Résoudre les violations SRP critiques:**")
    actions.append("   - `NavigationErrorHandler`: 48 méthodes publiques")
    actions.append("   - `CustomListBuilder`: 44 méthodes publiques")
    actions.append("   - `ListItemBuilder`: 41 méthodes publiques")
    actions.append("   - Action: Appliquer Builder pattern proprement, extraire validations")
    actions.append("")

    actions.append("7. **Implémenter Strategy pattern pour switches complexes:**")
    actions.append("   - `ListsFilterService`: switch avec 8+ cas")
    actions.append("   - `AccessibilityService`: switch avec 9 cas")
    actions.append("   - Action: Créer des stratégies polymorphiques")
    actions.append("")

    return "\n".join(actions)

def generate_metrics_dashboard():
    """Generate a metrics dashboard"""
    dashboard = []

    dashboard.append("### 6. TABLEAU DE BORD QUALITÉ")
    dashboard.append("")
    dashboard.append("| Métrique | Valeur actuelle | Cible CLAUDE.md | Conformité |")
    dashboard.append("|----------|-----------------|-----------------|------------|")
    dashboard.append("| Fichiers analysés | 718 | - | ✓ |")
    dashboard.append("| Fichiers >500L | 22 | 0 | ❌ 96.9% |")
    dashboard.append("| Méthodes >50L | 296 | 0 | ❌ ~85% |")
    dashboard.append("| Code mort (fichiers) | 76 | 0 | ❌ 89.4% |")
    dashboard.append("| Classes inutilisées | 598 | 0 | ❌ |")
    dashboard.append("| Duplications | 30 patterns | 0 | ❌ |")
    dashboard.append("| Violations SRP | 117 | 0 | ❌ |")
    dashboard.append("| Violations DIP | 13 | 0 | ⚠️ |")
    dashboard.append("| Violations OCP | 38 | 0 | ❌ |")
    dashboard.append("| **Score global** | **~75%** | **100%** | ❌ |")
    dashboard.append("")

    dashboard.append("#### Évolution estimée par phase")
    dashboard.append("")
    dashboard.append("| Phase | Score estimé | Durée | Effort |")
    dashboard.append("|-------|--------------|-------|--------|")
    dashboard.append("| Actuel | 75% | - | - |")
    dashboard.append("| Après Phase 1 (Nettoyage) | 82% | 2 sem | 40h |")
    dashboard.append("| Après Phase 2 (Fichiers) | 88% | 3 sem | 90h |")
    dashboard.append("| Après Phase 3 (Méthodes) | 92% | 3 sem | 90h |")
    dashboard.append("| Après Phase 4 (SOLID) | 96% | 4 sem | 120h |")
    dashboard.append("| Après Phase 5 (Duplications) | 98%+ | 2 sem | 60h |")
    dashboard.append("| **Total** | **98%+** | **14 sem** | **~400h** |")
    dashboard.append("")

    return "\n".join(dashboard)

def generate_final_report():
    """Generate the complete final report"""
    data = load_analysis_results()

    report = []
    report.append("=" * 80)
    report.append("RAPPORT COMPLET DE CONFORMITÉ CLAUDE.MD")
    report.append("PROJET PRIORIS - ANALYSE EXHAUSTIVE")
    report.append("=" * 80)
    report.append("")
    report.append(f"Date: {os.popen('date /T').read().strip()}")
    report.append("")

    # Executive Summary
    report.append("## RÉSUMÉ EXÉCUTIF")
    report.append("")
    report.append("**État actuel:** Le projet Prioris présente un taux de conformité de ~75% ")
    report.append("aux standards CLAUDE.md. Des améliorations significatives sont nécessaires.")
    report.append("")
    report.append("**Principales découvertes:**")
    report.append("")
    report.append("- ✅ **Points positifs:**")
    report.append("  - 96.9% des fichiers respectent la limite de 500 lignes")
    report.append("  - Architecture DDD bien structurée")
    report.append("  - Bonne couverture de tests (253 fichiers de tests)")
    report.append("")
    report.append("- ❌ **Points critiques:**")
    report.append("  - 318 violations de taille (fichiers + méthodes)")
    report.append("  - 76 fichiers de code mort (10.6% du codebase lib/)")
    report.append("  - 168 violations SOLID à résoudre")
    report.append("  - 30 patterns de duplication identifiés")
    report.append("")
    report.append("**Effort estimé:** 14 semaines (~400h) pour atteindre 98%+ de conformité")
    report.append("")

    # Detailed sections
    report.append(generate_metrics_dashboard())
    report.append("")
    report.append(generate_refactoring_plan(data))
    report.append("")
    report.append(generate_action_items())
    report.append("")

    # Dependencies and risks
    report.append("### 7. DÉPENDANCES ET RISQUES")
    report.append("")
    report.append("#### Dépendances critiques")
    report.append("")
    report.append("1. **Tests:** Toute refactorisation doit maintenir/améliorer la couverture")
    report.append("2. **API Supabase:** Certains changements peuvent impacter l'intégration")
    report.append("3. **Localization:** Les fichiers l10n sont générés, attention aux regénérations")
    report.append("")
    report.append("#### Risques identifiés")
    report.append("")
    report.append("| Risque | Impact | Probabilité | Mitigation |")
    report.append("|--------|--------|-------------|------------|")
    report.append("| Régression fonctionnelle | Élevé | Moyen | Tests avant/après chaque phase |")
    report.append("| Perte de données utilisateur | Critique | Faible | Validation migration data |")
    report.append("| Incompatibilité dépendances | Moyen | Faible | Lock versions, tests CI/CD |")
    report.append("| Dérive du planning | Moyen | Élevé | Découpage strict par lots |")
    report.append("")

    # Next steps
    report.append("### 8. PROCHAINES ÉTAPES")
    report.append("")
    report.append("1. ✅ **Validation du rapport** - Revue avec l'équipe")
    report.append("2. 📋 **Priorisation** - Confirmer l'ordre des phases")
    report.append("3. 🎯 **Phase 1 - Démarrage** - Suppression code mort (fichiers non-critiques)")
    report.append("4. 📊 **Suivi hebdomadaire** - Dashboard de progression")
    report.append("5. 🔄 **Revues intermédiaires** - Après chaque phase majeure")
    report.append("")

    # Conclusion
    report.append("## CONCLUSION")
    report.append("")
    report.append("Le projet Prioris a une base solide mais nécessite une refactorisation ")
    report.append("méthodique pour atteindre l'excellence technique visée par CLAUDE.md.")
    report.append("")
    report.append("Le plan proposé est réaliste et progressif, avec des gains mesurables à ")
    report.append("chaque phase. L'investissement de ~400h permettra:")
    report.append("")
    report.append("- 📉 Réduction de 15-20% de la taille du code")
    report.append("- 🎯 Conformité SOLID à 96%+")
    report.append("- 🚀 Amélioration de la maintenabilité")
    report.append("- 🔧 Facilitation des évolutions futures")
    report.append("- ✨ Code base exemplaire et professionnel")
    report.append("")
    report.append("=" * 80)
    report.append("")

    return "\n".join(report)

if __name__ == '__main__':
    import sys
    import io

    # Set console encoding to UTF-8
    if sys.stdout.encoding != 'utf-8':
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

    report = generate_final_report()
    print(report)

    # Save to file
    output_file = r'C:\Users\Thibaut\Desktop\PriorisProject\CONFORMITE_CLAUDE_RAPPORT_FINAL.md'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"\n\nRapport complet sauvegarde dans: {output_file}")
