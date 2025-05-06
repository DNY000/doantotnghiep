package com.example.shipper_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.channel.shared.data"
    private var deepLinkPending: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    result.success(deepLinkPending)
                    deepLinkPending = null
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }

    private fun handleDeepLink(intent: Intent) {
        val data = intent.data
        if (data != null && data.scheme == "shipper-vnpay-return") {
            val deepLink = data.toString()
            
            // Nếu Flutter đã sẵn sàng, gửi deepLink qua channel
            val channel = flutterEngine?.dartExecutor?.let {
                MethodChannel(it.binaryMessenger, CHANNEL)
            }
            
            if (channel != null) {
                channel.invokeMethod("onReceiveDeepLink", deepLink)
            } else {
                // Lưu deep link để trả về sau khi Flutter sẵn sàng
                deepLinkPending = deepLink
            }
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        handleDeepLink(intent)
    }
}
