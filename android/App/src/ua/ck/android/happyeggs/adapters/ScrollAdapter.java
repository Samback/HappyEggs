package ua.ck.android.happyeggs.adapters;

import ua.ck.android.happyeggs.R;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

public class ScrollAdapter extends BaseAdapter {
	private int mCount;
	private Context mContext;
	private LayoutInflater mInflator;
	private int[] images;
	
	
	public ScrollAdapter(int mCount, Context mContext, int[] images) {
		super();
		this.mCount = mCount;
		this.mContext = mContext;
		this.mInflator = LayoutInflater.from(mContext);
		this.images = images;
	}

	@Override
	public int getCount() {
		return mCount;
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View v = mInflator.inflate(R.layout.item_scroll, null);
		ImageView imgChooseEgg = (ImageView)v.findViewById(R.id.imgChooseEgg);
	    BitmapFactory.Options o2 = new BitmapFactory.Options();
	    o2.inSampleSize=10;
	    Bitmap bm = BitmapFactory.decodeResource(mContext.getResources(), images[position], o2);
	    imgChooseEgg.setImageBitmap(bm);
		return v;
	}

}
