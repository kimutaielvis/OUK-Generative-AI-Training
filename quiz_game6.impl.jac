impl QuizWalker.start {
    q1 = root ++> quiz_turn(
        "What is the capital of Kenya?",
        [ "Nairobi", "Kisumu", "Mombasa", "Nakuru" ],
        1
    );

    q2 = root ++> quiz_turn(
        "Which language is this game first written in?", 
        ["C++", "Python", "Jac", "Java"],
        3
    );

    q3 = root ++> quiz_turn(
        "What is 2 + 2?",  
        ["3", "4", "5", "6"],
        1
    );

    visit q1;
}

impl QuizWalker.answer_question {
    if [-->] {
        visit [-->];
    } else {
        user_choice = input("Q: " + here.question + "\nOptions: " + str(here.options) + "\nYour answer (0-" + str(len(here.options)-1) + "): ");

        if int(user_choice) == here.correct_index {
            print("Correct!");
            print(explain_answer(here.question, here.options[here.correct_index]));
            self.score += 1;
        } else {
            print("Wrong. Correct answer is:", here.options[here.correct_index]);
            print(give_hint(here.question, here.options));
        }

        # Move to next question
        if here != [root --> quiz_turn][-1] {
            visit [-->];
        } else {
            print("\n Final Score:", self.score, "/", self.total);
            disengage;
        }
    }
}
