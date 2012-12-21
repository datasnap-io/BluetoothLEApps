//
//  SensorTableViewCell.h
//  SensorApp
//
//  Created by Scott Gruby on 12/19/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SensorTag.h"

@interface SensorTableViewCell : UITableViewCell
@property (nonatomic, strong) SensorTag *sensorTag;
@property (nonatomic, assign) SensorType cellType;
- (void) setupCell;
@end
