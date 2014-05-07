package com.jtilley.things2do;

import java.util.Calendar;

import org.json.JSONException;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Dialog;
import android.app.DialogFragment;
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup;
import android.widget.DatePicker;
import android.widget.EditText;

import com.parse.ParseACL;
import com.parse.ParseObject;
import com.parse.ParseUser;

public class AddItemActivity extends Activity {
PlaceholderFragment frag;
DialogFragment dateDialog;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_add_item);
		
		frag = new PlaceholderFragment(this);
		
		if (savedInstanceState == null) {
			getFragmentManager().beginTransaction()
					.add(R.id.container, frag).commit();
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
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return super.onOptionsItemSelected(item);
	}
	
	public void saveItem(String name, String date, int time) throws JSONException{
		ParseUser current = ParseUser.getCurrentUser();
		ParseObject task = new ParseObject("Task");
		
		task.add("Name", name);
		task.add("Date", date);
		task.add("Time", time);
		task.setACL(new ParseACL(current));
		task.add("User", current);
		task.saveInBackground();
		finish();
	}
	
	public class DateDialog extends DialogFragment implements OnDateSetListener{

		@Override
		public Dialog onCreateDialog(Bundle savedInstanceState) {
			// TODO Auto-generated method stub
			Calendar calendar = Calendar.getInstance();
			int year = calendar.get(Calendar.YEAR);
			int month = calendar.get(Calendar.MONTH);
			int day = calendar.get(Calendar.DAY_OF_MONTH);
			return new DatePickerDialog(getActivity(), this, year, month, day);
		}

		@Override
		public void onDateSet(DatePicker view, int year, int monthOfYear,
				int dayOfMonth) {
			// TODO Auto-generated method stub
			frag.setDateInput(year, monthOfYear, dayOfMonth);
		}
		
	}
	
	public void displayDateDialog(Boolean focus){
		if(focus){
			dateDialog = new DateDialog();
			dateDialog.show(getFragmentManager(), "DateDialog");
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
			return rootView;
		}
		
		public void setDateInput(int year, int month, int day){
			date = month + "/" + day + "/" + year;
			dateInput.setText(date);
			getView().clearFocus();
		}
		public void getInputs() throws NumberFormatException, JSONException{
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
			if(validate == true){
				activity.saveItem(taskInput.getText().toString(), date, Integer.valueOf(timeInput.getText().toString()));
			}
		}
	}

}
