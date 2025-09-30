"""A Quiz Game with Graph Traversal"""

walker QuizWalker {
    has score: int = 0;
    has total: int = 3;

    can start_quiz with `root entry;
    def process_answer(user_ans: int, correct_index: int, options: list);
}

node qnode {
    has question: str;
    has options: list;
    has correct_index: int;

    can ask with QuizWalker entry;
}

# Run the game
with entry {
    QuizWalker() spawn root;
}
