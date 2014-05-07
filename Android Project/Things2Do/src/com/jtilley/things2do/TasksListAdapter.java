package com.jtilley.things2do;

import java.util.ArrayList;
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
		return position;
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@SuppressWarnings("unchecked")
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
		
		ParseObject object = taskList.get(position);
		ArrayList<String> name = (ArrayList<String>) object.get("Name");
		ArrayList<String> date = (ArrayList<String>) object.get("Date");
		ArrayList<Integer> time = (ArrayList<Integer>) object.get("Time");
		taskName.setText(name.get(0).toString());
		taskDate.setText("Date:\n " + date.get(0).toString());
		taskTime.setText("Hours: " + time.get(0).toString());
		
		return view;
	}

}
