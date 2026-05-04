import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var initialRoomId: String? = nil
    private var initialNickname: String? = nil
    private var deepLinkChannel: FlutterMethodChannel? = nil

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        let controller = window?.rootViewController as! FlutterViewController
        deepLinkChannel = FlutterMethodChannel(
            name: "com.peeroreum/deeplink",
            binaryMessenger: controller.binaryMessenger
        )

        // Flutter에서 getInitialRoomId / getInitialNickname 호출 시 응답
        deepLinkChannel?.setMethodCallHandler { [weak self] call, result in
            if call.method == "getInitialRoomId" {
                result(self?.initialRoomId)
            } else if call.method == "getInitialNickname" {
                result(self?.initialNickname)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        // 콜드 스타트: 앱이 꺼진 상태에서 카카오 링크로 열릴 때
        if let url = launchOptions?[.url] as? URL {
            handleKakaoLink(url, isColdStart: true)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 웜 스타트: 앱이 떠 있는 상태에서 카카오 링크로 열릴 때
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if url.scheme?.hasPrefix("kakaoa") == true && url.host == "kakaolink" {
            handleKakaoLink(url, isColdStart: false)
            return true
        }
        return super.application(app, open: url, options: options)
    }

    private func handleKakaoLink(_ url: URL, isColdStart: Bool) {
        let query = url.query ?? ""
        let decoded = query.removingPercentEncoding ?? query

        // 같이방: peeroreum://wedu/{roomId} 형태로 넘어오는 경우
        if decoded.hasPrefix("peeroreum://wedu/") {
            let roomId = String(decoded.dropFirst("peeroreum://wedu/".count))
                .components(separatedBy: "/").first ?? ""
            if !roomId.isEmpty {
                if isColdStart { initialRoomId = roomId }
                else { deepLinkChannel?.invokeMethod("onDeepLink", arguments: roomId) }
                return
            }
        }

        // query parameter 파싱 (roomId=xxx 또는 nickname=xxx)
        if let components = URLComponents(string: "app://app?\(query)") {
            let items = components.queryItems ?? []

            if let roomId = items.first(where: { $0.name == "roomId" })?.value, !roomId.isEmpty {
                if isColdStart { initialRoomId = roomId }
                else { deepLinkChannel?.invokeMethod("onDeepLink", arguments: roomId) }
                return
            }

            if let nickname = items.first(where: { $0.name == "nickname" })?.value, !nickname.isEmpty {
                if isColdStart { initialNickname = nickname }
                else { deepLinkChannel?.invokeMethod("onDeepLinkProfile", arguments: nickname) }
                return
            }
        }
    }
}
