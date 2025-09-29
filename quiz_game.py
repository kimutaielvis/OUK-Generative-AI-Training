"""A Simple Quiz Game"""

class QuizGame:
    def __init__(self, questions, attempts=3):
        self.questions = questions
        self.attempts = attempts
        self.score = 0

    def play(self):
        for q, options, answer in self.questions:
            print(f"\n{q}")
            for i, option in enumerate(options, 1):
                print(f"{i}. {option}")

            guess = input("Your choice (1/2/3/4): ")
            if guess.isdigit() and int(guess) == answer:
                print("Correct! ")
                self.score += 1
            else:
                print("Wrong!")

        print(f"\nGame Over! Your final score is {self.score}/{len(self.questions)}")


# Example quiz
questions = [
    ("What is the capital of Kenya?", ["Nairobi", "Kisumu", "Mombasa", "Nakuru"], 1),
    ("Which language is this game first written in?", ["C++", "Python", "Jac", "Java"], 2),
    ("What is 2 + 2?", ["3", "4", "5", "6"], 2),
]

game = QuizGame(questions)
game.play()
