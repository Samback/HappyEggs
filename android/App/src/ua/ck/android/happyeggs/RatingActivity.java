package ua.ck.android.happyeggs;

import android.os.Bundle;
import android.webkit.WebView;

import com.actionbarsherlock.app.SherlockActivity;

public class RatingActivity extends SherlockActivity {
	WebView webView;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_rating);
		webView = (WebView)findViewById(R.id.webView);
		webView.loadUrl("http://android.ck.ua");
	}
}
