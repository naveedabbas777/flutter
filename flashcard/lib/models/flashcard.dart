class Flashcard {
  final int? id;
  final String question;
  final String answer;

  Flashcard({this.id, required this.question, required this.answer});

  Map<String, dynamic> toMap() {
    return {'id': id, 'question': question, 'answer': answer};
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
    );
  }
}
