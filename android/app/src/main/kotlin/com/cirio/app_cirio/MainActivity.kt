package com.cirio.app_cirio

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/// Expõe o sensor de luminosidade ambiente (Sensor.TYPE_LIGHT) do Android
/// para o lado Dart via um EventChannel, dispensando plugins de terceiros
/// para essa única leitura (ver AmbientLightService em lib/services).
class MainActivity : FlutterActivity() {
    private val lightSensorChannel = "com.cirio.app_cirio/light_sensor"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, lightSensorChannel)
            .setStreamHandler(object : EventChannel.StreamHandler {
                private var sensorManager: SensorManager? = null
                private var listener: SensorEventListener? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    val manager = applicationContext.getSystemService(Context.SENSOR_SERVICE) as SensorManager
                    val sensor = manager.getDefaultSensor(Sensor.TYPE_LIGHT)
                    if (sensor == null) {
                        // Aparelho sem sensor de luz: encerra o stream para que o
                        // lado Dart caia no fallback de brilho do sistema.
                        events.endOfStream()
                        return
                    }

                    val sensorListener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent) {
                            events.success(event.values[0].toDouble())
                        }

                        override fun onAccuracyChanged(changedSensor: Sensor?, accuracy: Int) {}
                    }

                    sensorManager = manager
                    listener = sensorListener
                    manager.registerListener(sensorListener, sensor, SensorManager.SENSOR_DELAY_NORMAL)
                }

                override fun onCancel(arguments: Any?) {
                    listener?.let { sensorManager?.unregisterListener(it) }
                    listener = null
                    sensorManager = null
                }
            })
    }
}
