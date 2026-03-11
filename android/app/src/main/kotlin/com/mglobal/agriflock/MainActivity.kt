package com.mglobal.agriflock

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onResume() {
        super.onResume()
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun onPause() {
        super.onPause()
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}

//package com.mglobal.agriflock
//
//import io.flutter.embedding.android.FlutterFragmentActivity
//
//class MainActivity : FlutterFragmentActivity()