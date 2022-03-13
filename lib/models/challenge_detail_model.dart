class ChallengeDetailModel {
  ChallengeDetailModel(
      {required this.id,
      required this.title,
      required this.personalRecord,
      required this.wins,
      required this.losses,
      required this.headLine,
      required this.bodyText,
      required this.backgroundImagePath});

  final int id;
  final String title;
  final String personalRecord;
  final String wins;
  final String losses;
  final String headLine;
  final String bodyText;
  final String backgroundImagePath;
}

class ChallengeDetailData {
  static List<ChallengeDetailModel> challengeDetails = [
    ChallengeDetailModel(
      id: 1,
      title: 'PUSHUP CHALLENGE',
      personalRecord: 'TBD',
      wins: '?',
      losses: '?',
      headLine: 'Pushup Challenge',
      bodyText: 'How many pushups can you perform under 1 minute?',
      backgroundImagePath: 'images/avatar-blank.png',
      // personalRecord: 0,
    ),
    ChallengeDetailModel(
      id: 1,
      title: 'SQUAT CHALLENGE',
      personalRecord: 'TBD',
      wins: '?',
      losses: '?',
      headLine: 'Squat Challenge',
      bodyText: 'How many squats can you perform under 1 minute?',
      backgroundImagePath: 'images/avatar-blank.png',
      // personalRecord: 0,
    ),
    ChallengeDetailModel(
      id: 1,
      title: 'SITUP CHALLENGE',
      personalRecord: 'TBD',
      wins: '?',
      losses: '?',
      headLine: 'Situp Challenge',
      bodyText: 'How many situps can you perform under 1 minute?',
      backgroundImagePath: 'images/avatar-blank.png',
      // personalRecord: 0,
    ),
  ];
}
