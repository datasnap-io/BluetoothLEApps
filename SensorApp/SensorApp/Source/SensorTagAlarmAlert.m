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
	NSString *sensorString = nil;
	NSString *sensorUnitsString = nil;
	switch (self.sensorType)
	{
		case kSensorAmbientTemperatureType:
		{
			sensorString = NSLocalizedString(@"Ambient temperature", nil);
			if (![[NSUserDefaults standardUserDefaults] boolForKey:kUseCelsiusTemperature])
			{
				sensorUnitsString = @"ºF";
			}
			else
			{
				sensorUnitsString = @"ºC";
			}
			break;
		}
			
		case kSensorObjectTemperatureType:
		{
			sensorString = NSLocalizedString(@"Object temperature", nil);
			if (![[NSUserDefaults standardUserDefaults] boolForKey:kUseCelsiusTemperature])
			{
				sensorUnitsString = @"ºF";
			}
			else
			{
				sensorUnitsString = @"ºC";
			}
			break;
		}
			
		case kSensorHumidityType:
		{
			sensorString = NSLocalizedString(@"Relative humidity", nil);
			sensorUnitsString= @"% rH";
			break;
		}
			
		case kSensorPressureType:
		{
			sensorString = NSLocalizedString(@"Pressure", nil);
			sensorUnitsString = @" mbar";
			break;
		}
	}
	
	NSString *alertMessage = [NSString stringWithFormat:@"%@ is %@ %lu%@", sensorString, self.below ? NSLocalizedString(@"below", nil) : NSLocalizedString(@"above", nil), (unsigned long)self.alarmValue, sensorUnitsString];

	if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sensor Alarm", nil) message:alertMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
		[alert show];
	}
	else
	{
		UILocalNotification *notification = [[UILocalNotification alloc] init];
		notification.alertBody = alertMessage;
		notification.soundName = UILocalNotificationDefaultSoundName;
		[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
	}
}
@end
