"""Implementation of Quiz Game Graph Traversal"""

impl QuizWalker.start_quiz {
    end: `root | qnode = here;

    # Build the quiz graph (3 nodes connected in sequence)
    q1 = qnode(question="What is the capital of Kenya?", 
               options=["Nairobi", "Kisumu", "Mombasa", "Nakuru"], 
               correct_index=1);

    q2 = qnode(question="Which language is this game first written in?", 
               options=["C++", "Python", "Jac", "Java"], 
               correct_index=2);

    q3 = qnode(question="What is 2 + 2?", 
               options=["3", "4", "5", "6"], 
               correct_index=2);

    end ++> (end := q1);
    end ++> (end := q2);
    end ++> (end := q3);

    visit [-->];   # start visiting
}

impl qnode.ask {
    print(f"\nQuestion: {self.question}");
    for i in range(len(self.options)) {
        print(f"{i+1}) {self.options[i]}");
    }

    ans = input("Enter your choice (1/2/3/4): ");
    if ans.isdigit() {
        visitor.process_answer(int(ans), self.correct_index, self.options);
    } else {
        print(" Invalid input, skipping...");
    }

    visit [-->];   # move to next node
}

impl QuizWalker.process_answer(user_ans: int, correct_index: int, options: list) {
    if user_ans == correct_index {
        print(" Correct!");
        self.score += 1;
    } else {
        print(f" Wrong! The correct answer is option {correct_index}) {options[correct_index-1]}");
    }

    if self.score + (self.total - (self.score + (self.total - 3))) == self.total {
        print(f"\n Quiz Over! Final Score: {self.score}/{self.total}");
    }
}
