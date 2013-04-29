package ua.ck.android.happyeggs;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;

import com.actionbarsherlock.app.SherlockActivity;

public class SplashScreen extends SherlockActivity {
	 private boolean mIsBackButtonPressed;
	 private static final int SPLASH_DURATION = 1000; 
	    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_splash);
		Handler handler = new Handler();
        handler.postDelayed(new Runnable() { 
            @Override
            public void run() {
                finish();
                if (!mIsBackButtonPressed) {
                    Intent intent = new Intent(SplashScreen.this, MainActivity.class);
                    SplashScreen.this.startActivity(intent);
               }                 
            } 
        }, SPLASH_DURATION);
	}
	
	@Override
    public void onBackPressed() {
        mIsBackButtonPressed = true;
        super.onBackPressed();
   }
}
