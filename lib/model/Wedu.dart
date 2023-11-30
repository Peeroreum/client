import 'package:dio/dio.dart';

class Wedu{
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

  Wedu({
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

}