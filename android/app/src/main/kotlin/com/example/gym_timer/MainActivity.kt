package com.example.gym_timer

import android.webkit.WebView
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.gym_timer/cast"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable WebView debugging for inspection via chrome://inspect
        WebView.setWebContentsDebuggingEnabled(true)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendCastMessage") {
                val namespace = call.argument<String>("namespace")
                val message = call.argument<String>("message")
                val castSession: CastSession? = CastContext.getSharedInstance(this).sessionManager.currentCastSession
                
                if (castSession == null) {
                    println("MainActivity: CAST_ERROR - No active session found")
                    result.error("UNAVAILABLE", "No active Cast session", null)
                    return@setMethodCallHandler
                }

                if (!castSession.isConnected) {
                    println("MainActivity: CAST_ERROR - Session found but not connected")
                    result.error("NOT_CONNECTED", "Session not connected", null)
                    return@setMethodCallHandler
                }

                if (namespace != null && message != null) {
                    castSession.sendMessage(namespace, message)
                        .setResultCallback { status ->
                            if (status.isSuccess) {
                                result.success(true)
                            } else {
                                println("MainActivity: CAST_ERROR - ${status.statusMessage}")
                                result.error("CAST_ERROR", status.statusMessage, null)
                            }
                        }
                } else {
                    result.error("INVALID_PARAMS", "Namespace or message null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
