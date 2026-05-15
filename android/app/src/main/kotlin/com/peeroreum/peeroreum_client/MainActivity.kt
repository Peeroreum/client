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
    private var pendingNickname: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialRoomId" -> {
                        result.success(pendingRoomId)
                        pendingRoomId = null
                    }
                    "getInitialNickname" -> {
                        result.success(pendingNickname)
                        pendingNickname = null
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Flutter 엔진 시작 전에 미리 추출 (race condition 방지)
        pendingRoomId = extractRoomId(intent)
        pendingNickname = extractNickname(intent)
        android.util.Log.d("DeepLink", "onCreate pendingRoomId=$pendingRoomId pendingNickname=$pendingNickname, data=${intent?.data}")
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        android.util.Log.d("DeepLink", "onNewIntent data=${intent.data}")

        val roomId = extractRoomId(intent)
        if (roomId != null) {
            android.util.Log.d("DeepLink", "onNewIntent roomId=$roomId")
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("onDeepLink", roomId)
            }
        }

        val nickname = extractNickname(intent)
        if (nickname != null) {
            android.util.Log.d("DeepLink", "onNewIntent nickname=$nickname")
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("onDeepLinkProfile", nickname)
            }
        }
    }

    private fun extractRoomId(intent: Intent?): String? {
        val data = intent?.data ?: return null
        android.util.Log.d("DeepLink", "extractRoomId: scheme=${data.scheme} host=${data.host} query=${data.query}")

        // 1) peeroreum://wedu/{roomId}
        if (data.scheme == "peeroreum" && data.host == "wedu") {
            return data.pathSegments.firstOrNull()
        }

        // 2) kakaoa{key}://kakaolink?roomId={roomId}
        if (data.scheme?.startsWith("kakaoa") == true && data.host == "kakaolink") {
            val roomId = data.getQueryParameter("roomId")
            if (!roomId.isNullOrEmpty()) return roomId
            // 구버전 호환
            val pathRoomId = data.pathSegments.firstOrNull()?.takeIf { it.isNotEmpty() }
            if (pathRoomId != null) return pathRoomId
            val query = data.query?.takeIf { it.isNotEmpty() } ?: return null
            val decoded = try { URLDecoder.decode(query, "UTF-8") } catch (e: Exception) { query }
            if (decoded.startsWith("peeroreum://wedu/")) {
                return decoded.removePrefix("peeroreum://wedu/").split("/").firstOrNull()?.takeIf { it.isNotEmpty() }
            }
        }

        return null
    }

    private fun extractNickname(intent: Intent?): String? {
        val data = intent?.data ?: return null
        android.util.Log.d("DeepLink", "extractNickname: scheme=${data.scheme} host=${data.host} query=${data.query}")

        // 1) peeroreum://profile/{nickname}
        if (data.scheme == "peeroreum" && data.host == "profile") {
            return data.pathSegments.firstOrNull()?.takeIf { it.isNotEmpty() }
        }

        // 2) kakaoa{key}://kakaolink?nickname={nickname}
        if (data.scheme?.startsWith("kakaoa") == true && data.host == "kakaolink") {
            val nickname = data.getQueryParameter("nickname")
            if (!nickname.isNullOrEmpty()) return nickname
        }

        return null
    }
}
