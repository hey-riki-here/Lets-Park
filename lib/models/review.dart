class Review {
  String? _imageUrl;
  String? _reviewer;
  double? _rating;
  String? _review;

  Review(
    String? imageUrl,
    String? reviewer,
    double? rating,
    String? review,
  ) {
    _imageUrl = imageUrl;
    _reviewer = reviewer;
    _rating = rating;
    _review = review;
  }

  String? get getDisplayPhoto => _imageUrl;

  String? get getReviewer => _reviewer;

  double? get getRating => _rating;

  String? get getReview => _review;

  @override
  String toString() {
    return "Review[ $_reviewer, $_rating ,$_review ]";
  }

  Map<String, dynamic> toJson() => {
        'imageUrl': _imageUrl,
        'reviewer': _reviewer,
        'rating': _rating,
        'review': _review,
      };

  static Review fromJson(Map<String, dynamic> json) {
    return Review(
      json['imageUrl'],
      json['reviewer'],
      json['rating'],
      json['review'],
    );
  }
}
