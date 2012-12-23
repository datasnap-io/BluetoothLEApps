//
//  SettingsViewController.m
//  SensorApp
//
//  Created by Scott Gruby on 12/19/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "SettingsViewController.h"
#import "TableSection.h"
#import "TableRow.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISwitch *celsiusSwitch;
@property (nonatomic, strong) UISwitch *automaticallyReconnectSwitch;
@property (nonatomic, strong) NSArray *sections;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Settings", nil);
	
	self.celsiusSwitch = [[UISwitch alloc] init];
	self.celsiusSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kUseCelsiusTemperature];

	self.automaticallyReconnectSwitch = [[UISwitch alloc] init];
	self.automaticallyReconnectSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticalllyReconnect];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
	
	NSMutableArray *sections = [NSMutableArray array];
	TableSection *section = [[TableSection alloc] init];
	section.title = NSLocalizedString(@"Options", nil);
	
	TableRow *row = [[TableRow alloc] init];
	row.title = NSLocalizedString(@"Celsius", nil);
	row.accessoryView = self.celsiusSwitch;

	TableRow *row2 = [[TableRow alloc] init];
	row2.title = NSLocalizedString(@"Auto reconnect", nil);
	row2.accessoryView = self.automaticallyReconnectSwitch;

	section.rows = @[row, row2];
	[sections addObject:section];

	
	section = [[TableSection alloc] init];
	section.title = NSLocalizedString(@"About", nil);

	row = [[TableRow alloc] init];
	row.title = NSLocalizedString(@"Version", nil);;
	row.detailText = [NSString stringWithFormat:@"%@ (%@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *) kCFBundleVersionKey]];
	
	section.rows = @[row];
	[sections addObject:section];

	
	self.sections = sections;
	
	[self.tableView reloadData];
}

- (void) cancelAction:(id) sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:^{
		
	}];
}

- (void) doneAction:(id) sender
{
	[[NSUserDefaults standardUserDefaults] setBool:self.celsiusSwitch.on forKey:kUseCelsiusTemperature];
	[[NSUserDefaults standardUserDefaults] setBool:self.automaticallyReconnectSwitch.on forKey:kAutomaticalllyReconnect];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.navigationController dismissViewControllerAnimated:YES completion:^{
		
	}];
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

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"versionCell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"versionCell"];
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
