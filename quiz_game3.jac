"""A Simple Quiz Game"""

obj Game {
    has score: int, total: int;

    def play;
}

obj QuizGame (Game) {
    has questions: list;

    def init;
    override def play;
    def ask_question(q: tuple);
}

# Run the game
with entry {
    game = QuizGame();
    game.play();
}
