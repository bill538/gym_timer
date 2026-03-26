package com.example.gym_timer

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.gym_timer/cast"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendCastMessage") {
                val namespace = call.argument<String>("namespace")
                val message = call.argument<String>("message")
                val castSession: CastSession? = CastContext.getSharedInstance(this).sessionManager.currentCastSession
                if (castSession != null && namespace != null && message != null) {
                    castSession.sendMessage(namespace, message)
                        .setResultCallback { status ->
                            if (status.isSuccess) {
                                result.success(true)
                            } else {
                                result.error("CAST_ERROR", status.statusMessage, null)
                            }
                        }
                } else {
                    result.error("UNAVAILABLE", "No active Cast session", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
