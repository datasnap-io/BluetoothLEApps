//
//  SettingsViewController.m
//  SensorApp
//
//  Created by Scott Gruby on 12/19/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISwitch *celsiusSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Settings", nil);
	
	self.celsiusSwitch = [[UISwitch alloc] init];
	self.celsiusSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kUseCelsiusTemperature];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
}

- (void) cancelAction:(id) sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:^{
		
	}];
}

- (void) doneAction:(id) sender
{
	[[NSUserDefaults standardUserDefaults] setBool:self.celsiusSwitch.on forKey:kUseCelsiusTemperature];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.navigationController dismissViewControllerAnimated:YES completion:^{
		
	}];
}

#pragma mark - Table View Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:
		{
			return NSLocalizedString(@"Temperature", nil);
		}
			
		case 1:
		{
			return NSLocalizedString(@"About", nil);
		}
			
		default:
		{
			break;
		}
	}
	
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
		case 0:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"versionCell"];
			if (cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"versionCell"];
			}
			
			cell.textLabel.text = NSLocalizedString(@"Celsius", nil);
			cell.accessoryView = self.celsiusSwitch;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			return cell;
		}

		case 1:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"versionCell"];
			if (cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"versionCell"];
			}
			
			cell.textLabel.text = NSLocalizedString(@"Version", nil);
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *) kCFBundleVersionKey]];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			return cell;
		}
			
		default:
		{
			break;
		}
	}
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
