package ua.ck.android.happyeggs;

import android.content.Context;
import android.content.SharedPreferences;

public class Helper {
	public static final String TAG_NICK = "nick";
	private static SharedPreferences preferences;
	
	public static String getTAG_NICK(Context context) {
		preferences = context.getSharedPreferences(TAG_NICK, 0);
		return preferences.getString(TAG_NICK, "");
	}

	public static void setTAG_NICK(String nick, Context context) {
		preferences = context.getSharedPreferences(TAG_NICK, 0);
		preferences.edit().putString(TAG_NICK, nick).commit();		
	}
	
	
	
}
