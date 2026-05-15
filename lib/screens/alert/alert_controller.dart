import 'package:flutter/foundation.dart';
import 'package:peeroreum_client/api/ApiClient.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/screens/alert/alert_model.dart';

class AlertController extends GetxController{
  var activity_alerts = <AlertModel>[].obs;
  var service_alert = <AlertModel>[].obs;

  @override
  void onInit(){
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async{
    try {

      ///////// 활동 알림

      final activityResponse = await ApiClient().get('/notification/activity');

      if (activityResponse.statusCode == 200) {
        final List<dynamic> data = activityResponse.data['data'] ?? [];
        final alertList = data.map((item) => AlertModel.fromJson(item)).toList();

        activity_alerts.assignAll(alertList); // alerts 리스트에 데이터를 할당
      } else {
        if (kDebugMode) {
          print('Failed to fetch alerts: ${activityResponse.statusCode}');
        }
      }

      ///////// 서비스 알림

      final serviceResponse = await ApiClient().get('/notification/service');

      if (serviceResponse.statusCode == 200) {
        final List<dynamic> serviceData = serviceResponse.data['data'] ?? [];
        final serviceAlertList = serviceData.map((item) => AlertModel.fromJson(item)).toList();
        service_alert.assignAll(serviceAlertList); // Assign service alerts
      } else {
        if (kDebugMode) {
          print('Failed to fetch service alerts: ${serviceResponse.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching alerts: $e');
      }
    }
  }
}
