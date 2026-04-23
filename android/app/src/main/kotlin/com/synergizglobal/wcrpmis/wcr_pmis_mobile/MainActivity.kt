package com.synergizglobal.wcrpmis.wcr_pmis_mobile

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val fileExportChannel = "wcr_pmis_mobile/file_export"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fileExportChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "saveToDownloads") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val fileName = call.argument<String>("fileName")
                val mimeType = call.argument<String>("mimeType")
                val bytes = call.argument<ByteArray>("bytes")
                val subdirectory = call.argument<String>("subdirectory") ?: "WCR Documents"

                if (fileName.isNullOrBlank() || mimeType.isNullOrBlank() || bytes == null) {
                    result.error("INVALID_ARGS", "Missing required file export arguments.", null)
                    return@setMethodCallHandler
                }

                try {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                        result.error(
                            "UNSUPPORTED_ANDROID_VERSION",
                            "Direct save to public Downloads requires Android 10+.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    val resolver = applicationContext.contentResolver
                    val values = ContentValues().apply {
                        put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                        put(MediaStore.Downloads.MIME_TYPE, mimeType)
                        put(
                            MediaStore.Downloads.RELATIVE_PATH,
                            "${Environment.DIRECTORY_DOWNLOADS}/$subdirectory"
                        )
                        put(MediaStore.Downloads.IS_PENDING, 1)
                    }

                    val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                        ?: throw IllegalStateException("Unable to create MediaStore entry.")

                    resolver.openOutputStream(uri)?.use { stream ->
                        stream.write(bytes)
                    } ?: throw IllegalStateException("Unable to open output stream.")

                    values.clear()
                    values.put(MediaStore.Downloads.IS_PENDING, 0)
                    resolver.update(uri, values, null, null)

                    result.success("${Environment.DIRECTORY_DOWNLOADS}/$subdirectory/$fileName")
                } catch (error: Throwable) {
                    result.error("EXPORT_FAILED", error.message, null)
                }
            }
    }
}
