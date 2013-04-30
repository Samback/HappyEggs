package ua.ck.android.happyeggs;

import android.content.Context;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.provider.Settings.Secure;

public class Helper {
	public static final String TAG_NICK = "nick";
	private static SharedPreferences preferences;
	
	public static String getNick(Context context) {
		preferences = context.getSharedPreferences(TAG_NICK, 0);
		return preferences.getString(TAG_NICK, "");
	}

	public static void setNick(String nick, Context context) {
		preferences = context.getSharedPreferences(TAG_NICK, 0);
		preferences.edit().putString(TAG_NICK, nick).commit();		
	}
	
	public static boolean isConnectingToInternet(Context context){
        ConnectivityManager connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
          if (connectivity != null){
              NetworkInfo[] info = connectivity.getAllNetworkInfo();
              if (info != null){
                  for (int i = 0; i < info.length; i++){
                      if (info[i].getState() == NetworkInfo.State.CONNECTED){
                          return true;
                      }
                  }
              }
          }
          return false;
    }
	
	public static String getUDID(Context context){
		return Secure.getString(context.getContentResolver(), Secure.ANDROID_ID);				
	}	
}