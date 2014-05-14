package com.jtilley.things2do;
//Justin Tilley
//CPMD 
//Project 1

import java.util.List;

import com.parse.DeleteCallback;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import android.app.Activity;
import android.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
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
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
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
			Log.i("USER", current.toString());
			setTitle(current.getUsername() + "'s List");
			getList();
		}
	}
	
	//Get List of Tasks linked to Current User
	public void getList(){
		ParseQuery<ParseObject> query = ParseQuery.getQuery("Task");
		query.whereEqualTo("User", ParseUser.getCurrentUser());
		query.findInBackground(new FindCallback<ParseObject>() {
	
			@Override
			public void done(List<ParseObject> list, ParseException e) {
				// TODO Auto-generated method stub
				if(e == null){
					frag.displayList(list);
				}
			}
		});
	}
	
	//LogOut Current User and navigate to Login
	public void logoutUser(){
		ParseUser.logOut();
		Intent intent = new Intent(this, MainActivity.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
		startActivity(intent);
	}
	
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
			
			if(item.getItemId() == 1){
				String name = (String) temp.get("Name");
				String date = (String) temp.get("Date");
				int time = Integer.valueOf(temp.get("Time").toString());
				activity.displayAddItem(name, date, time, temp.getObjectId().toString());
			}else if(item.getItemId() == 2){
				temp.deleteInBackground(new DeleteCallback() {
					
					@Override
					public void done(ParseException arg0) {
						// TODO Auto-generated method stub
						activity.getList();
					}
				});
				
			}
			
			return super.onContextItemSelected(item);
		}
	}
}
