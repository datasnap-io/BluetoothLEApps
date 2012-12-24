//
//  SetupAlarmViewController.h
//  SensorApp
//
//  Created by Scott Gruby on 12/24/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SensorTag.h"

@class AlarmObject;

@interface SetupAlarmViewController : UIViewController
@property (nonatomic, assign) SensorType sensorType;
@property (nonatomic, strong) AlarmObject *alarm;
@end
