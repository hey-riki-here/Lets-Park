class UserNotification {
  String? _notificationId;
  String? _parkingSpaceId;
  String? _userImage;
  String? _username;
  String? _message;
  bool? _isNewParking;
  bool? _isForRating;
  int? _notificationDate;
  bool? _hasRead;
  bool? _hasFinishedReview;

  UserNotification(
    String notificationId,
    String parkingSpaceId,
    String userImage,
    String username,
    String message,
    bool isNewParking,
    bool isForRating,
    int notificationDate,
    bool hasRead,
    bool hasFinishedReview,
  ) {
    _notificationId = notificationId;
    _parkingSpaceId = parkingSpaceId;
    _userImage = userImage;
    _username = username;
    _message = message;
    _isNewParking = isNewParking;
    _isForRating = isForRating;
    _notificationDate = notificationDate;
    _hasRead = hasRead;
    _hasFinishedReview = hasFinishedReview;
  }

  String? get getNotificationId => _notificationId;

  String? get getParkingSpaceId => _parkingSpaceId;

  String? get getUserImage => _userImage;

  String? get getUsername => _username;

  String? get getMessage => _message;

  bool? get isNewParking => _isNewParking;

  bool? get isForRating => _isForRating;

  int? get getNotificationDate => _notificationDate;

  bool? get isNotifRead => _hasRead;

  bool? get isFinishedReviewing => _hasFinishedReview;

  @override
  String toString() {
    return "Notification [ $_parkingSpaceId, $_username , $_message , $_isNewParking, $_isForRating, $_notificationDate]";
  }

  Map<String, dynamic> toJson() => {
        'notificationId': _notificationId,
        'parkingSpaceId': _parkingSpaceId,
        'userImage': _userImage,
        'username': _username,
        'message': _message,
        'isNewParking': _isNewParking,
        'isForRating': _isForRating,
        'notificationDate': _notificationDate,
        'hasRead': _hasRead,
        'hasFinishedReview': _hasFinishedReview,
      };

  static UserNotification fromJson(Map<String, dynamic> json) {
    return UserNotification(
      json['notificationId'],
      json['parkingSpaceId'],
      json['userImage'],
      json['username'],
      json['message'],
      json['isNewParking'],
      json['isForRating'],
      json['notificationDate'],
      json['hasRead'],
      json['hasFinishedReview'],
    );
  }
}
