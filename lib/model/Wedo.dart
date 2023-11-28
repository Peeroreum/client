import 'package:http/http.dart';

class Wedo{
  String? title;
  int? subject;
  String? targetDate;
  int? grade;
  int? maximumPeople;
  String? challenge;
  bool? isLocked;
  String? password;
  MultipartFile? file;
  List? hashTags;

  Wedo({
    this.title,
    this.subject,
    this.targetDate,
    this.grade,
    this.maximumPeople,
    this.challenge,
    this.isLocked,
    this.password,
    this.file,
    this.hashTags
  });

  Map<String, dynamic> toFormData()=>{
    'title':title,
    'subject':subject,
    'targetDate':targetDate,
    'grade':grade,
    'maximumPeople':maximumPeople,
    'challenge':challenge,
    'isLocked':isLocked,
    'password':password,
    'file':file,
    'hashTags':hashTags
  };
}