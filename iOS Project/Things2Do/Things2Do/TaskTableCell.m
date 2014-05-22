//
//  TaskTableCell.m
//  Things2Do
//
//  Created by Justin Tilley on 5/19/14.
//  Copyright (c) 2014 Justin Tilley. All rights reserved.
//

#import "TaskTableCell.h"

@implementation TaskTableCell
@synthesize taskName, taskTime, taskDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) refreshCell
{
    taskLabel.text = taskName;
    timeLabel.text = [[NSString alloc] initWithFormat:@"Hours: %@", taskTime];
    dateLabel.text = [[NSString alloc] initWithFormat:@"Date: %@", taskDate];
}

@end
