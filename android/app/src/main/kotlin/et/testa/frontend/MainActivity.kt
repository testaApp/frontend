package et.testa.frontend

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.view.WindowCompat
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity: AudioServiceActivity() {
    
    private var splashView: View? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        // Apply the launch theme BEFORE super.onCreate
        setTheme(resources.getIdentifier("LaunchTheme", "style", packageName))
        
        super.onCreate(savedInstanceState)
        
        // Make the window edge-to-edge
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Show splash screen manually
        showSplashScreen()
    }
    
    private fun showSplashScreen() {
        try {
            // Get the splash drawable resource
            val splashDrawableId = resources.getIdentifier(
                "launch_background", 
                "drawable", 
                packageName
            )
            
            if (splashDrawableId != 0) {
                // Create a view with the splash background
                splashView = View(this).apply {
                    layoutParams = FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    setBackgroundResource(splashDrawableId)
                }
                
                // Add splash view to the root content view
                val content = findViewById<ViewGroup>(android.R.id.content)
                content.addView(splashView)
                
                // Keep splash visible for minimum 500ms
                Handler(Looper.getMainLooper()).postDelayed({
                    removeSplashScreen()
                }, 500)
            }
        } catch (e: Exception) {
            // If splash creation fails, just continue without it
            e.printStackTrace()
        }
    }
    
    private fun removeSplashScreen() {
        splashView?.let { view ->
            try {
                val content = findViewById<ViewGroup>(android.R.id.content)
                content.removeView(view)
                splashView = null
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
    
    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        // Ensure splash is removed when Flutter UI is ready
        Handler(Looper.getMainLooper()).postDelayed({
            removeSplashScreen()
        }, 200)
    }
}