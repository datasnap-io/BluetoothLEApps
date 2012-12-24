//
//  SensorTagAlarmAlert.h
//  SensorApp
//
//  Created by Scott Gruby on 12/19/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorTag.h"

@interface SensorTagAlarmAlert : NSObject
@property (nonatomic, assign) SensorType sensorType;
@property (nonatomic, assign) BOOL below; // If false, it is above
@property (nonatomic, assign) NSUInteger alarmValue;
@property (nonatomic, assign) double currentValue;
- (void) presentAlarmAlert;
@end
