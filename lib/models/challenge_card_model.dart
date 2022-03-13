class ChallengeCardModel {
  ChallengeCardModel(
      {required this.id,
      required this.title,
      required this.duration,
      required this.imagePath,
      this.personalRecord = 'TBD'});

  final int id;
  final String duration;
  final String title;
  final String imagePath;
  final String? personalRecord;
}

class ChallengeCardData {

  // this firebase object is not currently being used.
  // instead, we are using the below static list until we find a need to
  // dynamically generate challenges
  // Stream collectionStream = FirebaseFirestore.instance
  //     .collection('games')
  //     .where('status', isEqualTo: 'open')
  //     .snapshots();

  static List<ChallengeCardModel> challengeCards = [
    ChallengeCardModel(
      id: 0,
      duration: '1 minute',
      title: 'Pushup',
      imagePath: "images/avatar-blank.png",
      personalRecord: 'TBD',
    ),
    // ChallengeCardModel(
    //   id: 1,
    //   duration: '1 minute',
    //   title: 'Squats',
    //   imagePath: "images/squat-challenge-card.jpg",
    //   personalRecord: 'TBD',
    // ),
    // ChallengeCardModel(
    //   id: 2,
    //   duration: '1 minute',
    //   title: 'Situps',
    //   imagePath: "images/situp-challenge-card.jpg",
    //   personalRecord: 'TBD',
    // ),
  ];
}
