#!/usr/bin/env python3
"""
Script d'analyse de conformité CLAUDE.md pour le projet Prioris
"""

import os
import re
from pathlib import Path
from collections import defaultdict
import json

class ProjectAnalyzer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.violations = defaultdict(list)
        self.stats = {
            'total_files': 0,
            'files_over_500': 0,
            'methods_over_50': 0,
            'total_lines': 0
        }

    def is_excluded(self, file_path: Path) -> bool:
        """Determine if a file should be excluded from analysis (generated/tests)."""
        relative = file_path.relative_to(self.project_root).as_posix()

        generated_patterns = [
            'lib/l10n/',
            'lib/generated/',
            'lib/.dart_tool/',
            'test/.dart_tool/',
            'test/domain/services/persistence/unified_persistence_service_test.dart',
        ]

        filename = file_path.name
        if filename.endswith(('.g.dart', '.freezed.dart', '.mocks.dart', '_config.dart')):
            return True

        # Skip generated localization files
        for pattern in generated_patterns:
            if relative.startswith(pattern):
                return True

        # Skip mockito generated folders
        if '/regression/' in relative and filename.endswith('.dart'):
            return True

        return False

    def analyze_file(self, file_path):
        """Analyse un fichier Dart"""
        if self.is_excluded(file_path):
            return

        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            lines = content.split('\n')

        relative_path = file_path.relative_to(self.project_root)
        line_count = len(lines)

        self.stats['total_files'] += 1
        self.stats['total_lines'] += line_count

        # Vérifier si le fichier dépasse 500 lignes
        if line_count > 500:
            self.stats['files_over_500'] += 1
            self.violations['files_over_500'].append({
                'file': str(relative_path),
                'lines': line_count,
                'excess': line_count - 500
            })

        # Analyser les méthodes
        self.analyze_methods(str(relative_path), content, lines)

    def analyze_methods(self, file_path, content, lines):
        """Analyse les méthodes d'un fichier"""
        # Pattern pour détecter les méthodes/fonctions
        # Simplifié pour Dart: cherche des patterns comme "void methodName(", "String methodName(", etc.
        method_pattern = r'^\s*(?:[\w<>?,\s]+)\s+(\w+)\s*\([^)]*\)\s*(?:async|sync\*)?\s*\{'

        in_method = False
        method_name = None
        method_start = 0
        brace_count = 0

        for i, line in enumerate(lines, 1):
            # Ignorer les commentaires et les lignes vides
            stripped = line.strip()
            if not stripped or stripped.startswith('//') or stripped.startswith('/*'):
                continue

            # Détection de début de méthode
            match = re.match(method_pattern, line)
            if match and not in_method:
                method_name = match.group(1)
                method_start = i
                in_method = True
                brace_count = line.count('{') - line.count('}')
            elif in_method:
                brace_count += line.count('{') - line.count('}')

                # Fin de méthode
                if brace_count == 0:
                    method_length = i - method_start + 1

                    if method_length > 50:
                        self.stats['methods_over_50'] += 1
                        self.violations['methods_over_50'].append({
                            'file': file_path,
                            'method': method_name,
                            'lines': method_length,
                            'start_line': method_start,
                            'end_line': i
                        })

                    in_method = False
                    method_name = None
                    brace_count = 0

    def analyze_project(self):
        """Analyse tous les fichiers Dart du projet"""
        # Analyser lib/
        lib_path = self.project_root / 'lib'
        if lib_path.exists():
            for dart_file in lib_path.rglob('*.dart'):
                self.analyze_file(dart_file)

        # Analyser test/
        test_path = self.project_root / 'test'
        if test_path.exists():
            for dart_file in test_path.rglob('*.dart'):
                self.analyze_file(dart_file)

    def generate_report(self):
        """Génère le rapport d'analyse"""
        report = []
        report.append("=" * 80)
        report.append("RAPPORT D'ANALYSE DE CONFORMITÉ CLAUDE.MD")
        report.append("=" * 80)
        report.append("")

        # Résumé exécutif
        report.append("### 1. RÉSUMÉ EXÉCUTIF")
        report.append("")
        report.append(f"Nombre total de fichiers analysés: {self.stats['total_files']}")
        report.append(f"Total de lignes de code: {self.stats['total_lines']:,}")
        report.append(f"Fichiers dépassant 500 lignes: {self.stats['files_over_500']}")
        report.append(f"Méthodes dépassant 50 lignes: {self.stats['methods_over_50']}")

        conformity = 100 - ((self.stats['files_over_500'] / max(self.stats['total_files'], 1)) * 100)
        report.append(f"Pourcentage de conformité (fichiers): {conformity:.1f}%")
        report.append("")

        # Violations critiques
        critical_count = self.stats['files_over_500'] + self.stats['methods_over_50']
        report.append(f"**Nombre de violations critiques: {critical_count}**")
        report.append("")

        # Fichiers > 500 lignes
        report.append("### 2. VIOLATIONS PAR CATÉGORIE")
        report.append("")
        report.append(f"#### A. Fichiers > 500 lignes ({len(self.violations['files_over_500'])} fichiers)")
        report.append("")
        report.append("| Fichier | Lignes | Dépassement |")
        report.append("|---------|--------|-------------|")

        for violation in sorted(self.violations['files_over_500'], key=lambda x: x['lines'], reverse=True)[:50]:
            report.append(f"| {violation['file']} | {violation['lines']} | +{violation['excess']} |")

        report.append("")

        # Méthodes > 50 lignes
        report.append(f"#### B. Méthodes > 50 lignes ({len(self.violations['methods_over_50'])} méthodes)")
        report.append("")
        report.append("| Fichier | Méthode | Lignes | Ligne début | Ligne fin |")
        report.append("|---------|---------|--------|-------------|-----------|")

        for violation in sorted(self.violations['methods_over_50'], key=lambda x: x['lines'], reverse=True)[:100]:
            report.append(f"| {violation['file']} | {violation['method']} | {violation['lines']} | L{violation['start_line']} | L{violation['end_line']} |")

        report.append("")

        # Top 20 des fichiers prioritaires
        report.append("### 3. TOP 20 DES FICHIERS PRIORITAIRES")
        report.append("")

        # Calculer un score d'impact pour chaque fichier
        file_scores = defaultdict(lambda: {'score': 0, 'violations': [], 'lines': 0})

        for v in self.violations['files_over_500']:
            file_scores[v['file']]['score'] += (v['excess'] // 100) * 10  # 10 points par tranche de 100 lignes
            file_scores[v['file']]['violations'].append(f"Fichier trop grand: {v['lines']}L")
            file_scores[v['file']]['lines'] = v['lines']

        for v in self.violations['methods_over_50']:
            file_scores[v['file']]['score'] += (v['lines'] - 50) // 10  # 1 point par tranche de 10 lignes de méthode
            file_scores[v['file']]['violations'].append(f"Méthode {v['method']}: {v['lines']}L")

        sorted_files = sorted(file_scores.items(), key=lambda x: x[1]['score'], reverse=True)[:20]

        report.append("| Rang | Fichier | Score Impact | Violations |")
        report.append("|------|---------|--------------|------------|")

        for rank, (file, data) in enumerate(sorted_files, 1):
            violations_str = f"{len(data['violations'])} violation(s)"
            report.append(f"| {rank} | {file} | {data['score']} | {violations_str} |")

        report.append("")

        return "\n".join(report)

    def save_json(self, output_file):
        """Sauvegarde les résultats en JSON"""
        data = {
            'stats': self.stats,
            'violations': dict(self.violations)
        }
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

if __name__ == '__main__':
    import sys
    project_path = r'C:\Users\Thibaut\Desktop\PriorisProject'
    analyzer = ProjectAnalyzer(project_path)
    print("Analyse en cours...")
    analyzer.analyze_project()

    report = analyzer.generate_report()
    print(report)

    # Sauvegarder le JSON
    output_json = os.path.join(project_path, 'analysis_results.json')
    analyzer.save_json(output_json)
    print(f"\nRésultats détaillés sauvegardés dans {output_json}")
