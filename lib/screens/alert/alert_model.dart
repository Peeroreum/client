class AlertModel {
  String? title;
  String? description;
  DateTime? createdTime;
  String? timeago;

  AlertModel({this.title, this.description, this.createdTime}) {
    timeago = timeCheck(createdTime!);  // 생성자에서 timeago 계산
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
    title: json['title'],
    description: json['description'],
    createdTime: DateTime.parse(json['createdTime']),  // JSON에서 createdTime 파싱
  );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
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
//   final String description;
//   final String timeago;

//   AlertModel({
//     required this.description,
//     required this.timeago,
//   });

//   // 더미 데이터를 위한 팩토리 메서드
//   factory AlertModel.fromJson(Map<String, dynamic> json) {
//     return AlertModel(
//       description: json['description'],
//       timeago: json['timeago'],
//     );
//   }
// }

// List<AlertModel> generateDummyAlerts() {
//   return List.generate(10, (index) => AlertModel(
//     description: '알림 ${index+1} 설명 어쩌고 와랄라',
//     timeago: '10분 전',
//   ));
// }
