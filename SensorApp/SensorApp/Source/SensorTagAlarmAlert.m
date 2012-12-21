//
//  SensorTagAlarmAlert.m
//  SensorApp
//
//  Created by Scott Gruby on 12/19/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "SensorTagAlarmAlert.h"

@implementation SensorTagAlarmAlert
- (void) presentAlarmAlert
{
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
	//if ([[UIApplication sharedApplication].isAct])
}
@end
