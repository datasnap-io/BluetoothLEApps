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
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
	self.connectButton.enabled = NO;
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
			[self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
			self.peripheral = peripheral;
			self.connectButton.enabled = YES;
			[self.tableView reloadData];
		}
	}
}

- (void) didConnectPeripheral:(CBPeripheral *) peripheral error:(NSError *)error
{
	DebugLog(@"didConnectPeripheral: %@ - %@", peripheral, error);
	self.peripheral = peripheral;
	[self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
	self.connectButton.enabled = YES;
	
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
	self.connectButton.enabled = NO;
	[self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
	[[BluetoothLEManager sharedManager] discoverDevices];
}

- (void) didChangeState:(CBCentralManagerState) newState
{
	DebugLog(@"state changed: %d", newState);
	self.connectButton.enabled = NO;
	[self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
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
}

- (void) didUpdateValue:(BluetoothLEService *) service forServiceUUID:(CBUUID *) serviceUUID withCharacteristicUUID:(CBUUID *) characteristicUUID withData:(NSData *) data
{
	if (self.sensorTag == nil)
	{
		self.sensorTag = [[SensorTag alloc] init];
	}
	
	[self.sensorTag processCharacteristicDataWithServiceID:serviceUUID withCharacteristicID:characteristicUUID withData:data];
	//DebugLog(@"left down: %d right down: %d temperature: %f object temp: %f humidity: %0.1f%%rH pressure: %d mbar", self.sensorTag.leftButtonDown, self.sensorTag.rightButtonDown, (self.sensorTag.ambientTemperature * 1.8) + 32.0f, (self.sensorTag.objectTemperature * 1.8) + 32.0f, self.sensorTag.relativeHumidity, self.sensorTag.pressure);
	//	self.temperatureLabel.text = [NSString stringWithFormat:@"%0.2fº", (self.sensorTag.ambientTemperature * 1.8) + 32.0f];

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
