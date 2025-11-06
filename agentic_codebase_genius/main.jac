import from byllm.lib {Model};
import from utils {clone_repo, build_file_tree, read_file, parse_python_file};  # Python integration
import from os {path, makedirs};
import from datetime {datetime};

glob llm = Model(model_name = "gpt-4o");  # Use .env for key

# Nodes for Code Context Graph (CCG)
node file {
    has path: str;
    has content: str;
    has language: str;  # e.g., "python", "jac"
}

node module {
    has name: str;
}

node class {
    has name: str;
    has bases: list[str];
}

node function {
    has name: str;
    has params: list[str];
    has docstring: str;
}

# Edges for relationships
edge contains {}  # e.g., module contains function
edge inherits {}  # class inherits from base
edge calls {}     # function calls another

# Graph for codebase
graph codebase {
    has anchor repo_root;
    spawn {
        repo_root = spawn node::file(path="root");
    }
}

# Helper: Summarize README with LLM
"""Generate a concise summary of the README content."""
def summarize_readme(content: str) -> str by llm();

# Helper: Generate Markdown doc with LLM
"""Synthesize high-quality Markdown documentation from structured data. Include sections: Overview, Installation, Usage, API Reference. Add PlantUML diagram for relationships."""
def generate_md(structured_data: dict, diagram_prompt: str) -> str by llm(method="generate");

# Helper: Generate PlantUML diagram code with LLM
"""Generate PlantUML code for class/function relationships based on CCG data."""
def generate_diagram(ccg_data: dict) -> str by llm();

# Walker: Repo Mapper - Clones, builds file tree, summarizes README
walker repo_mapper {
    has repo_url: str;
    has temp_dir: str = "/tmp/codebase_genius_" + datetime.now().strftime("%Y%m%d_%H%M%S");
    has file_tree: dict;
    has readme_summary: str;

    can clone {
        try {
            clone_repo(repo_url, temp_dir);
        } with ValueError as e {
            report {"error": str(e)};
            disengage;
        }
    }

    can map_files {
        file_tree = build_file_tree(temp_dir);
        # Build graph nodes
        for folder, files in file_tree.items() {
            folder_node = spawn here --> node::file(path=folder);
            for f in files {
                file_path = path.join(folder, f);
                content = read_file(path.join(temp_dir, file_path));
                lang = "python" if f.endswith(".py") else "jac" if f.endswith(".jac") else "other";
                spawn folder_node --> node::file(path=file_path, content=content, language=lang);
            }
        }
    }

    can summarize {
        readme_path = path.join(temp_dir, "README.md");
        if path.exists(readme_path) {
            readme_content = read_file(readme_path);
            readme_summary = summarize_readme(readme_content);
        } else {
            readme_summary = "No README found.";
        }
    }

    with entry {
        clone;
        map_files;
        summarize;
        report {"file_tree": file_tree, "readme_summary": readme_summary, "temp_dir": temp_dir};
    }
}

# Walker: Code Analyzer - Parses files, builds CCG
walker code_analyzer {
    has temp_dir: str;
    has ccg: dict = {};  # Structured dict for simplicity (can be graph nodes)

    can analyze_file with file entry {
        file_node = visitor;
        if file_node.language == "python" {
            parsed = parse_python_file(path.join(temp_dir, file_node.path));
            module_name = path.basename(file_node.path).replace(".py", "");
            ccg[module_name] = parsed;
            # Build graph edges (example: calls)
            module_node = spawn here --> node::module(name=module_name);
            for cls in parsed["classes"] {
                cls_node = spawn module_node <--> edge::contains <--> node::class(name=cls["name"], bases=cls["bases"]);
                for base in cls["bases"] {
                    spawn cls_node <--> edge::inherits <--> node::class(name=base);  # Assume base exists
                }
            }
            for func in parsed["functions"] {
                func_node = spawn module_node <--> edge::contains <--> node::function(name=func["name"], params=func["params"]);
            }
            for call in parsed["calls"] {
                # Infer calls (simplified; match to known funcs)
                if call in [f["name"] for f in parsed["functions"]] {
                    # Spawn edge::calls between funcs
                }
            }
        } else {
            # For Jac/other, use LLM analysis
            """Analyze code content for functions, classes, relationships."""
            analyzed = llm(method="ReAct", tools=[])(file_node.content);  # Simplified; parse JSON output
            ccg[file_node.path] = analyzed;
        }
    }

    with entry {
        take --> node::file;  # Traverse files
        report {"ccg": ccg};
    }
}

# Walker: DocGenie - Generates final Markdown
walker doc_genie {
    has structured_data: dict;  # Combined file_tree, readme, ccg
    has output_dir: str;

    can synthesize {
        diagram_code = generate_diagram(structured_data["ccg"]);
        md_content = generate_md(structured_data, "Include PlantUML diagram: " + diagram_code);
        makedirs(output_dir, exist_ok=True);
        output_path = path.join(output_dir, "docs.md");
        with open(output_path, "w") as f {
            f.write(md_content);
        }
    }

    with entry {
        synthesize;
        report {"output_path": output_path};
    }
}

# Walker: Supervisor (Code Genius) - Orchestrates workflow
walker supervisor {
    has repo_url: str;
    root repo_root;

    has temp_dir: str;
    has file_tree: dict;
    has readme_summary: str;
    has ccg: dict;
    has repo_name: str = repo_url.split("/")[-1].replace(".git", "");

    can orchestrate {
        # Step 1: Repo Mapper
        mapper_report = spawn here walker::repo_mapper(repo_url=repo_url);
        if "error" in mapper_report {
            report mapper_report;
            disengage;
        }
        temp_dir = mapper_report["temp_dir"];
        file_tree = mapper_report["file_tree"];
        readme_summary = mapper_report["readme_summary"];

        # Step 2: Prioritize high-impact files (e.g., main.py, app.py)
        priority_files = [f for files in file_tree.values() for f in files if f in ["main.py", "app.py", "main.jac"]];

        # Step 3: Code Analyzer on priority, then all
        analyzer_report = spawn here walker::code_analyzer(temp_dir=temp_dir);
        ccg = analyzer_report["ccg"];

        # Step 4: DocGenie
        structured_data = {"file_tree": file_tree, "readme": readme_summary, "ccg": ccg};
        output_dir = "./outputs/" + repo_name;
        genie_report = spawn here walker::doc_genie(structured_data=structured_data, output_dir=output_dir);
    }

    with entry {
        orchestrate;
        report {"status": "Documentation generated", "path": path.join(output_dir, "docs.md")};
    }
}