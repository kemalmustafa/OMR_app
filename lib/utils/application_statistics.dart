import 'package:optiread/pages/list_item_application.dart';

double getAverageScore(List<ApplicationListItem> applicationList) {
  if (applicationList.isEmpty) {
    return 0;
  }
  final totalScore = applicationList
      .map((e) => e.data.score)
      .reduce((value, element) => value + element);
  return totalScore / applicationList.length;
}

double getStandardDeviation(List<ApplicationListItem> applicationList) {
  if (applicationList.isEmpty) {
    return 0;
  }
  final averageScore = getAverageScore(applicationList);
  final totalVariance = applicationList
      .map((e) => (e.data.score - averageScore) * (e.data.score - averageScore))
      .reduce((value, element) => value + element);
  return totalVariance / applicationList.length;
}

double getMedianScore(List<ApplicationListItem> applicationList) {
  if (applicationList.isEmpty) {
    return 0;
  }
  final scores = applicationList.map((e) => e.data.score).toList();
  scores.sort();
  final length = scores.length;
  if (length % 2 == 0) {
    return (scores[length ~/ 2] + scores[length ~/ 2 - 1]) / 2;
  }
  return scores[length ~/ 2];
}

double getModeScore(List<ApplicationListItem> applicationList) {
  if (applicationList.isEmpty) {
    return 0;
  }
  final scores = applicationList.map((e) => e.data.score).toList();
  final scoreMap = <double, int>{};
  for (double element in scores) {
    if (scoreMap.containsKey(element)) {
      scoreMap[element] = scoreMap[element]! + 1;
    } else {
      scoreMap[element] = 1;
    }
  }
  final maxScore = scoreMap.entries.reduce((value, element) {
    if (element.value > value.value) {
      return element;
    }
    return value;
  });
  return maxScore.key;
}

double getMinScore(List<ApplicationListItem> applicationList) {
  if (applicationList.isEmpty) {
    return 0;
  }
  final scores = applicationList.map((e) => e.data.score).toList();
  scores.sort();
  return scores.first;
}

double getMaxScore(List<ApplicationListItem> applicationList) {
  if (applicationList.isEmpty) {
    return 0;
  }
  final scores = applicationList.map((e) => e.data.score).toList();
  scores.sort();
  return scores.last;
}
