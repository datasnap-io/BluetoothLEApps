//
//  SetupAlarmViewController.m
//  SensorApp
//
//  Created by Scott Gruby on 12/24/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "SetupAlarmViewController.h"
#import "TableSection.h"
#import "TableRow.h"
#import "AlarmObject.h"

@interface SetupAlarmViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) UISwitch *onOffSwitch;
@property (nonatomic, strong) UIStepper *minStepper;
@property (nonatomic, strong) UIStepper	*maxStepper;
@end

@implementation SetupAlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.onOffSwitch = [[UISwitch alloc] init];
	[self.onOffSwitch addTarget:self action:@selector(toggleOnOff:) forControlEvents:UIControlEventValueChanged];
	
	self.maxStepper = [[UIStepper alloc] init];
	self.minStepper = [[UIStepper alloc] init];
	self.onOffSwitch.on = self.alarm.alarmOn;
	self.minStepper.value = self.alarm.minValue;
	self.maxStepper.value = self.alarm.maxValue;
	
	[self.minStepper addTarget:self action:@selector(minStepperChanged:) forControlEvents:UIControlEventValueChanged];
	[self.maxStepper addTarget:self action:@selector(maxStepperChanged:) forControlEvents:UIControlEventValueChanged];
	
	switch (self.sensorType)
	{
		case kSensorAmbientTemperatureType:
		{
			self.title = NSLocalizedString(@"Ambient Temperature", nil);
			self.minStepper.minimumValue = -50;
			self.minStepper.maximumValue = 150;
			self.maxStepper.minimumValue = -50;
			self.maxStepper.maximumValue = 150;
			break;
		}

		case kSensorObjectTemperatureType:
		{
			self.title = NSLocalizedString(@"Object Temperature", nil);
			self.minStepper.minimumValue = -50;
			self.minStepper.maximumValue = 600;
			self.maxStepper.minimumValue = -50;
			self.maxStepper.maximumValue = 600;
			break;
		}

		case kSensorHumidityType:
		{
			self.title = NSLocalizedString(@"Humidity", nil);
			self.minStepper.minimumValue = 0;
			self.minStepper.maximumValue = 100;
			self.maxStepper.minimumValue = 0;
			self.maxStepper.maximumValue = 100;
			break;
		}

		case kSensorPressureType:
		{
			self.title = NSLocalizedString(@"Pressure", nil);
			self.minStepper.minimumValue = 900;
			self.minStepper.maximumValue = 1200;
			self.maxStepper.minimumValue = 900;
			self.maxStepper.maximumValue = 1200;
			break;
		}
	}
	
	[self setupTable];
}

- (void) updateValues
{
	self.alarm.alarmOn = self.onOffSwitch.on;
	self.alarm.maxValue = self.maxStepper.value;
	self.alarm.minValue = self.minStepper.value;
}

- (void) setupTable
{
	[self updateValues];
	
	NSMutableArray *sections = [NSMutableArray array];
	TableSection *section = [[TableSection alloc] init];
	section.title = NSLocalizedString(@"Options", nil);
	
	TableRow *row = [[TableRow alloc] init];
	row.title = NSLocalizedString(@"Alarm", nil);
	row.accessoryView = self.onOffSwitch;
	
	if (self.onOffSwitch.on)
	{
		TableRow *row2 = [[TableRow alloc] init];
		row2.title = NSLocalizedString(@"Minimum", nil);
		row2.accessoryView = self.minStepper;
		
		TableRow *row3 = [[TableRow alloc] init];
		row3.title = NSLocalizedString(@"Maximum", nil);
		row3.accessoryView = self.maxStepper;

		switch (self.sensorType)
		{
			case kSensorAmbientTemperatureType:
			case kSensorObjectTemperatureType:
			{
				NSString *scaleAbbreviation = @"C";
				if (![[NSUserDefaults standardUserDefaults] boolForKey:kUseCelsiusTemperature])
				{
					scaleAbbreviation = @"F";
				}

				row2.detailText = [NSString stringWithFormat:@"%luº %@", (unsigned long)self.minStepper.value, scaleAbbreviation];
				row3.detailText = [NSString stringWithFormat:@"%luº %@", (unsigned long)self.maxStepper.value, scaleAbbreviation];
				break;
			}
				
			case kSensorHumidityType:
			{
				row2.detailText = [NSString stringWithFormat:@"%lu%% rH", (unsigned long) self.minStepper.value];
				row3.detailText = [NSString stringWithFormat:@"%lu%% rH", (unsigned long) self.maxStepper.value];
				break;
			}

			case kSensorPressureType:
			{
				row2.detailText = [NSString stringWithFormat:@"%lu mbar", (unsigned long) self.minStepper.value];
				row3.detailText = [NSString stringWithFormat:@"%lu mbar", (unsigned long) self.maxStepper.value];
				break;
			}
		}
		
		section.rows = @[row, row2, row3];
	}
	else
	{
		section.rows = @[row];
	}
	[sections addObject:section];
	
	
	self.sections = sections;
	
	[self.tableView reloadData];
}

- (void) toggleOnOff:(id) sender
{
	[self setupTable];
}

- (void) minStepperChanged:(id) sender
{
	[self setupTable];
}

- (void) maxStepperChanged:(id) sender
{
	[self setupTable];
}

#pragma mark - Table View Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	TableSection *tableSection = [self.sections objectAtIndex:section];
	return tableSection.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	TableSection *tableSection = [self.sections objectAtIndex:section];
    return [tableSection.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TableSection *tableSection = [self.sections objectAtIndex:indexPath.section];
	TableRow *tableRow = [tableSection.rows objectAtIndex:indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alarmCell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"alarmCell"];
	}
	
	cell.textLabel.text = tableRow.title;
	cell.detailTextLabel.text = tableRow.detailText;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryView = tableRow.accessoryView;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
