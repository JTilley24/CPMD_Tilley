package com.jtilley.things2do;
//Justin Tilley
//CPMD 
//Project 4

import java.util.Calendar;
import java.util.List;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup;
import android.widget.DatePicker;
import android.widget.EditText;

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

public class AddItemActivity extends Activity {
PlaceholderFragment frag;
Context mContext;
DateDialog dateDialog;
public String objectName;
public String objectDate;
public int objectTime;
public String objectId;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_add_item);
		
		mContext = this;
		
		Intent intent = this.getIntent();
		objectName = intent.getStringExtra("name");
		objectDate = intent.getStringExtra("date");
		objectTime = intent.getIntExtra("time", 0);
		objectId = intent.getStringExtra("objectid");
		
		
		if (savedInstanceState == null) {
			frag = new PlaceholderFragment(this);
			frag.setRetainInstance(true);
			getFragmentManager().beginTransaction()
					.add(R.id.container, frag, "add_frag").commit();
		}else{
			frag = (PlaceholderFragment) getFragmentManager().findFragmentByTag("add_frag");
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.add_item, menu);
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
		}else if(id == R.id.action_accept){
			try {
				frag.getInputs();
			} catch (NumberFormatException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else if(id == R.id.action_logout){
			logoutUser();
		}
		return super.onOptionsItemSelected(item);
	}
	
	//Check for Network Connection
	public Boolean checkConnection(){
		Boolean connected;
		
		ConnectivityManager connManager = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo network = connManager.getActiveNetworkInfo();
		connected = network != null && network.isConnectedOrConnecting();

		return connected;
	}
	
	//LogOut User and navigate back to Login
	public void logoutUser(){
		ParseUser.logOut();
		Intent intent = new Intent(this, MainActivity.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
		startActivity(intent);
	}
	
	//Save Item and link to Current User
	public void saveItem(final String name, final String date, final int time){
		//Check for Editing Object or New Task
		if(objectId != null){
			ParseQuery<ParseObject> query = ParseQuery.getQuery("Task");
			if(!checkConnection()){
				query.fromLocalDatastore();
				
				query.findInBackground(new FindCallback<ParseObject>() {
					
					@Override
					public void done(List<ParseObject> list, ParseException e) {
						// TODO Auto-generated method stub
						for(int i = 0; i< list.size(); i++){
							ParseObject temp = list.get(i);
							if(list.get(i).getObjectId().equalsIgnoreCase(objectId)){
								temp.put("Name", name);
								temp.put("Date", date);
								temp.put("Time", time);
								temp.saveEventually(new SaveCallback() {
									
									@Override
									public void done(ParseException arg0) {
										// TODO Auto-generated method stub
										timeStamp();
									}
								});
								setChanges();
								finish();
							}
						}
					}
				});
			}else{
				query.getInBackground(objectId, new GetCallback<ParseObject>() {
					
					@Override
					public void done(ParseObject task, com.parse.ParseException e) {
						// TODO Auto-generated method stub
						if(e == null){
							task.put("Name", name);
							task.put("Date", date);
							task.put("Time", time);
							task.saveInBackground(new SaveCallback() {
									
									@Override
									public void done(ParseException arg0) {
										// TODO Auto-generated method stub
										timeStamp();
										finish();
									}
								});
						}
					}
				});
			}
		}else{
			ParseUser current = ParseUser.getCurrentUser();
			ParseObject task = new ParseObject("Task");
			
			task.put("Name", name);
			task.put("Date", date);
			task.put("Time", time);
			task.put("User", current);
			if(checkConnection()){
				task.saveInBackground(new SaveCallback() {
					
					@Override
					public void done(ParseException arg0) {
						// TODO Auto-generated method stub
						timeStamp();
						finish();
					}
				});
			}else{
				task.saveEventually(new SaveCallback() {
					
					@Override
					public void done(ParseException arg0) {
						// TODO Auto-generated method stub
						timeStamp();
					}
				});
				setChanges();
				finish();
			}
		}
	}
	
	//TimeStamp For Sync
	public void timeStamp(){
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
	
	//Set Offline Changes
	public void setChanges(){
		SharedPreferences prefs = getSharedPreferences(ParseUser.getCurrentUser().getUsername(), 0);
		SharedPreferences.Editor editPrefs = prefs.edit();
		editPrefs.putBoolean("Changed", true);
		editPrefs.commit();
	}
	
	//Display DialogFragment for Date Input
	public class DateDialog extends DatePickerDialog{

		public DateDialog(Context context,
				OnDateSetListener callBack, int year, int monthOfYear,
				int dayOfMonth) {
			
			super(context, callBack, year, monthOfYear, dayOfMonth);
			// TODO Auto-generated constructor stub
		}
	}
	
	//Open DateDialog when Date Input is selected
	public void displayDateDialog(Boolean focus){
		if(focus){
			Calendar cal = Calendar.getInstance();
			if(objectDate != null){
				String[] dateString = objectDate.split("/");
				cal.set(Calendar.YEAR, Integer.valueOf(dateString[2]));
				cal.set(Calendar.MONTH, Integer.valueOf(dateString[0]));
				cal.set(Calendar.DAY_OF_MONTH, Integer.valueOf(dateString[1]));
			}
			
			dateDialog = new DateDialog(this, new OnDateSetListener() {
				
				@Override
				public void onDateSet(DatePicker view, int year, int monthOfYear,
						int dayOfMonth) {
					// TODO Auto-generated method stub
					frag.setDateInput(year, monthOfYear, dayOfMonth);
				}
			}, cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.get(Calendar.DAY_OF_MONTH));
			
			dateDialog.getDatePicker().setMinDate(Calendar.getInstance().getTimeInMillis() - 1000);
			
			dateDialog.show();
		}else{
			dateDialog.dismiss();
		}
	}

	/**
	 * A placeholder fragment containing a simple view.
	 */
	public static class PlaceholderFragment extends Fragment {
	AddItemActivity activity;
	EditText taskInput;
	EditText dateInput;
	EditText timeInput;
	String date;
		public PlaceholderFragment(AddItemActivity act) {
			activity = act;
		}

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {
			View rootView = inflater.inflate(R.layout.fragment_add_item,
					container, false);
		
			taskInput = (EditText) rootView.findViewById(R.id.taskNameInput);
			dateInput = (EditText) rootView.findViewById(R.id.dateInput);
			dateInput.setOnFocusChangeListener(new OnFocusChangeListener() {
				
				@Override
				public void onFocusChange(View v, boolean hasFocus) {
					// TODO Auto-generated method stub
					
						activity.displayDateDialog(hasFocus);
					
				}
			});
			timeInput = (EditText) rootView.findViewById(R.id.timeInput);
			
			if(activity.objectName != null){
				displayEdit(activity.objectName, activity.objectDate, activity.objectTime);
			}
			
			return rootView;
		}
		
		public void displayEdit(String name, String date, int time){
			taskInput.setText(name);
			dateInput.setText(date);
			timeInput.setText(String.valueOf(time));
		}
		
		//Set selected Date to input
		public void setDateInput(int year, int month, int day){
			date = month + "/" + day + "/" + year;
			dateInput.setText(date);
			getView().clearFocus();
		}
		
		//Range Validation for Time input
		public Boolean timeValidate(int time){
			if(time <= 24 && time >= 1){
				return true;
			}else{
				return false;
			}
		}
		
		//Validate and call saveItem
		public void getInputs() throws NumberFormatException{
			Boolean validate = true;
			if(taskInput.getText().length() == 0){
				taskInput.setError("Task is required!");
				validate = false;
			}
			if(dateInput.getText().length() == 0){
				dateInput.setError("Date is required!");
				validate = false;
			}
			if(timeInput.getText().length() == 0){
				timeInput.setError("Estimated Hours is required!");
				validate = false;
			}
			int time = Integer.valueOf(timeInput.getText().toString());
			if(!timeValidate(time)){
				timeInput.setError("Hours must be between 1 and 24");
				validate = false;
			}
			if(validate == true){
					activity.saveItem(taskInput.getText().toString(), dateInput.getText().toString(), Integer.valueOf(timeInput.getText().toString()));
				
			}
		}
	}

}
