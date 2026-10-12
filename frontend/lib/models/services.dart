class Services {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  Services({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory Services.fromJson(
      Map<String, dynamic> json) {
    return Services(
      id: json['id'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}