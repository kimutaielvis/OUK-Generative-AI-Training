# Quiz Game in Jac (Step 0 → Step 6)
This repository showcases the progressive development of a Quiz Game using Jac, starting from a simple script and evolving into an AI-powered interactive game.

The goal of this project is to demonstrate:
1. How Jac supports object-oriented design.
2. How to use walkers, nodes, and graph traversal.
3. How to separate declarations & implementations.
4. How to integrate AI models using byLLM.

## Features

3 multiple-choice questions.

Player selects an answer by typing the option index.

AI gives intelligent hints if the player is wrong.

AI explains the correct answer when the player is right.

Keeps track of the final score.

## Installation & Setup
1. Create Virtual Environment
Create a new virtual using the command :

       python -m venv jac-env
   
2. Activate Virtual Environment

       jac-env\Scripts\activate

3. Install JacLang
With the environment active, install JacLang via pip:

        pip install jac-lang

Verify installation:

        jac --version

4. Run the Games
Examples:

        jac run quiz_game0.jac     # Step 0 – Basic script
        jac run quiz_game3.jac     # Step 3 – With .impl file
        jac run quiz_game6.jac     # Step 6 – AI-enhan
