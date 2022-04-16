class UserNotification {
  //String? _notificationId;
  String? _userImage;
  String? _username;
  String? _message;
  bool? _isNewParking;
  bool? _isForRating;
  int? _notificationDate;

  UserNotification(
    String userImage,
    String username,
    String message,
    bool isNewParking,
    bool isForRating,
    int notificationDate,
  ) {
    _userImage = userImage;
    _username = username;
    _message = message;
    _isNewParking = isNewParking;
    _isForRating = isForRating;
    _notificationDate = notificationDate;
  }

  String? get getUserImage => _userImage;

  String? get getUsername => _username;

  String? get getMessage => _message;

  bool? get isNewParking => _isNewParking;

  bool? get isForRating => _isForRating;

  int? get getNotificationDate => _notificationDate;

  @override
  String toString() {
    return "Notification [ $_username , $_message , $_isNewParking, $_isForRating, $_notificationDate]";
  }
  
  Map<String, dynamic> toJson() => {
        'userImage': _userImage,
        'username': _username,
        'message': _message,
        'isNewParking': _isNewParking,
        'isForRating': _isForRating,
        'notificationDate': _notificationDate,
      };

  static UserNotification fromJson(Map<String, dynamic> json) {
    return UserNotification(
      json['userImage'],
      json['username'],
      json['message'],
      json['isNewParking'],
      json['isForRating'],
      json['notificationDate'],
    );
  }
}
