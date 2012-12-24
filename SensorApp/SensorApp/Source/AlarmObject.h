//
//  AlarmObject.h
//  SensorApp
//
//  Created by Scott Gruby on 12/24/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmObject : NSObject <NSCoding>
@property (nonatomic, assign) NSUInteger sensorType;
@property (nonatomic, assign) BOOL alarmOn;
@property (nonatomic, assign) NSUInteger minValue;
@property (nonatomic, assign) NSUInteger maxValue;
@property (nonatomic, strong) NSDate *lastAlarmDate;

- (void) clearValueCount;
- (void) updateAlarmValue:(double) value;
- (BOOL) lowValueAlarm;
- (BOOL) highValueAlarm;
@end
