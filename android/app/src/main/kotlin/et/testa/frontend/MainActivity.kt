package et.testa.frontend

import android.os.Bundle
import androidx.core.view.WindowCompat
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity: AudioServiceActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Disable persisted Firebase Messaging background callback handles.
        // The app no longer registers a Dart background handler, so keeping old
        // handles can spin up a second Flutter engine and hurt startup.
        getSharedPreferences("io.flutter.firebase.messaging.callback", MODE_PRIVATE)
            .edit()
            .remove("callback_handle")
            .remove("user_callback_handle")
            .apply()

        super.onCreate(savedInstanceState)

        // Make the window edge-to-edge
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
