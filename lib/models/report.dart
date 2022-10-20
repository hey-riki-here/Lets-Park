class Report {
  String? _reportId;
  String? _reporter;
  String? _message;
  int? _reportDate;
  String? _reportType;

  Report(
    String? reportId,
    String? reporter,
    String? message,
    int? reportDate,
    String? reportType,
  ) {
    _reportId = reportId;
    _reporter =reporter;
    _message = message;
    _reportDate = reportDate;
    _reportType = reportType;
  }

  Report.fromDatabase(
    String? reportId,
    String? reporter,
    String? message,
    int? reportDate,
    String? reportType,
  ) {
    _reportId = reportId;
    _reporter =reporter;
    _message = message;
    _reportDate = reportDate;
    _reportType = reportType;
  }

  String? get getReportId => _reportId;

  set setReportId(String? id) => _reportId = id;

  String? get getReporter => _reporter;

  String? get getMessage => _message;

  int? get getReportDate => _reportDate;

  String? get getReportType => _reportType;

  Map<String, dynamic> toJson() => {
    'reportId': _reportId,
    'reporter': _reporter,
    'message': _message,
    'reportDate': _reportDate,
    'reportType': _reportType,
  };

  static Report fromJson(Map<String, dynamic> json) {
    return Report.fromDatabase(
      json['reportId'],
      json['reporter'],
      json['message'],
      json['reportDate'],
      json['reportType'],
    );
  }
}