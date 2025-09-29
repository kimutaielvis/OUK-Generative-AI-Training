"""Implementation of Quiz Game – Scale Agnostic"""

impl QuizWalker.start {
    end: `root | quiz_turn = here;

    # Define quiz questions
    qs = [
        ("What is the capital of Kenya?", ["Nairobi", "Kisumu", "Mombasa", "Nakuru"], 1),
        ("Which language is this game first written in?", ["C++", "Python", "Jac", "Java"], 2),
        ("What is 2 + 2?", ["3", "4", "5", "6"], 2)
    ];

    # Create quiz_turn nodes
    for q in qs {
        end ++> (end := quiz_turn(question=q[0], options=q[1], correct_index=q[2]));
    }

    # Begin traversal
    visit [-->];

}

impl QuizWalker.answer_question {
    print(f"\nQuestion: {here.question}");
    for i in range(len(here.options)) {
        print(f"{i+1}) {here.options[i]}");
    }

    ans = input("Enter your choice (1/2/3/4): ");
    if ans.isdigit() {
        if int(ans) == here.correct_index {
            print("Correct!");
            self.score += 1;
        } else {
            print(f" Wrong! The correct answer was option {here.correct_index}) {here.options[here.correct_index-1]}");
        }
    } else {
        print("Invalid input, skipping...");
    }

    visit [-->];
    print(f"\n Game Over! You scored {self.score} out of {self.total}");
}
