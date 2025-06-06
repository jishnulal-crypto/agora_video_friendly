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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "showIncomingCall") {
                val callerName = call.argument<String>("callerName") ?: "Unknown"
                val callType = call.argument<String>("callType") ?: "audio" // or "video"

                val intent = Intent(this, IncomingCallActivity::class.java).apply {
                    putExtra("callerName", callerName)
                    putExtra("callType", callType)
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
