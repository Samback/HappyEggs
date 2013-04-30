package ua.ck.android.happyeggs;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import ua.ck.android.happyeggs.adapters.ScrollAdapter;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.Toast;

import com.actionbarsherlock.app.SherlockActivity;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuItem;
import com.actionbarsherlock.widget.ShareActionProvider;
import com.bump.api.BumpAPIIntents;
import com.bump.api.IBumpAPI;
import com.devsmart.android.ui.HorizontalListView;
import com.google.analytics.tracking.android.EasyTracker;


public class MainActivity extends SherlockActivity implements AdapterView.OnItemClickListener {
	private static final int SELECT_CAMERA = 101;
	private static final int SELECT_GALERY = 102;
	private final String JSON_TAG = "attack";
	private IBumpAPI api;
	private Uri imageUri;
	private final String tag ="!!!CHEB!!!";
	private boolean bumpStatus; 
	private  ImageView imgEgg;
	private AlertDialog.Builder ad;
	private String NAME;
	private String UDID;	
	private final String PLATFORM  = "android";
	private ImageView imgBacground;
	
	private int myNumber = 0, hisNumber = 0;
	private int[] images = {R.drawable.e0,
							R.drawable.e4,
							R.drawable.e5,
							R.drawable.e6,
							R.drawable.e7,
							R.drawable.e8,
							R.drawable.e9,
							R.drawable.e10};
	
	
	@Override
    protected void onStart() {
        EasyTracker.getInstance().activityStart(this);
        super.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
        EasyTracker.getInstance().activityStop(this);
    }
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);  
        
        bumpStatus = false;
        setContentView(R.layout.activity_main);
        imgEgg = (ImageView)findViewById(R.id.imgEgg);
        imgBacground =(ImageView)findViewById(R.id.imgBacground ); 
        HorizontalListView listview = (HorizontalListView) findViewById(R.id.listview);
        ScrollAdapter adapter = new ScrollAdapter(images.length, getApplicationContext(), images);
        listview.setAdapter(adapter);
        listview.setOnItemClickListener(this);
        initBump();
        if (Helper.getNick(this).isEmpty()){
        	startActivity(new Intent(this, SettingsActivity.class));
        }
    }
    
    private void initBump(){
		bindService(new Intent(IBumpAPI.class.getName()), connection, Context.BIND_AUTO_CREATE);    
		IntentFilter filter = new IntentFilter();
        filter.addAction(BumpAPIIntents.CHANNEL_CONFIRMED);
        filter.addAction(BumpAPIIntents.DATA_RECEIVED);
        filter.addAction(BumpAPIIntents.NOT_MATCHED);
        filter.addAction(BumpAPIIntents.MATCHED);
        filter.addAction(BumpAPIIntents.CONNECTED);
        registerReceiver(receiver, filter);
	}
    
    private byte[] sendNumber(){
    	int min = 1;
    	int max = 100;
    	Random r = new Random();
    	myNumber = r.nextInt(max - min + 1) + min;
    	try {
    		JSONObject jRoot = new JSONObject();
			jRoot.put(JSON_TAG, myNumber);
			return jRoot.toString().getBytes();
		} catch (JSONException e) {
			e.printStackTrace();
		}
    	return "".getBytes();    	
    }
    
    private void checkNumber(String data){
    	try{
    		JSONObject jRoot = new JSONObject(data);
    		hisNumber = jRoot.optInt(JSON_TAG);
    		Log.i("Numbers: ", "My : " + Integer.toString(myNumber)+" his : "+Integer.toString(hisNumber));
    		if (hisNumber > myNumber){
    			sendReport("lose");
    			showResulDialog(-1);
    			setBrokenEgg(hisNumber);
    			//Toast.makeText(getApplicationContext(), "You lose", Toast.LENGTH_SHORT).show();
    		}else if (hisNumber < myNumber){
    			sendReport("win");
    			showResulDialog(1);
    			//Toast.makeText(getApplicationContext(), "You Win", Toast.LENGTH_SHORT).show();
    		}else{
    			sendReport("tie");
    			showResulDialog(0);
    			//Toast.makeText(getApplicationContext(), "Tie", Toast.LENGTH_SHORT).show();
    		}
    	}catch (JSONException e){
    		e.printStackTrace();
    	}
    }
    
    private void setBrokenEgg(int power){
    	if (power > 60){
        	imgBacground.setBackground(getResources().getDrawable(R.drawable.first_scratch));    		
    	}else if (power < 30){
    		imgBacground.setBackground(getResources().getDrawable(R.drawable.second_scratch));
    	}else{
    		imgBacground.setBackground(getResources().getDrawable(R.drawable.third_scratch));
    	}
    }
    
    private void showResulDialog(int res){
    	AlertDialog.Builder ad;
    	ad = new AlertDialog.Builder(this);	
		switch (res) {
		case 0:
			ad.setMessage(getResources().getString(R.string.tie));  
			break;
		case 1:
			ad.setMessage(getResources().getString(R.string.win));  
			break;
		case -1:
			ad.setMessage(getResources().getString(R.string.lose));
			break;
		default:
			break;
		}
		ad.setCancelable(false);
		ad.setNeutralButton("OK", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				imgBacground.setBackground(getResources().getDrawable(R.drawable.egg_iphone));
			}
		});
		ad.show();    	
    }
    
    private void sendReport(String state){
    	Thread mThread = new Thread(new ReportSender(state));
    	mThread.start();
    }
    
    private class ReportSender implements Runnable{
    	private String state;
    	
		public ReportSender(String state) {
			super();
			this.state = state;
		}

		@Override
		public void run() {
			doPost(state);
		}
    }
    
    private void doPost(String state ){
    	//String result = new String("");
    	//Log.i("doPost", "doPost");
    	NAME = Helper.getNick(getApplicationContext());
        UDID  = Helper.getUDID(getApplicationContext());
    	try{
    		HttpClient client =  new DefaultHttpClient();
    		HttpPost post = new HttpPost("http://egg.localhome.in.ua/app/chart/add/"+ UDID);
    		
    		List<BasicNameValuePair> pairs = new ArrayList<BasicNameValuePair>();
            pairs.add(new BasicNameValuePair("state", state));
            pairs.add(new BasicNameValuePair("name", NAME));
            pairs.add(new BasicNameValuePair("platform", PLATFORM));
            post.setEntity(new UrlEncodedFormEntity(pairs));
    		//Log.i("Sending nick", NAME);
            HttpResponse response = client.execute(post);
            
            BufferedReader reader = new BufferedReader(new InputStreamReader(response.getEntity().getContent(),"windows-1251"));
		    StringBuilder sb = new StringBuilder();
		    String line = null;
		    while ((line = reader.readLine()) != null) {
		    	sb.append(line + System.getProperty("line.separator"));
		    }    
		    //result = sb.toString();            
    	}catch (org.apache.http.client.ClientProtocolException e) {
    		e.printStackTrace();
	    } catch (IOException e) {
	    	e.printStackTrace();	    
	    } catch (Exception e) {
	    	e.printStackTrace();
	    }
    }
        
    private final BroadcastReceiver receiver = new BroadcastReceiver() {
	    public void onReceive(Context context, Intent intent) {
	        final String action = intent.getAction();
	        try {
	        	Log.i(tag,"Recive something");
	        	if (action.equals(BumpAPIIntents.DATA_RECEIVED)) {
	        		//Toast.makeText(getApplicationContext(), "Received data from: " + api.userIDForChannelID(intent.getLongExtra("channelID", 0)), Toast.LENGTH_SHORT).show();
	                checkNumber(new String(intent.getByteArrayExtra("data")));	  
	            } else if (action.equals(BumpAPIIntents.MATCHED)) {
	            	//Toast.makeText(getApplicationContext(), "MATCHED", Toast.LENGTH_SHORT).show();
	                api.confirm(intent.getLongExtra("proposedChannelID", 0), true);
	            } else if (action.equals(BumpAPIIntents.CHANNEL_CONFIRMED)) {	            	
	            	api.send(intent.getLongExtra("channelID", 0), sendNumber());
	            	//Toast.makeText(getApplicationContext(), "CHANNEL_CONFIRMED", Toast.LENGTH_SHORT).show();
	            } else if (action.equals(BumpAPIIntents.CONNECTED)) {
	                api.enableBumping();
	                bumpStatus = true;
	                invalidateOptionsMenu();
	                Log.i("Status","ok");
	                Toast.makeText(getApplicationContext(), "CONNECTED", Toast.LENGTH_SHORT).show();
	            } else{
	            	Log.i(tag,"Get this action: "+action.toString());
	            	//Toast.makeText(getApplicationContext(), "No contact, try again", Toast.LENGTH_SHORT).show();		            
	            }	            
	        } catch (RemoteException e) {
	        	e.printStackTrace();
	        }
	    }
	};
	
	private final ServiceConnection connection = new ServiceConnection() {	    
		public void onServiceConnected(ComponentName className, IBinder binder) {
			Log.i(tag,"onServiceConnected");
	        api = IBumpAPI.Stub.asInterface(binder);	        
	        Log.i(tag,"after IBumpAPI.Stub.asInterface(binder)");
	        try {
	            new Thread(new Runnable() {					
					public void run() {
						try{
							Log.i(tag,"Inner Try! before api.configured");							
							//api.configure("8cdf424bb78349c6bfafb9f22f2788a4", "Cheb");							
							api.configure("de703e6680454adbbf3d1ac99727c9b0", "Cheb");//Max ID
							//api.configure("004d36464fba4d8a99db91ab389929c7", "Cheb");//New Cheb ID
							//api.configure("b00609a8b2f143edba70f8e0bee2754e", "Cheb");//Old ChebID
							Log.i(tag,"Inner Try! after api.configured");
						}catch (RemoteException e) {
							Log.i(tag,"RemoteException error: "+ e.toString());
						}
					}
				}).start();        	
	        } catch (Exception e) {
	        	Log.i(tag,"catch error: "+ e.toString());	
	        }	        	
	    }
		public void onServiceDisconnected(ComponentName name) {}
	};
	
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
		if (position != 0){
			BitmapFactory.Options o2 = new BitmapFactory.Options();
	    	o2.inSampleSize=1;
	    	Bitmap bm = BitmapFactory.decodeResource(getResources(), images[position], o2);
	    	imgEgg.setImageBitmap(bm);
		}else{
			showPhotoDialog();
		}
	}	

	private void showPhotoDialog(){
		ad = new AlertDialog.Builder(this);
		ad.setTitle("Choose source"); // 
		ad.setMessage("Camera or gallery"); // 
		ad.setCancelable(true);
		ad.setPositiveButton("Camera", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				openCamera();
			}
		});
		ad.setNeutralButton("Gallery", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				openGallery();
			}
		});
		ad.show();		
	}
	
	private void openCamera(){
	Log.i("Opt","Camera");
	Log.d("ANDRO_CAMERA", "Starting camera on the phone...");
	        String fileName = "testphoto.jpg";
	        ContentValues values = new ContentValues();
	        values.put(MediaStore.Images.Media.TITLE, fileName);
	        values.put(MediaStore.Images.Media.DESCRIPTION,
	                "Image capture by camera");
	        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");
	        imageUri = this.getContentResolver().insert( MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
	        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
	        intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
	        intent.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, 1);
	        startActivityForResult(intent, SELECT_CAMERA);
	}
	
	private void openGallery(){
		Log.i("Opt","Gallery");
		Intent photoPickerIntent = new Intent(Intent.ACTION_PICK);
		photoPickerIntent.setType("image/*");
		startActivityForResult(photoPickerIntent, SELECT_GALERY);
	}
	
	
	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		switch(requestCode) {
			case SELECT_GALERY:
				if(resultCode == Activity.RESULT_OK){
					setImage(data.getData());	
				}
					break;
			case SELECT_CAMERA:
				if(resultCode == Activity.RESULT_OK){
					setImage(imageUri);	
				}
				break;	
	
		}	
	}
	
	private Boolean setImage(Uri uri) {
		Log.i("Image URI", uri.toString());
		// Log.i("Image File path", getRealPathFromURI(uri));
		try {
			if (((BitmapDrawable) imgEgg.getDrawable()) != null)
				(((BitmapDrawable) imgEgg.getDrawable()).getBitmap()).recycle();
			InputStream imageStream = getContentResolver().openInputStream(uri);
			Bitmap bmp = BitmapFactory.decodeStream(imageStream);
			int width = bmp.getWidth();
			int height = bmp.getHeight();
			float k;
			if (width > height) {
				if (width > 2048) {
					k = width / height;
					width = 2048;
					height = (int) (2048 / k);
					imgEgg.setImageBitmap(Bitmap.createScaledBitmap(bmp, width,
							height, false));
				} else {
					imgEgg.setImageBitmap(bmp);
				}
			} else {
				if (height > 2048) {
					k = height / width;
					height = 2048;
					width = (int) (2048 / k);
					imgEgg.setImageBitmap(Bitmap.createScaledBitmap(bmp, width,
							height, false));
				} else {
					imgEgg.setImageBitmap(bmp);
				}
			}
			// imgInit = true;
			return true;
		} catch (FileNotFoundException e) {
			Log.i("FileNotFound", "FileNotFound");
			e.printStackTrace();
			return false;
		}
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getSupportMenuInflater().inflate(R.menu.main, menu);
		if (bumpStatus){
			MenuItem statusMenu = menu.findItem(R.id.action_status);
			statusMenu.setIcon(R.drawable.ic_action_ok);
		}
		shareMenuItem(menu);
		return true;
	}
	
	@Override
	public boolean onMenuItemSelected(int featureId, MenuItem item) {
		switch (item.getItemId()) {
		case R.id.settings:
			startActivity(new Intent(this, SettingsActivity.class));
			break;
		case R.id.rating:
			startActivity(new Intent(this, RatingActivity.class));
			break;
		default:
			break;
		}
		return super.onMenuItemSelected(featureId, item);
	}

	private void shareMenuItem(Menu menu){
		MenuItem menuItem = menu.findItem(R.id.share);
		ShareActionProvider mShareActionProvider = (ShareActionProvider) menuItem.getActionProvider();
		Intent shareIntent = new Intent(Intent.ACTION_SEND);
		shareIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
		shareIntent.setType("text/plain");
		shareIntent.putExtra(Intent.EXTRA_TEXT, getString(R.string.sharesubject));
		shareIntent.putExtra(Intent.EXTRA_SUBJECT,getString(R.string.sharetext));
		mShareActionProvider.setShareIntent(shareIntent);
	}   
}