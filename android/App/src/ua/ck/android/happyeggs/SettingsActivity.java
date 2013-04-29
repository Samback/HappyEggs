package ua.ck.android.happyeggs;

import android.os.Bundle;
import android.widget.EditText;

import com.actionbarsherlock.app.SherlockActivity;

public class SettingsActivity extends SherlockActivity {
	EditText editNick;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_settings);
		editNick = (EditText)findViewById(R.id.editNick);
		editNick.setText(Helper.getTAG_NICK(this));		
	}

	@Override
	protected void onStop() {		
		super.onStop();
		Helper.setTAG_NICK(editNick.getText().toString(), this);
	}
	
	

}
