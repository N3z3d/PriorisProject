#!/usr/bin/env python3
"""
Script pour analyser les méthodes Dart >50 lignes dans le projet
Conforme aux exigences CLAUDE.md
"""

import re
import os
from pathlib import Path
from dataclasses import dataclass
from typing import List, Tuple

@dataclass
class MethodInfo:
    file_path: str
    method_name: str
    start_line: int
    end_line: int
    line_count: int

def find_dart_files(root_dir: str = "lib") -> List[Path]:
    """Trouve tous les fichiers .dart dans le répertoire"""
    return list(Path(root_dir).rglob("*.dart"))

def analyze_method_sizes(file_path: Path) -> List[MethodInfo]:
    """Analyse un fichier pour trouver les méthodes >50 lignes"""
    methods = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Erreur lecture {file_path}: {e}")
        return methods

    # Pattern pour détecter le début d'une méthode
    method_pattern = re.compile(
        r'^\s*(?:@override\s+)?'  # Optional @override
        r'(?:static\s+|final\s+|const\s+)?'  # Optional modifiers
        r'(?:Future<[^>]+>|Stream<[^>]+>|Widget|void|bool|int|double|String|List|Map|Set|[A-Z]\w*)\s+'  # Return type
        r'(\w+)\s*'  # Method name (captured)
        r'\([^)]*\)'  # Parameters
        r'\s*(?:async)?\s*\{'  # Opening brace
    )

    i = 0
    while i < len(lines):
        line = lines[i]
        match = method_pattern.match(line)

        if match:
            method_name = match.group(1)
            start_line = i + 1  # 1-indexed
            brace_count = 1
            j = i

            # Compter les accolades pour trouver la fin de la méthode
            # Commencer après la première ligne (qui contient déjà une {)
            j += 1
            while j < len(lines) and brace_count > 0:
                for char in lines[j]:
                    if char == '{':
                        brace_count += 1
                    elif char == '}':
                        brace_count -= 1
                        if brace_count == 0:
                            break
                j += 1

            end_line = j  # 1-indexed
            line_count = end_line - start_line + 1

            if line_count > 50:
                methods.append(MethodInfo(
                    file_path=str(file_path),
                    method_name=method_name,
                    start_line=start_line,
                    end_line=end_line,
                    line_count=line_count
                ))

            i = j  # Continue après cette méthode
        else:
            i += 1

    return methods

def main():
    print("Analyse des methodes >50 lignes dans le projet Prioris\n")
    print("=" * 80)

    all_methods = []
    dart_files = find_dart_files()

    print(f"Fichiers Dart trouves: {len(dart_files)}\n")

    for file_path in dart_files:
        methods = analyze_method_sizes(file_path)
        all_methods.extend(methods)

    # Trier par nombre de lignes (décroissant)
    all_methods.sort(key=lambda m: m.line_count, reverse=True)

    if not all_methods:
        print("[OK] Aucune methode >50 lignes trouvee!")
        print("[SUCCESS] Le projet respecte CLAUDE.md (max 50 lignes/methode)!")
        return

    print(f"[FAIL] {len(all_methods)} methodes >50 lignes trouvees:\n")
    print("=" * 80)

    for i, method in enumerate(all_methods, 1):
        rel_path = method.file_path.replace("lib\\", "").replace("lib/", "")
        print(f"{i:3}. {rel_path}")
        print(f"     Methode: {method.method_name}()")
        print(f"     Lignes: {method.start_line}-{method.end_line} ({method.line_count} lignes)")
        print()

    # Statistiques
    print("=" * 80)
    print(f"STATISTIQUES:")
    print(f"   - Total methodes >50L: {len(all_methods)}")
    print(f"   - Methode la plus longue: {all_methods[0].line_count} lignes")
    print(f"   - Moyenne: {sum(m.line_count for m in all_methods) / len(all_methods):.1f} lignes")

    # Grouper par fichier
    by_file = {}
    for method in all_methods:
        if method.file_path not in by_file:
            by_file[method.file_path] = []
        by_file[method.file_path].append(method)

    print(f"\nFichiers avec le plus de violations:")
    sorted_files = sorted(by_file.items(), key=lambda x: len(x[1]), reverse=True)
    for file_path, methods in sorted_files[:10]:
        rel_path = file_path.replace("lib\\", "").replace("lib/", "")
        print(f"   - {rel_path}: {len(methods)} methode(s)")

if __name__ == "__main__":
    main()
