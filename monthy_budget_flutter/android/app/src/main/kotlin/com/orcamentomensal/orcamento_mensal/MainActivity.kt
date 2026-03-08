package com.orcamentomensal.orcamento_mensal

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.orcamentomensal/quick_actions"
    private var channel: MethodChannel? = null
    private var pendingAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)

        // Deliver any action that arrived before engine was ready.
        pendingAction?.let {
            channel?.invokeMethod("quickAction", it)
            pendingAction = null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val uri = intent?.data ?: return
        if (uri.scheme != "orcamentomensal") return

        val actionType = when {
            uri.host == "quick-add" && uri.path == "/expense" -> "quick_add_expense"
            uri.host == "quick-add" && uri.path == "/shopping" -> "quick_add_shopping"
            uri.host == "meals" -> "open_meals"
            uri.host == "assistant" -> "open_assistant"
            else -> return
        }

        if (channel != null) {
            channel?.invokeMethod("quickAction", actionType)
        } else {
            pendingAction = actionType
        }
    }
}
