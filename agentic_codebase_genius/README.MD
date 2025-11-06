# Codebase Genius – AI-Powered Code Documentation System

## Overview
Codebase Genius is an autonomous, agentic intelligent, multi-agent system that generates comprehensive, well-structured documentation for any public GitHub repository

# Setup & Installation
## 1. Clone the Repository
    git clone https://github.com/kimutaielvis/OUK-Generative-AI-Training.git
    cd OUK-Generative-AI-Training/agentic_codebase_genius
## 2. Create and Activate Virtual Environment
    # Windows PowerShell
    python -m venv .venv
    .\.venv\Scripts\Activate.ps1

    # Linux/macOS
    python3 -m venv .venv
    source .venv/bin/activate

## 3. Install Dependencies
    pip install -r requirements.txt --only-binary=:all:
    pip install -r FE/requirements.txt

## 4. Set Up Environment Variables
Create .env in project root:

    OPENAI_API_KEY=sk-proj-your-openai-key-here

# Running the System
## Terminal 1 – Start Jac Backend
    jac run main.jac --serve
## Terminal 2 – Start Streamlit Frontend
    
    streamlit run FE/app.py

 
# Architecture  

Code Genius: Supervisor agent orchestrating workflow
Repo Mapper: Clones repo, builds file tree, summarizes README
Code Analyzer: Parses code with Tree-sitter, builds Code Context Graph
DocGenie: Generates markdown documentation and diagrams

# Technologies

Built with Jaseci 1.4.0.20, byLLM, Python, and Streamlit.
