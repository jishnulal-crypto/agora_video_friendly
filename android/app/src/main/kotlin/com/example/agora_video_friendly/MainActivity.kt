package com.example.agora_video_friendly

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.agora_video_friendly/call_overlay"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showIncomingCall") {
                val callerId = call.argument<String>("callerId") ?: "Unknown"
                val receiverId = call.argument<String>("receiverId") ?: ""
                val isVideo = call.argument<String>("isVideo") ?: "false"
                val channelId = call.argument<String>("channelId") ?: ""
                val callerName = call.argument<String>("callerName") ?: "Unknown"

                val intent = Intent(this, IncomingCallActivity::class.java).apply {
                    putExtra("callerId", callerId)
                    putExtra("receiverId", receiverId)
                    putExtra("isVideo", isVideo)
                    putExtra("channelId", channelId)
                    putExtra("callerName", callerName)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }

                startActivity(intent)
                result.success("Call UI Shown")
            } else {
                result.notImplemented()
            }
        }
    }
}

