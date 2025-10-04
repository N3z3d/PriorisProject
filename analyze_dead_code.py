#!/usr/bin/env python3
"""
Analyse du code mort et des duplications
"""

import os
import re
from pathlib import Path
from collections import defaultdict
import json

class DeadCodeAnalyzer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.lib_files = []
        self.test_files = []
        self.imports = defaultdict(set)
        self.exports = defaultdict(set)
        self.class_definitions = defaultdict(list)
        self.class_usages = defaultdict(int)
        self.function_definitions = defaultdict(list)
        self.duplications = []

    def scan_files(self):
        """Scan all Dart files"""
        lib_path = self.project_root / 'lib'
        if lib_path.exists():
            for dart_file in lib_path.rglob('*.dart'):
                relative = str(dart_file.relative_to(self.project_root))
                self.lib_files.append(relative)

        test_path = self.project_root / 'test'
        if test_path.exists():
            for dart_file in test_path.rglob('*.dart'):
                relative = str(dart_file.relative_to(self.project_root))
                self.test_files.append(relative)

    def analyze_imports_exports(self):
        """Analyze imports and exports in files"""
        all_files = self.lib_files + self.test_files

        for file_path in all_files:
            full_path = self.project_root / file_path
            try:
                with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()

                # Find imports
                import_pattern = r"import\s+['\"]([^'\"]+)['\"]"
                for match in re.finditer(import_pattern, content):
                    import_path = match.group(1)
                    if not import_path.startswith('package:flutter') and not import_path.startswith('dart:'):
                        self.imports[file_path].add(import_path)

                # Find exports
                export_pattern = r"export\s+['\"]([^'\"]+)['\"]"
                for match in re.finditer(export_pattern, content):
                    export_path = match.group(1)
                    self.exports[file_path].add(export_path)

                # Find class definitions
                class_pattern = r"class\s+(\w+)(?:\s+extends|\s+implements|\s+with|\s*\{)"
                for match in re.finditer(class_pattern, content):
                    class_name = match.group(1)
                    self.class_definitions[class_name].append(file_path)

                # Find class usages (simplified)
                for class_name in self.class_definitions.keys():
                    if re.search(r'\b' + class_name + r'\b', content):
                        self.class_usages[class_name] += 1

            except Exception as e:
                pass

    def find_unused_files(self):
        """Find files that are never imported"""
        unused = []

        # Build a map of all imported files
        all_imports = set()
        for imports in self.imports.values():
            all_imports.update(imports)

        for file_path in self.lib_files:
            # Skip generated files
            if '.g.dart' in file_path or '.mocks.dart' in file_path:
                continue

            # Skip export files
            if 'export.dart' in file_path:
                continue

            # Skip main.dart
            if file_path.endswith('main.dart'):
                continue

            # Check if file is imported
            file_name = os.path.basename(file_path)
            is_imported = False

            for imp in all_imports:
                if file_name in imp or file_path.replace('\\', '/') in imp:
                    is_imported = True
                    break

            if not is_imported:
                unused.append(file_path)

        return unused

    def find_unused_classes(self):
        """Find classes that are defined but rarely used"""
        unused = []

        for class_name, files in self.class_definitions.items():
            usage_count = self.class_usages.get(class_name, 0)

            # If class is defined but only referenced once (its own definition)
            if usage_count <= 1:
                unused.append({
                    'class': class_name,
                    'defined_in': files,
                    'usage_count': usage_count
                })

        return sorted(unused, key=lambda x: x['usage_count'])

    def find_duplications(self):
        """Find potential code duplications (simplified)"""
        # This is a simplified version - looks for similar function signatures
        signatures = defaultdict(list)

        all_files = self.lib_files + self.test_files

        for file_path in all_files:
            full_path = self.project_root / file_path
            try:
                with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()

                # Find function signatures
                func_pattern = r'((?:Future|void|int|String|bool|List|Map|dynamic)\s+\w+\s*\([^)]*\))'
                for match in re.finditer(func_pattern, content):
                    signature = match.group(1).strip()
                    # Normalize signature
                    normalized = re.sub(r'\s+', ' ', signature)
                    signatures[normalized].append(file_path)

            except Exception as e:
                pass

        # Find duplicates
        duplicates = []
        for sig, files in signatures.items():
            if len(files) > 2 and len(sig) > 30:  # Skip very short signatures
                duplicates.append({
                    'signature': sig,
                    'files': list(set(files)),
                    'count': len(files)
                })

        return sorted(duplicates, key=lambda x: x['count'], reverse=True)[:30]

    def generate_report(self):
        """Generate dead code report"""
        self.scan_files()
        self.analyze_imports_exports()

        unused_files = self.find_unused_files()
        unused_classes = self.find_unused_classes()
        duplications = self.find_duplications()

        report = []
        report.append("=" * 80)
        report.append("ANALYSE DU CODE MORT ET DUPLICATIONS")
        report.append("=" * 80)
        report.append("")

        # Unused files
        report.append(f"### C. CODE MORT DÉTECTÉ ({len(unused_files)} fichiers)")
        report.append("")
        report.append("| Fichier | Type | Raison |")
        report.append("|---------|------|--------|")

        for file in unused_files[:50]:
            report.append(f"| {file} | Fichier | Jamais importé |")

        report.append("")

        # Unused classes
        report.append(f"### Classes peu utilisées ({len(unused_classes)} classes)")
        report.append("")
        report.append("| Classe | Fichier | Utilisations |")
        report.append("|--------|---------|--------------|")

        for item in unused_classes[:50]:
            files_str = ', '.join(item['defined_in'][:2])
            if len(item['defined_in']) > 2:
                files_str += '...'
            report.append(f"| {item['class']} | {files_str} | {item['usage_count']} |")

        report.append("")

        # Duplications
        report.append(f"### D. DUPLICATIONS POTENTIELLES ({len(duplications)} patterns)")
        report.append("")
        report.append("| Signature | Fichiers | Occurrences |")
        report.append("|-----------|----------|-------------|")

        for dup in duplications:
            files_str = f"{len(dup['files'])} fichiers"
            sig_short = dup['signature'][:60] + '...' if len(dup['signature']) > 60 else dup['signature']
            report.append(f"| {sig_short} | {files_str} | {dup['count']} |")

        report.append("")

        return "\n".join(report)

if __name__ == '__main__':
    project_path = r'C:\Users\Thibaut\Desktop\PriorisProject'
    analyzer = DeadCodeAnalyzer(project_path)

    print("Analyse du code mort en cours...")
    report = analyzer.generate_report()
    print(report)
