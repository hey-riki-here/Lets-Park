class UserNotification {
  String? _notificationId;
  String? _parkingSpaceId;
  String? _parkingId;
  String? _userImage;
  String? _username;
  String? _message;
  bool? _isNewParking;
  bool? _isForRating;
  int? _notificationDate;
  bool? _hasRead;
  bool? _hasFinishedReview;
  bool? _forExtension;
  String? _extensionInfo;
  String? _oldDeparture;
  String? _oldDuration;

  UserNotification(
    String notificationId,
    String parkingSpaceId,
    String parkingId,
    String userImage,
    String username,
    String message,
    bool isNewParking,
    bool isForRating,
    int notificationDate,
    bool hasRead,
    bool hasFinishedReview,
    bool forExtension,
    String extensionInfo,
    String oldDeparture,
    String oldDuration,
  ) {
    _notificationId = notificationId;
    _parkingSpaceId = parkingSpaceId;
    _parkingId = parkingId;
    _userImage = userImage;
    _username = username;
    _message = message;
    _isNewParking = isNewParking;
    _isForRating = isForRating;
    _notificationDate = notificationDate;
    _hasRead = hasRead;
    _hasFinishedReview = hasFinishedReview;
    _forExtension = forExtension;
    _extensionInfo = extensionInfo;
    _oldDeparture = oldDeparture;
    _oldDuration = oldDuration;
  }

  String? get getNotificationId => _notificationId;

  set setNotificationId(String? id) => _notificationId = id;

  String? get getParkingSpaceId => _parkingSpaceId;

  String? get getParkingId => _parkingId;

  String? get getUserImage => _userImage;

  String? get getUsername => _username;

  String? get getMessage => _message;

  bool? get isNewParking => _isNewParking;

  bool? get isForRating => _isForRating;

  int? get getNotificationDate => _notificationDate;

  bool? get isNotifRead => _hasRead;

  bool? get isFinishedReviewing => _hasFinishedReview;

  bool? get isForExtension => _forExtension;

  String? get getExtensionInfo => _extensionInfo;
  
  String? get getOldDeparture => _oldDeparture;
  
  String? get getOldDuration => _oldDuration;

  @override
  String toString() {
    return "Notification [ $_parkingSpaceId, $_username , $_message , $_isNewParking, $_isForRating, $_notificationDate]";
  }

  Map<String, dynamic> toJson() => {
        'notificationId': _notificationId,
        'parkingSpaceId': _parkingSpaceId,
        'parkingId': _parkingId,
        'userImage': _userImage,
        'username': _username,
        'message': _message,
        'isNewParking': _isNewParking,
        'isForRating': _isForRating,
        'notificationDate': _notificationDate,
        'hasRead': _hasRead,
        'hasFinishedReview': _hasFinishedReview,
        'forExtension': _forExtension,
        'extensionInfo': _extensionInfo,
        'oldDeparture': _oldDeparture,
        'oldDuration': _oldDuration,
      };

  static UserNotification fromJson(Map<String, dynamic> json) {
    return UserNotification(
      json['notificationId'],
      json['parkingSpaceId'],
      json['parkingId'],
      json['userImage'],
      json['username'],
      json['message'],
      json['isNewParking'],
      json['isForRating'],
      json['notificationDate'],
      json['hasRead'],
      json['hasFinishedReview'],
      json['forExtension'],
      json['extensionInfo'],
      json['oldDeparture'],
      json['oldDuration'],
    );
  }
}
