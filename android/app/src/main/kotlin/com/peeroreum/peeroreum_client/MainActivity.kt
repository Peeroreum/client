package com.peeroreum.peeroreum_client

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.URLDecoder

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.peeroreum/deeplink"
    private var pendingRoomId: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialRoomId" -> {
                        result.success(pendingRoomId)
                        pendingRoomId = null
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Flutter 엔진 시작 전에 미리 추출 (race condition 방지)
        pendingRoomId = extractRoomId(intent)
        android.util.Log.d("DeepLink", "onCreate pendingRoomId=$pendingRoomId, data=${intent?.data}")
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val roomId = extractRoomId(intent)
        android.util.Log.d("DeepLink", "onNewIntent roomId=$roomId, data=${intent.data}")
        if (roomId != null) {
            // 앱이 실행 중일 때 → Flutter에 직접 전달
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("onDeepLink", roomId)
            }
        }
    }

    private fun extractRoomId(intent: Intent?): String? {
        // Intent Extras 전체 로그 (Kakao SDK가 extras로 파라미터 전달하는지 확인)
        val extras = intent?.extras
        if (extras != null) {
            android.util.Log.d("DeepLink", "=== Intent Extras ===")
            for (key in extras.keySet()) {
                android.util.Log.d("DeepLink", "  extra[$key] = ${extras.get(key)}")
            }
        } else {
            android.util.Log.d("DeepLink", "Intent Extras = null")
        }

        val data = intent?.data ?: return null
        // 상세 로그 - 실제 URI 구조 파악용
        android.util.Log.d("DeepLink", "raw dataString: ${intent.dataString}")
        android.util.Log.d("DeepLink", "scheme=${data.scheme} host=${data.host}")
        android.util.Log.d("DeepLink", "path=${data.path} encodedPath=${data.encodedPath}")
        android.util.Log.d("DeepLink", "query=${data.query} encodedQuery=${data.encodedQuery}")
        android.util.Log.d("DeepLink", "pathSegments=${data.pathSegments}")

        // 1) peeroreum://wedu/{roomId}
        if (data.scheme == "peeroreum" && data.host == "wedu") {
            return data.pathSegments.firstOrNull()
        }

        // 2) kakaoa{key}://kakaolink?roomId={roomId} — FeedTemplate androidExecutionParams
        if (data.scheme?.startsWith("kakaoa") == true && data.host == "kakaolink") {
            // androidExecutionParams로 전달된 roomId 쿼리 파라미터
            val roomId = data.getQueryParameter("roomId")
            if (!roomId.isNullOrEmpty()) {
                android.util.Log.d("DeepLink", "Kakao roomId from executionParams: $roomId")
                return roomId
            }
            // 구버전 호환: path segment
            val pathRoomId = data.pathSegments.firstOrNull()?.takeIf { it.isNotEmpty() }
            if (pathRoomId != null) return pathRoomId
            // 구버전 호환: raw query
            val query = data.query?.takeIf { it.isNotEmpty() } ?: return null
            val decoded = try { URLDecoder.decode(query, "UTF-8") } catch (e: Exception) { query }
            if (decoded.startsWith("peeroreum://wedu/")) {
                return decoded.removePrefix("peeroreum://wedu/").split("/").firstOrNull()?.takeIf { it.isNotEmpty() }
            }
            return decoded.split("/").firstOrNull()?.takeIf { it.isNotEmpty() }
        }

        return null
    }
}
