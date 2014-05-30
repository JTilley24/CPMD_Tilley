package com.jtilley.things2do;
//Justin Tilley
//CPMD 
//Project 4
import com.parse.Parse;

import android.app.Application;

public class MainApplication extends Application {

	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		//Initialize Parse
		Parse.enableLocalDatastore(this);
		Parse.initialize(this,"CdeHn8mEBCyXEyUSXakxslroJJ7s3rhssAatCooS", "4rUjsJqJamYFQdOyZ9J3eegMdJRXMkOMlwVL8YZV");
	}

}
