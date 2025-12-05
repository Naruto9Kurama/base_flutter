package com.creator.base_flutter  

import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/pip"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enterPictureInPicture" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        try {
                            val params = PictureInPictureParams.Builder()
                                .setAspectRatio(Rational(16, 9))
                                .build()
                            enterPictureInPictureMode(params)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("PIP_ERROR", e.message, null)
                        }
                    } else {
                        result.error("UNAVAILABLE", "画中画需要 Android 8.0+", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    // 可选：用户按 Home 键时自动进入画中画
    // override fun onUserLeaveHint() {
    //     super.onUserLeaveHint()
    //     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    //         try {
    //             val params = PictureInPictureParams.Builder()
    //                 .setAspectRatio(Rational(16, 9))
    //                 .build()
    //             enterPictureInPictureMode(params)
    //         } catch (e: Exception) {
    //             // 忽略错误
    //         }
    //     }
    // }
}