class AlertModel {
  String? title;
  String? body;
  String? type;
  DateTime? createdTime;
  String? timeago;

  AlertModel({this.title, this.body, this.type, this.createdTime}) {
    timeago = timeCheck(createdTime!); // 생성자에서 timeago 계산
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        title: json['title'],
        body: json['body'],
        type: json['type'].toString() ?? "0",
        createdTime:
            DateTime.parse(json['createdTime']), // JSON에서 createdTime 파싱
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'type': type,
        'createdTime': createdTime?.toIso8601String(),
        'timeago': timeago,
      };

  // timeCheck 함수를 추가해서 AlertModel 내부에서 사용
  String timeCheck(DateTime createdTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdTime);

    if (difference.inDays > 0) {
      if (difference.inDays <= 7) {
        return '${difference.inDays}일';
      } else if (difference.inDays <= 30) {
        int weeks = (difference.inDays / 7).floor();
        return '$weeks주';
      } else if (difference.inDays >= 365) {
        int years = difference.inDays ~/ 365;
        return '$years년';
      } else if (difference.inDays >= 30) {
        int months = difference.inDays ~/ 30;
        return '$months달';
      } else {
        return '${difference.inDays}일';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분';
    } else {
      return '${difference.inSeconds}초';
    }
  }
}

// class AlertModel {
//   final String title;
//   final String description;
//   final String timeago;

//   AlertModel({
//     required this.title,
//     required this.description,
//     required this.timeago,
//   });

//   // 더미 데이터를 위한 팩토리 메서드
//   factory AlertModel.fromJson(Map<String, dynamic> json) {
//     return AlertModel(
//       title: json['title'],
//       description: json['description'],
//       timeago: json['timeago'],
//     );
//   }
// }

// List<AlertModel> generateDummyAlerts() {
//   return List.generate(10, (index) => AlertModel(
//     title: '전교 ${index+1}등 지망생',
//     description: '개발자님이 칭찬을 보냈어요!',
//     timeago: '10분 전',
//   ));
// }
