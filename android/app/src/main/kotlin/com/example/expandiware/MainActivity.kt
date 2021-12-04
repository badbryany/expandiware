package com.example.expandiware

import android.os.Build
import androidx.core.content.res.ResourcesCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/colors"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            when (call.method) {
                "getMaterialYouColors" -> result.success(getMaterialYouColors())
                else -> result.notImplemented()
            }
        }
    }

    private fun getMaterialYouColors(): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return null
        }

        return mapOf(
                        "system_accent1_0" to android.R.color.system_accent1_0,
                        "system_accent1_10" to android.R.color.system_accent1_10,
                        "system_accent1_50" to android.R.color.system_accent1_50,
                        "system_accent1_100" to android.R.color.system_accent1_100,
                        "system_accent1_200" to android.R.color.system_accent1_200,
                        "system_accent1_300" to android.R.color.system_accent1_300,
                        "system_accent1_400" to android.R.color.system_accent1_400,
                        "system_accent1_500" to android.R.color.system_accent1_500,
                        "system_accent1_600" to android.R.color.system_accent1_600,
                        "system_accent1_700" to android.R.color.system_accent1_700,
                        "system_accent1_800" to android.R.color.system_accent1_800,
                        "system_accent1_900" to android.R.color.system_accent1_900,
                        "system_accent1_1000" to android.R.color.system_accent1_1000,

                        "system_accent2_0" to android.R.color.system_accent2_0,
                        "system_accent2_10" to android.R.color.system_accent2_10,
                        "system_accent2_50" to android.R.color.system_accent2_50,
                        "system_accent2_100" to android.R.color.system_accent2_100,
                        "system_accent2_200" to android.R.color.system_accent2_200,
                        "system_accent2_300" to android.R.color.system_accent2_300,
                        "system_accent2_400" to android.R.color.system_accent2_400,
                        "system_accent2_500" to android.R.color.system_accent2_500,
                        "system_accent2_600" to android.R.color.system_accent2_600,
                        "system_accent2_700" to android.R.color.system_accent2_700,
                        "system_accent2_800" to android.R.color.system_accent2_800,
                        "system_accent2_900" to android.R.color.system_accent2_900,
                        "system_accent2_1000" to android.R.color.system_accent2_1000,

                        "system_accent3_0" to android.R.color.system_accent3_0,
                        "system_accent3_10" to android.R.color.system_accent3_10,
                        "system_accent3_50" to android.R.color.system_accent3_50,
                        "system_accent3_100" to android.R.color.system_accent3_100,
                        "system_accent3_200" to android.R.color.system_accent3_200,
                        "system_accent3_300" to android.R.color.system_accent3_300,
                        "system_accent3_400" to android.R.color.system_accent3_400,
                        "system_accent3_500" to android.R.color.system_accent3_500,
                        "system_accent3_600" to android.R.color.system_accent3_600,
                        "system_accent3_700" to android.R.color.system_accent3_700,
                        "system_accent3_800" to android.R.color.system_accent3_800,
                        "system_accent3_900" to android.R.color.system_accent3_900,
                        "system_accent3_1000" to android.R.color.system_accent3_1000,

                        "system_neutral1_0" to android.R.color.system_neutral1_0,
                        "system_neutral1_10" to android.R.color.system_neutral1_10,
                        "system_neutral1_50" to android.R.color.system_neutral1_50,
                        "system_neutral1_100" to android.R.color.system_neutral1_100,
                        "system_neutral1_200" to android.R.color.system_neutral1_200,
                        "system_neutral1_300" to android.R.color.system_neutral1_300,
                        "system_neutral1_400" to android.R.color.system_neutral1_400,
                        "system_neutral1_500" to android.R.color.system_neutral1_500,
                        "system_neutral1_600" to android.R.color.system_neutral1_600,
                        "system_neutral1_700" to android.R.color.system_neutral1_700,
                        "system_neutral1_800" to android.R.color.system_neutral1_800,
                        "system_neutral1_900" to android.R.color.system_neutral1_900,
                        "system_neutral1_1000" to android.R.color.system_neutral1_1000,

                        "system_neutral2_0" to android.R.color.system_neutral2_0,
                        "system_neutral2_10" to android.R.color.system_neutral2_10,
                        "system_neutral2_50" to android.R.color.system_neutral2_50,
                        "system_neutral2_100" to android.R.color.system_neutral2_100,
                        "system_neutral2_200" to android.R.color.system_neutral2_200,
                        "system_neutral2_300" to android.R.color.system_neutral2_300,
                        "system_neutral2_400" to android.R.color.system_neutral2_400,
                        "system_neutral2_500" to android.R.color.system_neutral2_500,
                        "system_neutral2_600" to android.R.color.system_neutral2_600,
                        "system_neutral2_700" to android.R.color.system_neutral2_700,
                        "system_neutral2_800" to android.R.color.system_neutral2_800,
                        "system_neutral2_900" to android.R.color.system_neutral2_900,
                        "system_neutral2_1000" to android.R.color.system_neutral2_1000
                )
                .map { (name, id) ->
                    val color = ResourcesCompat.getColor(resources, id, theme)
                    val colorHex = Integer.toHexString(color)
                    return@map "\"$name\": \"#$colorHex\""
                }
                .joinToString(separator = ",", prefix = "{", postfix = "}")
    }
}