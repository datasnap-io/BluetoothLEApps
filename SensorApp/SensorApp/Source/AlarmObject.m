//
//  AlarmObject.m
//  SensorApp
//
//  Created by Scott Gruby on 12/24/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "AlarmObject.h"

@interface AlarmObject ()
@property (nonatomic, assign) NSUInteger numBelow;
@property (nonatomic, assign) NSUInteger numAbove;
@end

@implementation AlarmObject
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeInteger:self.sensorType forKey:@"SensorType"];
	[aCoder encodeInteger:self.minValue forKey:@"minValue"];
	[aCoder encodeInteger:self.maxValue forKey:@"maxValue"];
	[aCoder encodeBool:self.alarmOn forKey:@"alarmOn"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		_sensorType = [aDecoder decodeIntegerForKey:@"SensorType"];
		_minValue = [aDecoder decodeIntegerForKey:@"minValue"];
		_maxValue = [aDecoder decodeIntegerForKey:@"maxValue"];
		_alarmOn = [aDecoder decodeBoolForKey:@"alarmOn"];
	}
	
	return self;
}

- (void) setCount:(NSUInteger) value
{
	if (self.alarmOn)
	{
		if (value < self.minValue)
		{
			self.numBelow++;
		}
		else if (value > self.maxValue)
		{
			self.numAbove++;
		}
		// Reset the values if they are out of range.
		// This helps to present false positives
		// when the sensor hasn't settled down
		else
		{
			self.numAbove = 0;
			self.numBelow = 0;
		}
	}
}

- (void) clearValueCount
{
	self.numAbove = 0;
	self.numBelow = 0;
}

- (BOOL) lowValueAlarm
{
	BOOL result = self.alarmOn && (self.numBelow >= kNumberOfReadsForAlarm);
	if (result)
	{
		if (self.lastAlarmDate != nil)
		{
			NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastAlarmDate];
			if (timeInterval >= kTimeIntervalBetweenAlarms)
			{
				self.lastAlarmDate = [NSDate date];
			}
			else
			{
				result = NO;
			}
		}
		else
		{
			self.lastAlarmDate = [NSDate date];
		}
	}
	return result;
}

- (BOOL) highValueAlarm
{
	BOOL result = self.alarmOn && (self.numAbove >= kNumberOfReadsForAlarm);
	if (result)
	{
		if (self.lastAlarmDate != nil)
		{
			NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastAlarmDate];
			if (timeInterval >= kTimeIntervalBetweenAlarms)
			{
				self.lastAlarmDate = [NSDate date];
			}
			else
			{
				result = NO;
			}
		}
		else
		{
			self.lastAlarmDate = [NSDate date];
		}
	}
	return result;
}


@end
