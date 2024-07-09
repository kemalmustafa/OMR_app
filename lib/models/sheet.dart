
class Sheet {

  int question_count;
  int options;
  List<String> answers;

  Sheet(this.question_count, this.options, this.answers);

  @override
  String toString() {
    return 'Sheet{soru_sayisi: $question_count, sik_sayisi: $options, cevaplar: $answers}';
  }


  static Sheet fromJson(Map parsed) {
    return Sheet(parsed['question_count'], parsed['options'], List<String>.from(parsed['answers']));
  }
}