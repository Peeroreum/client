import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peeroreum_client/api/PeeroreumApi.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/screens/alert/alert_model.dart';

class AlertController extends GetxController{
  var token;
  var activity_alerts = <AlertModel>[].obs;
  var service_alert = <AlertModel>[].obs;

  @override
  void onInit(){
    super.onInit();
    // activity_alerts.assignAll(generateDummyAlerts());
    // service_alert.assignAll(generateDummyAlerts());
    fetchData();
  }

  Future<void> fetchData() async{
    final getConnect = GetConnect();
    token = await const FlutterSecureStorage().read(key: "accessToken");
    const String activityUrl = '${API.hostConnect}/notification/activity';
    const String serviceUrl = '${API.hostConnect}/notification/service';
    
    try {

      ///////// 활동 알림

      final activityResponse = await getConnect.get(
        activityUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (activityResponse.statusCode == 200) {
        final List<dynamic> data = activityResponse.body['data'] ?? [];
        final alertList = data.map((item) => AlertModel.fromJson(item)).toList();

        activity_alerts.assignAll(alertList); // alerts 리스트에 데이터를 할당
      } else {
        if (kDebugMode) {
          print('Failed to fetch alerts: ${activityResponse.statusText}');
        }
      }

      ///////// 서비스 알림

      final serviceResponse = await getConnect.get(
        serviceUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (serviceResponse.statusCode == 200) {
        final List<dynamic> serviceData = serviceResponse.body['data'] ?? [];
        final serviceAlertList = serviceData.map((item) => AlertModel.fromJson(item)).toList();
        service_alert.assignAll(serviceAlertList); // Assign service alerts
      } else {
        if (kDebugMode) {
          print('Failed to fetch service alerts: ${serviceResponse.statusText}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching alerts: $e');
      }
    }
  }
}
