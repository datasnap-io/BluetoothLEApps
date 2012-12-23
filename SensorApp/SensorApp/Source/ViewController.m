//
//  ViewController.m
//  SensorApp
//
//  Created by Scott Gruby on 12/12/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "ViewController.h"
#import "SensorTag.h"
#import "SensorTableViewCell.h"
#import "BluetoothLEManager.h"
#import "BluetoothLEService.h"
#import "BluetoothLEService+SensorTag.h"
#import "SettingsViewController.h"


@interface ViewController () <BluetoothLEManagerDelegateProtocol, BluetoothLEServiceProtocol, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) CBPeripheral *peripheral; // We only connect with 1 device at a time
@property (nonatomic, strong) SensorTag *sensorTag;
@property (nonatomic, strong) BluetoothLEService *service;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[BluetoothLEManager sharedManagerWithDelegate:self];
	[self.tableView registerNib:[UINib nibWithNibName:@"SensorTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SensorTableViewCell"];
	self.tableView.rowHeight = 96;
	[self.tableView reloadData];
	
	self.title = NSLocalizedString(@"SensorApp", nil);
	
	UIImage *image = [UIImage imageNamed:@"gear.png"];
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
	[button setBackgroundImage:image forState:UIControlStateNormal];
	[button addTarget:self action:@selector(settingsAction:) forControlEvents:UIControlEventTouchDown];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	[self setupConnectButton];
}

- (void) settingsAction:(id) sender
{
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]];
	
	[self.navigationController presentViewController:navController animated:YES completion:^{
		[self.tableView reloadData];
	}];
}

- (void) didDiscoverPeripheral:(CBPeripheral *) peripheral advertisementData:(NSDictionary *) advertisementData
{
	// Determine if this is the peripheral we want. If it is,
	// we MUST stop scanning before connecting

	NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
	if (localName && [localName caseInsensitiveCompare:@"SensorTag"] == NSOrderedSame)
	{
		[[BluetoothLEManager sharedManager] stopScanning];
		if (self.peripheral == nil)
		{
			self.peripheral = peripheral;
			[self setupConnectButton];
			[self.tableView reloadData];
		}
	}
}

- (void) didConnectPeripheral:(CBPeripheral *) peripheral error:(NSError *)error
{
	DebugLog(@"didConnectPeripheral: %@ - %@", peripheral, error);
	self.peripheral = peripheral;
	[self setupConnectButton];
	
	self.service = [[BluetoothLEService alloc] initWithPeripheral:self.peripheral withServiceUUIDs:[SensorTag serviceUUIDsToMonitor]  delegate:self];
	[self.service discoverServices];
	[self.tableView reloadData];
}

- (void) didDisconnectPeripheral:(CBPeripheral *) peripheral error:(NSError *)error
{
	DebugLog(@"didDisconnect: %@ %@", peripheral, error);
	self.service = nil;
	self.peripheral = nil;
	[self.tableView reloadData];
	[self setupConnectButton];
	[[BluetoothLEManager sharedManager] discoverDevices];
}

- (void) didChangeState:(CBCentralManagerState) newState
{
	DebugLog(@"state changed: %d", newState);

	if (newState == CBCentralManagerStatePoweredOn)
	{
		if (self.peripheral == nil)
		{
			[[BluetoothLEManager sharedManager] discoverDevices];
		}
	}
	else
	{
		self.peripheral = nil;
		[self.tableView reloadData];
	}
	
	[self setupConnectButton];
}

- (void) didUpdateValue:(BluetoothLEService *) service forServiceUUID:(CBUUID *) serviceUUID withCharacteristicUUID:(CBUUID *) characteristicUUID withData:(NSData *) data
{
	if (self.sensorTag == nil)
	{
		self.sensorTag = [[SensorTag alloc] init];
	}
	
	[self.sensorTag processCharacteristicDataWithServiceID:serviceUUID withCharacteristicID:characteristicUUID withData:data];
	//DebugLog(@"left down: %d right down: %d temperature: %f object temp: %f humidity: %0.1f%%rH pressure: %d mbar", self.sensorTag.leftButtonDown, self.sensorTag.rightButtonDown, (self.sensorTag.ambientTemperature * 1.8) + 32.0f, (self.sensorTag.objectTemperature * 1.8) + 32.0f, self.sensorTag.relativeHumidity, self.sensorTag.pressure);

	if ([self.sensorTag hasBarometricPressureCalibrationData] && self.sensorTag.pressure == 0)
	{
		// If we have calibration data, but don't have the pressure yet, we have to turn on the presure sensor.
		[service startMonitoringBarometerSensor];
	}
	
	[self.tableView reloadData];
}

- (void) didDiscoverCharacterisics:(BluetoothLEService *) service
{
	[service startMonitoringKeyPresses];
	[service startMonitoringTemperatureSensor];
	[service startMonitoringHumiditySensor];
	[service readBarometerSensorCalibration];
	DebugLog(@"finished discovering: %@", service);
}



- (IBAction)connectAction:(id)sender
{
	if (self.peripheral)
	{
		if ([self.peripheral isConnected])
		{
			[[BluetoothLEManager sharedManager] disconnectPeripheral:self.peripheral];
		}
		else
		{
			[[BluetoothLEManager sharedManager] connectPeripheral:self.peripheral];
		}
	}
}

- (void) setupConnectButton
{
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:self.peripheral.isConnected ? NSLocalizedString(@"Disconnect", nil) : NSLocalizedString(@"Connect", nil) style:UIBarButtonItemStyleBordered  target:self action:@selector(connectAction:)];
	self.navigationItem.leftBarButtonItem = item;
	self.navigationItem.leftBarButtonItem.enabled = (self.peripheral != nil);
}

#pragma mark - Table View Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([self.peripheral isConnected])
	{
		return 4;
	}
	else
	{
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// This should never return nil
	SensorTableViewCell *cell = (SensorTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"SensorTableViewCell"];
	cell.sensorTag = self.sensorTag;
	cell.cellType = indexPath.row;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	[cell setupCell];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
