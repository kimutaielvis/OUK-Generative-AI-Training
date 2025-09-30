"""A Quiz Game – Scale Agnostic Version"""

walker QuizWalker {
    has score: int = 0;
    has total: int = 3;
    has current_q: int = 0;

    can start with `root entry;
    can answer_question with quiz_turn entry;
}

node quiz_turn {
    has question: str;
    has options: list;
    has correct_index: int;
}

# CLI mode only (local runs, not cloud)
with entry:__main__ {
    root spawn QuizWalker();
}
