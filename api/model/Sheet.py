class Sheet:
    def __init__(self):
        self.answers = []
        self.question_count = 0
        self.empty_count = 0
        self.multi_answer_count = 0
        self.options = 0
        self.image_path = ""

    def __str__(self):
        return f"Question Count: {self.question_count}, Empty Count: {self.empty_count}, Multi Answer Count: {self.multi_answer_count}, Options: {self.options}, Image Path: {self.image_path}, Answers: {self.answers}"

