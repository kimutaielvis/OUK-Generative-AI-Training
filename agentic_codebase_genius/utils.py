import os
from git import Repo, GitCommandError
from tree_sitter import Language, Parser
import tree_sitter_python as tspython

# Build Tree-Sitter language library (run once)
Language.build_library('build/my-languages.so', [tspython.directory])

PY_LANGUAGE = Language('build/my-languages.so', 'python')

parser = Parser()
parser.set_language(PY_LANGUAGE)

def clone_repo(url: str, temp_dir: str) -> str:
    """Clone GitHub repo to temp dir. Return dir path or raise error."""
    try:
        Repo.clone_from(url, temp_dir)
        return temp_dir
    except GitCommandError as e:
        raise ValueError(f"Failed to clone {url}: {str(e)}")

def build_file_tree(repo_dir: str) -> dict:
    """Build file tree dict, ignoring .git, node_modules, etc."""
    ignore_dirs = {'.git', 'node_modules', '__pycache__'}
    tree = {}
    for root, dirs, files in os.walk(repo_dir):
        dirs[:] = [d for d in dirs if d not in ignore_dirs]
        rel_root = os.path.relpath(root, repo_dir)
        tree[rel_root] = files
    return tree

def read_file(path: str) -> str:
    """Read file content."""
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        return f"Error reading {path}: {str(e)}"

def parse_python_file(path: str) -> dict:
    """Parse Python file with Tree-Sitter. Return dict of classes, functions, calls."""
    content = read_file(path).encode()
    tree = parser.parse(content)
    root_node = tree.root_node

    entities = {'classes': [], 'functions': [], 'calls': []}
    def traverse(node):
        if node.type == 'class_definition':
            name = node.child_by_field_name('name').text.decode()
            bases = [b.text.decode() for b in node.child_by_field_name('superclasses').children if b.type == 'identifier'] if node.child_by_field_name('superclasses') else []
            entities['classes'].append({'name': name, 'bases': bases})
        elif node.type == 'function_definition':
            name = node.child_by_field_name('name').text.decode()
            params = [p.text.decode() for p in node.child_by_field_name('parameters').children if p.type == 'identifier']
            entities['functions'].append({'name': name, 'params': params})
        elif node.type == 'call':
            func = node.child_by_field_name('function').text.decode()
            entities['calls'].append(func)
        for child in node.children:
            traverse(child)

    traverse(root_node)
    return entities