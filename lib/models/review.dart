class Review {
  String? _imageUrl;
  String? _reviewer;
  double? _rating;
  String? _review;
  List<String>? _quickReviews;

  Review(
    String? imageUrl,
    String? reviewer,
    double? rating,
    String? review,
    List<String>? quickReviews,
  ) {
    _imageUrl = imageUrl;
    _reviewer = reviewer;
    _rating = rating;
    _review = review;
    _quickReviews = quickReviews;
  }

  String? get getDisplayPhoto => _imageUrl;

  String? get getReviewer => _reviewer;

  double? get getRating => _rating;

  String? get getReview => _review;

  List<String>? get getQuickReviews => _quickReviews;

  @override
  String toString() {
    return "Review[ $_reviewer, $_rating ,$_review ]";
  }

  Map<String, dynamic> toJson() => {
        'imageUrl': _imageUrl,
        'reviewer': _reviewer,
        'rating': _rating,
        'review': _review,
        'quickReviews': _quickReviews,
      };

  static Review fromJson(Map<String, dynamic> json) {
    List fromDatabaseQuickReviews = json['quickReviews'];
    List<String>? quickReviewsList = [];
    quickReviewsList = fromDatabaseQuickReviews.cast<String>();

    return Review(
      json['imageUrl'],
      json['reviewer'],
      json['rating'],
      json['review'],
      quickReviewsList,
    );
  }
}
