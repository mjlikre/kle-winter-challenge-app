// Import the firebase_core plugin
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:tuple/tuple.dart';

/// VARIABLES
final FirebaseFirestore firestore = FirebaseFirestore.instance;

/// CONSTANTS
enum YearInSchool { Freshmen, Sophomore, Junior, Senior, Staff }

enum Gender { Male, Female }

final DateTime startDate = new DateTime(2020, DateTime.november, 23);

class FirebaseRepository {
  /// CONSTANTS
  // Collection names
  static const String USERS_COLLECTION = "users";
  static const String COMMITMENTS_COLLECTION = "commitments";
  static const String PROGRESS_COLLECTION = "progress";
  static const String VERSES_COLLECTION = "verse";
  static const String POINTS_COLLECTION = "points";

  // Field names
  static const String FULL_NAME_FIELD = "fullName";
  static const String PROFILE_URL_FIELD = "profileImageUrl";
  static const String YEAR_FIELD = "year";
  static const String GENDER_FIELD = "gender";
  static const String SCORE_FIELD = "score";
  static const String VERSE_FIELD = "verse";
  static const String SERVANTHOOD_FIELD = "servanthood";
  static const String PRAYER_FIELD = "prayer";
  static const String VERSE_REFERENCE_FIELD = "verse_reference";
  static const String VERSE_TEXT_FIELD = "verse_text";

  // Point values
  static const int VERSE_POINTS = 10;
  static const int SERVANTHOOD_POINTS = 10;
  static const int PRAYER_POINTS = 10;

  /// CREATE FUNCTIONS

  void createUserWithGoogleProvider(auth.User firebaseUser) {
    firestore.collection(USERS_COLLECTION).doc(firebaseUser.uid).set({
      FULL_NAME_FIELD: firebaseUser.displayName,
      PROFILE_URL_FIELD: firebaseUser.photoURL
    });
  }

  /// Create or updates the commitment of a user in the database
  void updateServanthoodCommitment(String userId, String commitment) {
    firestore
        .collection(COMMITMENTS_COLLECTION)
        .doc(userId)
        .set({SERVANTHOOD_FIELD: commitment});
  }

  /// Adds name on the prayer_list of the given user in the database
  void updatePrayerCommitment(String userId, String name) async {
    var prayerList;

    await getPrayerList(userId).then((result) {
      prayerList = result.toList();
    });

    if (prayerList.length < 5) {
      prayerList = prayerList.add(name);

      firestore
          .collection(COMMITMENTS_COLLECTION)
          .doc(userId)
          .update({PRAYER_FIELD: prayerList});
    }
  }

  /// UPDATE FUNCTIONS
  // Records the user has completed their servanthood commitment on given week
  void markCommitmentComplete(String userId, int week, String commitmentType) {
    firestore
        .collection(PROGRESS_COLLECTION)
        .doc(userId)
        .update({week.toString() + "." + commitmentType: true});

    firestore.collection(USERS_COLLECTION).doc(userId).update(
        {SCORE_FIELD: FieldValue.increment(getPointValue(commitmentType))});
  }

  // Records the user has memorized their verse for the week
  void markVerseMemorized(String userId) {
    markCommitmentComplete(userId, getCurrentWeekNumber(), VERSE_FIELD);
  }

  // Records the user has completed their servanthood commitment for the week
  void markServanthoodCommitmentCompleted(String userId) {
    markCommitmentComplete(userId, getCurrentWeekNumber(), SERVANTHOOD_FIELD);
  }

  // Records the user has prayed for people for the week
  void markPrayerCompleted(String userId) {
    markCommitmentComplete(userId, getCurrentWeekNumber(), PRAYER_FIELD);
  }

  // Sets the year of the user
  void setYear(String userId, YearInSchool year) {
    firestore
        .collection(USERS_COLLECTION)
        .doc(userId)
        .update({YEAR_FIELD: year});
  }

  // Sets the gender of the user
  void setGender(String userId, Gender gender) {
    firestore
        .collection(USERS_COLLECTION)
        .doc(userId)
        .update({YEAR_FIELD: gender});
  }

  /// GET FUNCTIONS
  // Returns the user details
  Future<Object> getUserDetails(String userId) async {
    var user;

    await firestore
        .collection(USERS_COLLECTION)
        .doc(userId)
        .get()
        .then((document) {
      if (document.exists) {
        user = document;
      }
    });

    return user;
  }

  // Get commitment of user of certain type (prayer or servanthood)
  Future<dynamic> getCommitment(String userId, String commitmentType) async {
    var commitment;

    await firestore
        .collection(COMMITMENTS_COLLECTION)
        .doc(userId)
        .get()
        .then((document) {
      if (document.exists) {
        commitment = document.get(commitmentType);
      }
    });

    return commitment;
  }

  /// Returns servanthood commitment of user as a string
  Future<String> getServanthoodCommitment(String userId) async {
    return getCommitment(userId, SERVANTHOOD_FIELD);
  }

  /// Returns prayer list of user
  Future<List<String>> getPrayerList(String userId) async {
    return getCommitment(userId, PRAYER_FIELD);
  }

  /// Returns the current score of the user
  Future<int> getUserScore(String userId) async {
    int score;
    await firestore
        .collection(USERS_COLLECTION)
        .doc(userId)
        .get()
        .then((document) {
      if (document.exists) {
        score = document.get(SCORE_FIELD);
      }
    });

    return score;
  }

  // Returns the scores sorted by year and ordered from highest to lowest.
  Future<int> getRankedScoreForYear(YearInSchool year) {
    // TODO: Implement method
    return null;
  }

  // Returns the scores sorted by gender and ordered from highest to lowest.
  Future<int> getRankedScoreForGender(Gender year) {
    // TODO: Implement method
    return null;
  }

  // Returns individual scores and ordered from highest to lowest.
  Future<int> getRankedScoreForIndividuals() {
    // TODO: Implement method
    return null;
  }

  // Returns boolean indicating completion of commitment for given week
  Future<bool> isCommitmentCompletedForWeek(
      String userId, String commitment, int weekNumber) async {
    bool isCompleted = false;
    var tasks;

    await firestore
        .collection(PROGRESS_COLLECTION)
        .doc(userId)
        .get()
        .then((document) {
      if (document.exists && document.get(weekNumber.toString)) {
        tasks = document.get(weekNumber.toString);
        isCompleted = tasks[commitment];
      }
    });

    return isCompleted;
  }

  /// Returns boolean indicating completion of verse memorization for given week
  Future<bool> isVerseMemorizedForWeek(String userId, int weekNumber) async {
    return isCommitmentCompletedForWeek(userId, VERSE_FIELD, weekNumber);
  }

  /// Returns boolean indicating completion of servanthood commitment for given week
  Future<bool> isServanthoodCompletedForWeek(
      String userId, int weekNumber) async {
    return isCommitmentCompletedForWeek(userId, SERVANTHOOD_FIELD, weekNumber);
  }

  /// Returns boolean indicating completion of prayer commitment for given week
  Future<bool> isPrayerOfferedForWeek(String userId, int weekNumber) async {
    return isCommitmentCompletedForWeek(userId, PRAYER_FIELD, weekNumber);
  }

  /// Returns boolean indicating completion of prayer commitment for current week
  Future<bool> isVerseMemorizedForCurrentWeek(String userId) async {
    return isCommitmentCompletedForWeek(
        userId, VERSE_FIELD, getCurrentWeekNumber());
  }

  /// Returns boolean indicating completion of prayer commitment for current week
  Future<bool> isServanthoodCompletedForCurrentWeek(String userId) async {
    return isCommitmentCompletedForWeek(
        userId, SERVANTHOOD_FIELD, getCurrentWeekNumber());
  }

  /// Returns boolean indicating completion of prayer commitment for current week
  Future<bool> isPrayerOfferedForCurrentWeek(String userId) async {
    return isCommitmentCompletedForWeek(
        userId, PRAYER_FIELD, getCurrentWeekNumber());
  }

  Future<Tuple2> getVerseOfTheWeek() async {
    return getVerseForWeek(getCurrentWeekNumber());
  }

  Future<Tuple2> getVerseForWeek(int weekNumber) async {
    Tuple2 memoryVerseTuple;

    await firestore
        .collection(VERSES_COLLECTION)
        .doc(weekNumber.toString())
        .get()
        .then((document) {
      if (document.exists) {
        memoryVerseTuple = Tuple2<String, String>(
            document.get(VERSE_REFERENCE_FIELD),
            document.get(VERSE_TEXT_FIELD));
      }
    });

    return memoryVerseTuple;
  }

  /// HELPER FUNCTIONS

  // Returns the current week number starting from start date of Winter Challenge.
  int getCurrentWeekNumber() {
    return 1 + DateTime.now().difference(startDate).inDays ~/ 7;
  }

  // Returns the point value of commitment types.
  int getPointValue(String commitmentType) {
    switch (commitmentType) {
      case VERSE_FIELD:
        return VERSE_POINTS;
      case SERVANTHOOD_FIELD:
        return SERVANTHOOD_POINTS;
      case PRAYER_FIELD:
        return PRAYER_POINTS;
      default:
        return 0;
    }
  }
}
