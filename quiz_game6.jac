"""AI-Enhanced Quiz Game – Step 6"""

import from byllm.llm { Model }

glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

"""LLM-powered helper functions"""
def give_hint(question: str, options: list) -> str by llm();
def explain_answer(question: str, correct_option: str) -> str by llm();

walker QuizWalker {
    has score: int = 0;
    has total: int = 3;

    can start with `root entry;
    can answer_question with quiz_turn entry;
}

node quiz_turn {
    has question: str;
    has options: list;
    has correct_index: int;
}

# CLI entrypoint
with entry:__main__ {
    root spawn QuizWalker();
}
