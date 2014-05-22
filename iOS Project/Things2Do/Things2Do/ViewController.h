//
//  ViewController.h
//  Things2Do
//
//  Created by Justin Tilley on 5/8/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ViewController : UIViewController
{
    IBOutlet UITextField *userText;
    IBOutlet UITextField *passText;
    IBOutlet UITextField *emailText;
    IBOutlet UILabel *emailLabel;
    IBOutlet UIButton *loginButton;
    IBOutlet UIButton *signUpButton;
    IBOutlet UIButton *cancelButton;
}

-(IBAction)onClick:(id)sender;
-(IBAction)hideKeyboard:(id)sender;
@end
