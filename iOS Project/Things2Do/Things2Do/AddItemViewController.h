//
//  AddItemViewController.h
//  Things2Do
//
//  Created by Justin Tilley on 5/21/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddItemViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *nameText;
    IBOutlet UITextField *dateText;
    IBOutlet UITextField *timeText;
    IBOutlet UIDatePicker *datePicker;
    NSDateFormatter *dateFormat;
    NSString *dateString;
    NSString *newDate;
    NSMutableString *alertString;
}
@property(nonatomic, strong) PFObject *editObject;
-(IBAction)onClick:(id)sender;
-(IBAction)onChange:(id)sender;
@end
