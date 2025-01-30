package com.example.sms_sender

import android.content.Context
import android.telephony.SmsManager
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SmsSenderPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sms_sender")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "sendSms" -> {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")
                val simSlot = call.argument<Int>("simSlot")
                sendSms(phoneNumber, message, simSlot, result)
            }
            "getSimCards" -> {
                getSimCards(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun sendSms(phoneNumber: String?, message: String?, simSlot: Int?, result: Result) {
        if (phoneNumber == null || message == null) {
            result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
            return
        }

        try {
            val smsManager: SmsManager = if (simSlot != null) {
                SmsManager.getSmsManagerForSubscriptionId(getSubscriptionId(simSlot))
            } else {
                SmsManager.getDefault()
            }

            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
            result.success("SMS sent")
        } catch (e: Exception) {
            result.error("SMS_FAILED", "Plugin: Failed to send SMS", e.message)
        }
    }

    private fun getSimCards(result: Result) {
        val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
        val subscriptions = subscriptionManager.activeSubscriptionInfoList

        if (subscriptions == null || subscriptions.isEmpty()) {
            result.success(emptyList<Map<String, Any?>>())
            return
        }

        val simCards = mutableListOf<Map<String, Any?>>()
        for (subscription in subscriptions) {
            simCards.add(mapOf(
                "displayName" to subscription.displayName.toString(),
                "subscriptionId" to subscription.subscriptionId,
                "simSlotIndex" to subscription.simSlotIndex
            ))
        }

        result.success(simCards)
    }

    private fun getSubscriptionId(simSlot: Int): Int {
        val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
        val subscriptions = subscriptionManager.activeSubscriptionInfoList

        if (subscriptions == null || subscriptions.isEmpty()) {
            throw Exception("No active SIM cards found")
        }

        for (subscription in subscriptions) {
            if (subscription.simSlotIndex == simSlot) {
                return subscription.subscriptionId
            }
        }

        throw Exception("SIM slot $simSlot not found")
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}