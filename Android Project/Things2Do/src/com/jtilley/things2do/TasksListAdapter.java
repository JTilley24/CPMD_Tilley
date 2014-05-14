package com.jtilley.things2do;
//Justin Tilley
//CPMD 
//Project 1

import java.util.List;

import com.parse.ParseObject;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class TasksListAdapter extends BaseAdapter{
private Activity activity;
public static List<ParseObject> taskList;
private static LayoutInflater inflater = null;

	public TasksListAdapter(Activity act, List<ParseObject> list){
		activity = act;
		taskList = list;
		inflater = (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	}
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return taskList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return taskList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		View view = convertView;
		if(view == null){
			view = inflater.inflate(R.layout.task_list_row, null);
		}
		
		TextView taskName = (TextView) view.findViewById(R.id.taskName);
		TextView taskTime = (TextView) view.findViewById(R.id.taskTime);
		TextView taskDate = (TextView) view.findViewById(R.id.taskDate);
		//Set ParseObject data to each row
		ParseObject object = taskList.get(position);
		String name = (String) object.get("Name");
		String date = (String) object.get("Date");
		int time = Integer.valueOf(object.get("Time").toString());
		taskName.setText(name);
		taskDate.setText("Date:\n " + date);
		taskTime.setText("Hours: " + time);
		
		return view;
	}

}
