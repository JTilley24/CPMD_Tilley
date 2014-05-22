//
//  TaskTableCell.h
//  Things2Do
//
//  Created by Justin Tilley on 5/19/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskTableCell : UITableViewCell
{
    IBOutlet UILabel *taskLabel;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *dateLabel;
}
@property (nonatomic,strong) NSString *taskName;
@property (nonatomic,strong) NSString *taskTime;
@property (nonatomic,strong) NSString *taskDate;

-(void)refreshCell;
@end
