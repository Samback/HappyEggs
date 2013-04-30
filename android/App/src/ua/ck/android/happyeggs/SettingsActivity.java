package ua.ck.android.happyeggs;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.actionbarsherlock.app.SherlockActivity;

public class SettingsActivity extends SherlockActivity {
	private EditText editNick;
	private Button btnClose;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_settings);
		editNick = (EditText)findViewById(R.id.editNick);
		btnClose = (Button)findViewById(R.id.btnClose);
		editNick.setText(Helper.getNick(this));
		btnClose.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				finish();
			}
		});
	}

	@Override
	protected void onStop() {		
		super.onStop();
		Helper.setNick(editNick.getText().toString(), this);
	}
}