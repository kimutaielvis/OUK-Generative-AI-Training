"""Implementation of Quiz Game"""

impl Game.play {
    raise NotImplementedError("Subclasses must implement this method.");
}

impl QuizGame.init {
    self.score = 0;
    self.total = 3;
    self.questions = [
        ("What is the capital of Kenya?", ["Nairobi", "Kisumu", "Mombasa", "Nakuru"], 1),
        ("Which language is this game first written in?", ["C++", "Python", "Jac", "Java"], 2),
        ("What is 2 + 2?", ["3", "4", "5", "6"], 2)
    ];
}

impl QuizGame.play {
    for q in self.questions {
        self.ask_question(q);
    }
    print(f" Game Over! You scored {self.score} out of {self.total}");
}

impl QuizGame.ask_question(q: tuple) {
    question = q[0];
    options = q[1];
    correct_index = q[2];

    print(f"\nQuestion: {question}");
    for i in range(len(options)) {
        print(f"{i+1}) {options[i]}");
    }

    ans = input("Enter your choice (1/2/3/4): ");
    if ans.isdigit() {
        if int(ans) == correct_index {
            print(" Correct!");
            self.score += 1;
        } else {
            print(f" Wrong! The correct answer is option {correct_index}) {options[correct_index-1]}");
        }
    } else {
        print(" Invalid input, skipping...");
    }
}
