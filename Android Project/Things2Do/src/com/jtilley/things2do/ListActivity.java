package com.jtilley.things2do;
//Justin Tilley
//CPMD 
//Project 2

import java.util.List;

import com.parse.DeleteCallback;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import android.app.Activity;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.View.OnCreateContextMenuListener;
import android.view.ViewGroup;
import android.widget.AdapterView.AdapterContextMenuInfo;
import android.widget.ListView;
import android.widget.TextView;

public class ListActivity extends Activity {
PlaceholderFragment frag;
String timeStamp;
Context mContext;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		mContext = this;
		
		setContentView(R.layout.activity_list);

		if (savedInstanceState == null) {
			frag = new PlaceholderFragment(this);
			frag.setRetainInstance(true);
			getFragmentManager().beginTransaction()
					.add(R.id.container, frag, "list_frag").commit();
		}else{
			frag = (PlaceholderFragment) getFragmentManager().findFragmentByTag("list_frag");
		}
		
		
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		//Get and Display Current User Data
		ParseUser current = ParseUser.getCurrentUser();
		if(current != null){
			setTitle(current.getUsername() + "'s List");
			getList();
			
			ParseQuery<ParseObject> query = ParseQuery.getQuery("Changes");
			query.whereEqualTo("User", current.getUsername());
			query.findInBackground(new FindCallback<ParseObject>() {
				
				@Override
				public void done(List<ParseObject> list, ParseException e) {
					// TODO Auto-generated method stub
					if(e == null){
						if(list.size() > 0){
							timeStamp = list.get(0).getString("TimeStamp");
						}
					}
				}
			});
			checkOfflineChanges();
			final Handler parseHandler = new Handler();
			final Runnable parseSync = new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					checkChanges();
					parseHandler.postDelayed(this, 10000);
				}
			};
			parseHandler.postDelayed(parseSync, 10000);
			
		}
	}
	
	//Get List of Tasks linked to Current User
	public void getList(){
		ParseQuery<ParseObject> query = ParseQuery.getQuery("Task");
		query.whereEqualTo("User", ParseUser.getCurrentUser());
		if(checkConnection() == false){
			query.fromLocalDatastore();
		}
		query.findInBackground(new FindCallback<ParseObject>() {
	
			@Override
			public void done(List<ParseObject> list, ParseException e) {
				// TODO Auto-generated method stub
				if(e == null){
					if(checkConnection()){	
						ParseObject.unpinAllInBackground();
					}
					ParseObject.pinAllInBackground(list);
					frag.displayList(list);
				}
			}
		});
	}
	
	public void setTimeStamp(){
		ParseQuery<ParseObject> query = ParseQuery.getQuery("Changes");
		query.findInBackground(new FindCallback<ParseObject>() {
			
			@Override
			public void done(List<ParseObject> list, ParseException e) {
				// TODO Auto-generated method stub
				if(e == null){
					if(list.size() > 0){
						ParseObject temp = list.get(0);
						temp.put("User", ParseUser.getCurrentUser().getUsername());
						temp.put("TimeStamp", String.valueOf(System.currentTimeMillis()));
						temp.saveInBackground();
					}else{
						ParseObject timeSObject = new ParseObject("Changes");
						timeSObject.put("User", ParseUser.getCurrentUser().getUsername());
						timeSObject.put("TimeStamp", String.valueOf(System.currentTimeMillis()));
						timeSObject.saveInBackground();
					}
				}
			}
		});
	}
	
	public void checkOfflineChanges(){
		SharedPreferences prefs = getSharedPreferences(ParseUser.getCurrentUser().getUsername(), 0);
		if(prefs != null){
			Boolean changed = prefs.getBoolean("Changed", false);
			if(changed){
				ParseQuery<ParseObject> query = ParseQuery.getQuery("Changes");
				query.findInBackground(new FindCallback<ParseObject>() {
					
					@Override
					public void done(List<ParseObject> list, ParseException e) {
						// TODO Auto-generated method stub
						if(e == null){
							if(list.size() > 0){
								ParseObject temp = list.get(0);
								temp.put("User", ParseUser.getCurrentUser().getUsername());
								temp.put("TimeStamp", String.valueOf(System.currentTimeMillis()));
								temp.saveInBackground();
							}else{
								ParseObject timeSObject = new ParseObject("Changes");
								timeSObject.put("User", ParseUser.getCurrentUser().getUsername());
								timeSObject.put("TimeStamp", String.valueOf(System.currentTimeMillis()));
								timeSObject.saveInBackground();
							}
							
						}
					}
				});
				SharedPreferences.Editor editPrefs = prefs.edit();
				editPrefs.putBoolean("Changed", false);
				editPrefs.commit();
			}
		}
	}
	
	//Check Network Connection
	public Boolean checkConnection(){
		Boolean connected;
		
		ConnectivityManager connManager = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo network = connManager.getActiveNetworkInfo();
		connected = network != null && network.isConnectedOrConnecting();

		return connected;
	}
	
	//LogOut Current User and navigate to Login
	public void logoutUser(){
		ParseUser.logOut();
		Intent intent = new Intent(this, MainActivity.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
		startActivity(intent);
	}
	
	//Send Data from Selected Item and open Add Item Activity
	public void displayAddItem(String name, String date, int time, String objectid){
		Intent intent = new Intent(this, AddItemActivity.class);
		intent.putExtra("name", name);
		intent.putExtra("date", date);
		intent.putExtra("time", time);
		intent.putExtra("objectid", objectid);
		startActivity(intent);
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.list, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		if (id == R.id.action_settings) {
			return true;
		}else if(id == R.id.action_add){
			Intent intent = new Intent(this, AddItemActivity.class);
			startActivity(intent);
		}else if(id == R.id.action_logout){
			logoutUser();
		}
		return super.onOptionsItemSelected(item);
	}
	
	public void checkChanges(){
		
		ParseQuery<ParseObject> query = ParseQuery.getQuery("Changes");
		query.whereEqualTo("User", ParseUser.getCurrentUser().getUsername());
		query.findInBackground(new FindCallback<ParseObject>() {
			
			@Override
			public void done(List<ParseObject> list, ParseException e) {
				// TODO Auto-generated method stub
				if(e == null){
					if(list.size() > 0){
						String newTime = list.get(0).getString("TimeStamp");
						if(!timeStamp.equalsIgnoreCase(newTime)){
							getList();
						}
					}
				}
			}
		});
	}

	/**
	 * A placeholder fragment containing a simple view.
	 */
	public static class PlaceholderFragment extends Fragment {
	ListView taskList;
	TextView noDataText;
	ListActivity activity;
		public PlaceholderFragment(ListActivity act) {
			activity = act;
		}

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {
			View rootView = inflater.inflate(R.layout.fragment_list, container,
					false);
			taskList = (ListView) rootView.findViewById(R.id.taskList);
			noDataText = (TextView) rootView.findViewById(R.id.noDataText);
			
			//Long Click on List Item to Edit or Delete
			taskList.setOnCreateContextMenuListener(new OnCreateContextMenuListener() {
				 
				@Override
				public void onCreateContextMenu(ContextMenu menu, View v,
						ContextMenuInfo menuInfo) {
					// TODO Auto-generated method stub
						menu.add(0, 1, 0, "EDIT");
						menu.add(0, 2, 1, "DELETE");
				}
			});
			return rootView;
		}
		
		
		
		//Display List of Task
		public void displayList(List<ParseObject> list){
			if(list.size() != 0){
				noDataText.setVisibility(View.GONE);
				taskList.setVisibility(View.VISIBLE);
				taskList.setAdapter(new TasksListAdapter(activity, list));
				
			}else{
				taskList.setVisibility(View.GONE);
				noDataText.setVisibility(View.VISIBLE);
			}
		}

		
		@Override
		public boolean onContextItemSelected(MenuItem item) {
			// TODO Auto-generated method stub
			AdapterContextMenuInfo menuInfo = (AdapterContextMenuInfo) item.getMenuInfo();
			ParseObject temp = (ParseObject) taskList.getAdapter().getItem(menuInfo.position);
			//Edit or Delete Options
			if(item.getItemId() == 1){
				String name = (String) temp.get("Name");
				String date = (String) temp.get("Date");
				int time = Integer.valueOf(temp.get("Time").toString());
				activity.displayAddItem(name, date, time, temp.getObjectId().toString());
			}else if(item.getItemId() == 2){
				if(activity.checkConnection()){
					temp.deleteInBackground(new DeleteCallback() {
						
						@Override
						public void done(ParseException arg0) {
							// TODO Auto-generated method stub
							activity.getList();
							activity.setTimeStamp();
						}
					});
				}else{
					temp.deleteEventually();
					SharedPreferences prefs = activity.getSharedPreferences(ParseUser.getCurrentUser().getUsername(), 0);
					SharedPreferences.Editor editPrefs = prefs.edit();
					editPrefs.putBoolean("Changed", true);
					editPrefs.commit();
					activity.getList();
				}
			}
			
			return super.onContextItemSelected(item);
		}
	}
}
