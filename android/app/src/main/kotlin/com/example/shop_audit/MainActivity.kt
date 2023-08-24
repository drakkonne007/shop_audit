package com.example.shop_audit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.yandex.mapkit.MapKitFactory
import androidx.annotation.NonNull

class MainActivity: FlutterActivity()
{
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine){
        MapKitFactory.setApiKey("3cfd11d4-91b7-47a1-85a1-3747453b7a2b")
        super.configureFlutterEngine(flutterEngine)
    }

}
