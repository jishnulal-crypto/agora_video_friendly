package com.example.agora_video_friendly
import io.flutter.embedding.android.FlutterActivity
import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.*
import androidx.core.content.ContextCompat

class IncomingCallActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Show on lock screen
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        val callerName = intent.getStringExtra("callerName") ?: "Unknown"
        val callType = intent.getStringExtra("callType") ?: "audio" // "video" or "audio"


        // Root layout
        val rootLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.BLACK)
            gravity = Gravity.CENTER
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setPadding(32, 32, 32, 32)
        }

        // Call icon
        val icon = ImageView(this).apply {
            setImageResource(
                if (callType == "video") android.R.drawable.presence_video_online
                else android.R.drawable.sym_call_incoming
            )
            setColorFilter(Color.WHITE)
            layoutParams = LinearLayout.LayoutParams(150, 150).apply {
                bottomMargin = 40
            }
        }

        // Caller name
        val nameText = TextView(this).apply {
            text = callerName
            setTextColor(Color.WHITE)
            textSize = 26f
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 30)
        }

        // Button layout
        val buttonLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        // Accept Button
        val acceptButton = Button(this).apply {
            text = "Accept"
            setBackgroundColor(Color.parseColor("#4CAF50")) // Green
            setTextColor(Color.WHITE)
            setPadding(20, 10, 20, 10)
            setOnClickListener {
                val intent = FlutterActivity
                    .withNewEngine()
                    .initialRoute("/callScreen?type=audio&callerName=$callerName")
                    .build(this@IncomingCallActivity)
                startActivity(intent)
                finish()
            }
        }

        // Decline Button
        val declineButton = Button(this).apply {
            text = "Decline"
            setBackgroundColor(Color.parseColor("#F44336")) // Red
            setTextColor(Color.WHITE)
            setPadding(20, 10, 20, 10)
            setOnClickListener {
                finish()
            }
        }

        // Add spacing between buttons
        val spacing = Space(this).apply {
            layoutParams = LinearLayout.LayoutParams(40, 0)
        }

        buttonLayout.addView(acceptButton)
        buttonLayout.addView(spacing)
        buttonLayout.addView(declineButton)

        // Assemble view
        rootLayout.addView(icon)
        rootLayout.addView(nameText)
        rootLayout.addView(buttonLayout)

        setContentView(rootLayout)
    }
}
