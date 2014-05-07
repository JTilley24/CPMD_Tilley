package com.jtilley.things2do;

import android.app.Activity;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.LogInCallback;
import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParseUser;
import com.parse.SignUpCallback;

public class MainActivity extends Activity {
Context mContext;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		mContext = this;
		
		GetParse getParse = new GetParse();
		getParse.execute();
		
		
		
		if (savedInstanceState == null) {
			getFragmentManager().beginTransaction()
					.add(R.id.container, new PlaceholderFragment(this)).commit();
		}
	}
	
	public class GetParse extends AsyncTask<Void, Void, Void> {

		@Override
		protected Void doInBackground(Void... params) {
			// TODO Auto-generated method stub
			Parse.initialize(mContext,"CdeHn8mEBCyXEyUSXakxslroJJ7s3rhssAatCooS", "4rUjsJqJamYFQdOyZ9J3eegMdJRXMkOMlwVL8YZV");
			ParseUser current = ParseUser.getCurrentUser();
			if(current != null){
				Log.i("Current", current.getUsername().toString());
				Intent intent = new Intent(mContext, ListActivity.class);
				startActivity(intent);
			}
		return null;
			
		}
		
	}
	
	public void signUpAccount(final String userName, final String password, String email){
		ParseUser newUser = new ParseUser();
		newUser.setUsername(userName);
		newUser.setPassword(password);
		newUser.setEmail(email);
		newUser.signUpInBackground(new SignUpCallback() {
			
			@Override
			public void done(ParseException e) {
				// TODO Auto-generated method stub
				if(e == null){
					loginAccount(userName, password);
				}else{
					if(e.getCode() == ParseException.USERNAME_TAKEN){
						Toast.makeText(mContext, e.getMessage(), Toast.LENGTH_LONG).show();
					}else if(e.getCode() == ParseException.EMAIL_TAKEN){
						Toast.makeText(mContext, e.getMessage(), Toast.LENGTH_LONG).show();
					}
				}
			}
		});
	}

	public void loginAccount(String userName, String password){
		ParseUser.logInInBackground(userName, password, new LogInCallback() {
			
			@Override
			public void done(ParseUser user, ParseException e) {
				// TODO Auto-generated method stub
				if(user != null){
					Intent intent = new Intent(mContext, ListActivity.class);
					startActivity(intent);
				}else{
					Toast.makeText(mContext, e.getMessage(), Toast.LENGTH_LONG).show();
				}
			}
		});
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
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
		}
		return super.onOptionsItemSelected(item);
	}

	/**
	 * A placeholder fragment containing a simple view.
	 */
	public static class PlaceholderFragment extends Fragment {
	MainActivity activity;
	Boolean signUp;
	Button signupButton;
	Button loginButton;
	Button cancelButton;
	TextView emailTitle;
	EditText emailInput;
	EditText userInput;
	EditText passwordInput;
	
		public PlaceholderFragment(MainActivity act) {
			activity = act;
		}

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {
			View rootView = inflater.inflate(R.layout.fragment_main, container,
					false);
			signUp = false;
			loginButton = (Button) rootView.findViewById(R.id.loginButton);
			signupButton = (Button) rootView.findViewById(R.id.signupButton);
			cancelButton = (Button) rootView.findViewById(R.id.cancelSignButton);
			emailTitle = (TextView) rootView.findViewById(R.id.emailTitle);
			emailInput = (EditText) rootView.findViewById(R.id.emailInput);
			userInput = (EditText) rootView.findViewById(R.id.userInput);
			passwordInput = (EditText) rootView.findViewById(R.id.passwordInput);
			
			loginButton.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					Boolean validate = true;
					if(userInput.getText().length() == 0){
						userInput.setError("Username is required!");
						validate = false;
					}
					if(passwordInput.getText().length() == 0){
						passwordInput.setError("Password is required!");
						validate = false;
					}
					if(validate == true){
						activity.loginAccount(userInput.getText().toString(), passwordInput.getText().toString());
					}
				}
			});
			
			signupButton.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					if(signUp == false){
						loginButton.setVisibility(View.GONE);
						cancelButton.setVisibility(View.VISIBLE);
						emailTitle.setVisibility(View.VISIBLE);
						emailInput.setVisibility(View.VISIBLE);
						signUp = true;
					}
					else if(signUp == true){
						Boolean validate = true;
						if(userInput.getText().length() == 0){
							userInput.setError("Username is required!");
							validate = false;
						}
						if(passwordInput.getText().length() == 0){
							passwordInput.setError("Password is required!");
							validate = false;
						}
						if(emailInput.getText().length() == 0){
							emailInput.setError("Email is required!");
							validate = false;
						}
						if(validate == true){
							activity.signUpAccount(userInput.getText().toString(), passwordInput.getText().toString(), emailInput.getText().toString());
							signUp = false;
						}
					}
				}
			});
			
			cancelButton.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					loginButton.setVisibility(View.VISIBLE);
					cancelButton.setVisibility(View.GONE);
					emailTitle.setVisibility(View.GONE);
					emailInput.setVisibility(View.GONE);
					userInput.setText("");
					passwordInput.setText("");
				}
			});
			return rootView;
		}
	}

}
