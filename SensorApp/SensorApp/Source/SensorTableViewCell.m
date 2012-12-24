//
//  SensorTableViewCell.m
//  SensorApp
//
//  Created by Scott Gruby on 12/19/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "SensorTableViewCell.h"

@interface SensorTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *mainValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *hasAlarmImageView;
@end

@implementation SensorTableViewCell
- (void) setupCell
{
	self.hasAlarmImageView.hidden = YES;
	NSString *label = nil;
	NSString *value = nil;
	switch (self.cellType)
	{
		case kSensorAmbientTemperatureType:
		{
			label = NSLocalizedString(@"Ambient Temperature", nil);
			if (self.sensorTag.hasAmbientTemperature)
			{
				double temp = self.sensorTag.ambientTemperature;
				NSString *scaleAbbreviation = @"C";
				if (![[NSUserDefaults standardUserDefaults] boolForKey:kUseCelsiusTemperature])
				{
					temp = temp * 1.8 + 32.0f;
					scaleAbbreviation = @"F";
				}
				value = [NSString stringWithFormat:@"%0.2fº %@", temp, scaleAbbreviation];
			}
			else
			{
				value = @"--º";
			}
			break;
		}

		case kSensorObjectTemperatureType:
		{
			if (self.sensorTag.hasObjectTemperature)
			{
				double temp = self.sensorTag.objectTemperature;
				NSString *scaleAbbreviation = @"C";
				if (![[NSUserDefaults standardUserDefaults] boolForKey:kUseCelsiusTemperature])
				{
					temp = temp * 1.8 + 32.0f;
					scaleAbbreviation = @"F";
				}
				label = NSLocalizedString(@"Object Temperature", nil);
				value = [NSString stringWithFormat:@"%0.2fº %@", temp, scaleAbbreviation];
			}
			else
			{
				value = @"--º";
			}
			break;
		}

		case kSensorHumidityType:
		{
			label = NSLocalizedString(@"Humidity", nil);
			if (self.sensorTag.hasRelativeHumidity)
			{
				value = [NSString stringWithFormat:@"%0.1f%% rH", self.sensorTag.relativeHumidity];
			}
			else
			{
				value = @"--% rH";
			}
			break;
		}

		case kSensorPressureType:
		{
			label = NSLocalizedString(@"Pressure", nil);
			if (self.sensorTag.hasPressure)
			{
				value = [NSString stringWithFormat:@"%d mbar", self.sensorTag.pressure];
			}
			else
			{
				value = @"-- mbar";
			}
			break;
		}
	}
	
	self.sensorTypeLabel.text = label;
	self.mainValueLabel.text = value;
}

- (IBAction)setupAlarmAction:(id)sender
{
	if (self.alarmBlock)
	{
		self.alarmBlock(self);
	}
}
@end
