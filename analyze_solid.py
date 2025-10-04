#!/usr/bin/env python3
"""
Analyse des violations SOLID
"""

import os
import re
from pathlib import Path
from collections import defaultdict
import json

class SOLIDAnalyzer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.violations = []

    def analyze_srp_violations(self):
        """Analyse des violations du Single Responsibility Principle"""
        srp_violations = []

        lib_path = self.project_root / 'lib'
        if not lib_path.exists():
            return srp_violations

        for dart_file in lib_path.rglob('*.dart'):
            try:
                with open(dart_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()

                relative_path = str(dart_file.relative_to(self.project_root))

                # Heuristiques pour détecter SRP violations
                # 1. Trop de méthodes publiques
                public_methods = len(re.findall(r'^\s*(?!_)\w+\s+\w+\s*\(', content, re.MULTILINE))

                # 2. Trop de dépendances (imports)
                imports = len(re.findall(r"import\s+['\"]", content))

                # 3. Classe qui fait plusieurs choses (détection de mots-clés)
                responsibilities = 0
                keywords = ['Repository', 'Service', 'Controller', 'Manager', 'Handler', 'Provider', 'Builder']
                class_name_match = re.search(r'class\s+(\w+)', content)

                if class_name_match:
                    class_name = class_name_match.group(1)

                    for keyword in keywords:
                        if keyword in class_name:
                            responsibilities += 1

                    # Détection de plusieurs responsabilités
                    if responsibilities > 1:
                        srp_violations.append({
                            'file': relative_path,
                            'class': class_name,
                            'reason': f"Classe avec plusieurs responsabilités détectées: {responsibilities}",
                            'severity': 'high'
                        })

                    # Trop de méthodes publiques
                    if public_methods > 15:
                        srp_violations.append({
                            'file': relative_path,
                            'class': class_name,
                            'reason': f"Trop de méthodes publiques: {public_methods}",
                            'severity': 'medium'
                        })

                    # Trop d'imports
                    if imports > 20:
                        srp_violations.append({
                            'file': relative_path,
                            'class': class_name,
                            'reason': f"Trop de dépendances (imports): {imports}",
                            'severity': 'low'
                        })

            except Exception as e:
                pass

        return srp_violations

    def analyze_dip_violations(self):
        """Analyse des violations du Dependency Inversion Principle"""
        dip_violations = []

        lib_path = self.project_root / 'lib'
        if not lib_path.exists():
            return dip_violations

        for dart_file in lib_path.rglob('*.dart'):
            try:
                with open(dart_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()

                relative_path = str(dart_file.relative_to(self.project_root))

                # Détection de dépendances concrètes au lieu d'abstractions
                # Chercher des constructeurs avec new ou direct instantiation
                concrete_deps = re.findall(r'=\s*(\w+)\s*\(', content)

                # Exclure les types primitifs et Flutter
                concrete_classes = [
                    dep for dep in concrete_deps
                    if dep[0].isupper() and dep not in ['String', 'List', 'Map', 'Set', 'Widget', 'State']
                ]

                if len(concrete_classes) > 5:
                    class_match = re.search(r'class\s+(\w+)', content)
                    if class_match:
                        dip_violations.append({
                            'file': relative_path,
                            'class': class_match.group(1),
                            'reason': f"Dépendances concrètes détectées: {len(concrete_classes)}",
                            'severity': 'medium'
                        })

            except Exception as e:
                pass

        return dip_violations

    def analyze_ocp_violations(self):
        """Analyse des violations du Open/Closed Principle"""
        ocp_violations = []

        lib_path = self.project_root / 'lib'
        if not lib_path.exists():
            return ocp_violations

        for dart_file in lib_path.rglob('*.dart'):
            try:
                with open(dart_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()

                relative_path = str(dart_file.relative_to(self.project_root))

                # Détection de switch/if-else longs (potentiellement violant OCP)
                switch_cases = re.findall(r'switch\s*\([^)]+\)\s*\{([^}]+)\}', content, re.DOTALL)
                for switch_content in switch_cases:
                    case_count = len(re.findall(r'case\s+', switch_content))
                    if case_count > 5:
                        class_match = re.search(r'class\s+(\w+)', content)
                        if class_match:
                            ocp_violations.append({
                                'file': relative_path,
                                'class': class_match.group(1),
                                'reason': f"Switch avec {case_count} cas - envisager Strategy pattern",
                                'severity': 'medium'
                            })

            except Exception as e:
                pass

        return ocp_violations

    def generate_report(self):
        """Generate SOLID violations report"""
        srp = self.analyze_srp_violations()
        dip = self.analyze_dip_violations()
        ocp = self.analyze_ocp_violations()

        report = []
        report.append("=" * 80)
        report.append("ANALYSE DES VIOLATIONS SOLID")
        report.append("=" * 80)
        report.append("")

        # SRP Violations
        report.append(f"### E. VIOLATIONS SRP - Single Responsibility ({len(srp)} violations)")
        report.append("")
        report.append("| Fichier | Classe | Raison | Sévérité |")
        report.append("|---------|--------|--------|----------|")

        for v in sorted(srp, key=lambda x: {'high': 0, 'medium': 1, 'low': 2}[x['severity']])[:30]:
            report.append(f"| {v['file']} | {v['class']} | {v['reason']} | {v['severity']} |")

        report.append("")

        # DIP Violations
        report.append(f"### F. VIOLATIONS DIP - Dependency Inversion ({len(dip)} violations)")
        report.append("")
        report.append("| Fichier | Classe | Raison | Sévérité |")
        report.append("|---------|--------|--------|----------|")

        for v in sorted(dip, key=lambda x: x['severity'])[:20]:
            report.append(f"| {v['file']} | {v['class']} | {v['reason']} | {v['severity']} |")

        report.append("")

        # OCP Violations
        report.append(f"### G. VIOLATIONS OCP - Open/Closed ({len(ocp)} violations)")
        report.append("")
        report.append("| Fichier | Classe | Raison | Sévérité |")
        report.append("|---------|--------|--------|----------|")

        for v in sorted(ocp, key=lambda x: x['severity'])[:20]:
            report.append(f"| {v['file']} | {v['class']} | {v['reason']} | {v['severity']} |")

        report.append("")

        # Summary
        total_violations = len(srp) + len(dip) + len(ocp)
        report.append(f"**Total violations SOLID: {total_violations}**")
        report.append("")

        return "\n".join(report)

if __name__ == '__main__':
    project_path = r'C:\Users\Thibaut\Desktop\PriorisProject'
    analyzer = SOLIDAnalyzer(project_path)

    print("Analyse SOLID en cours...")
    report = analyzer.generate_report()
    print(report)
