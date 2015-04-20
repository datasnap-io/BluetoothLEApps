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
#import "SetupAlarmViewController.h"
#import "AlarmObject.h"
#import "SensorTagAlarmAlert.h"


@interface ViewController () <BluetoothLEManagerDelegateProtocol, BluetoothLEServiceProtocol, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) CBPeripheral *peripheral; // We only connect with 1 device at a time
@property (nonatomic, strong) SensorTag *sensorTag;
@property (nonatomic, strong) BluetoothLEService *service;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *alarms;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[BluetoothLEManager sharedManagerWithDelegate:self];
	[self.tableView registerNib:[UINib nibWithNibName:@"SensorTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SensorTableViewCell"];
	self.tableView.rowHeight = 96;
	[self.tableView reloadData];
	[self loadAlarms];
	
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
    
	
        NSLog(@"I see an advertisement with identifer: %@, state: %@, name: %@, services: %@, RSSI: %@, description: %@",
              [peripheral identifier],
              [peripheral state],
              [peripheral name],
              [peripheral services],
              [peripheral RSSI],
              [advertisementData description]);
	
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

	if (self.peripheral != nil && [[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticalllyReconnect])
	{
		[[BluetoothLEManager sharedManager] connectPeripheral:self.peripheral];
	}
	else
	{
		[[BluetoothLEManager sharedManager] discoverDevices];
	}
	self.peripheral = nil;
	[self.tableView reloadData];
	[self setupConnectButton];
}

- (void) didChangeState:(CBCentralManagerState) newState
{
	DebugLog(@"state changed: %ld", (unsigned long) newState);

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
	
	// Handle the alarms
	if (self.sensorTag.hasAmbientTemperature)
	{
		AlarmObject *object = [self alarmForSensorType:kSensorAmbientTemperatureType];
		double temp = self.sensorTag.ambientTemperature;
		if (![[NSUserDefaults standardUserDefaults] boolForKey:kUseCelsiusTemperature])
		{
			temp = temp * 1.8 + 32.0f;
		}

		[object updateAlarmValue:temp];
	}

	if (self.sensorTag.hasObjectTemperature)
	{
		AlarmObject *object = [self alarmForSensorType:kSensorObjectTemperatureType];
		double temp = self.sensorTag.objectTemperature;
		if (![[NSUserDefaults standardUserDefaults] boolForKey:kUseCelsiusTemperature])
		{
			temp = temp * 1.8 + 32.0f;
		}
		
		[object updateAlarmValue:temp];
	}
	
	if (self.sensorTag.hasRelativeHumidity)
	{
		AlarmObject *object = [self alarmForSensorType:kSensorHumidityType];
		[object updateAlarmValue:self.sensorTag.relativeHumidity];
	}

	if (self.sensorTag.hasPressure)
	{
		AlarmObject *object = [self alarmForSensorType:kSensorPressureType];
		[object updateAlarmValue:self.sensorTag.pressure];
	}

	[self checkAlarms];
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
			self.peripheral = nil;
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
	cell.cellType = (SensorType) indexPath.row;
	cell.hasAlarm = [self alarmForSensorType:cell.cellType].alarmOn;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	[cell setupCell];
	
	__weak ViewController *weakSelf = self;
	cell.alarmBlock = ^(SensorTableViewCell * cell)
	{
		[weakSelf didTapSetAlarmCell:cell];
	};
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
	[self saveAlarms];
}

#pragma mark - Alarms

- (void) didTapSetAlarmCell:(SensorTableViewCell *) cell
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	
	SetupAlarmViewController *vc = [[SetupAlarmViewController alloc] init];
	vc.sensorType = (SensorType) indexPath.row;
	vc.alarm = [self alarmForSensorType:vc.sensorType];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void) loadAlarms
{
	NSData *alarmData = [[NSUserDefaults standardUserDefaults] objectForKey:kAlarms];
	if (alarmData != nil)
	{
		self.alarms = [NSKeyedUnarchiver unarchiveObjectWithData:alarmData];
	}
}

- (void) saveAlarms
{
	if (self.alarms)
	{
		// Reset all the alarms
		for (AlarmObject *object in self.alarms)
		{
			[object clearValueCount];
		}
		
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.alarms];
		if (data)
		{
			[[NSUserDefaults standardUserDefaults] setObject:data forKey:kAlarms];
		}
		else
		{
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:kAlarms];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (AlarmObject *) alarmForSensorType:(SensorType) type
{
	for (AlarmObject *object in self.alarms)
	{
		if (object.sensorType == type)
		{
			return object;
		}
	}
	
	AlarmObject *object = [[AlarmObject alloc] init];
	object.sensorType = type;
	if (self.alarms == nil)
	{
		self.alarms = [NSArray arrayWithObject:object];
	}
	else
	{
		NSMutableArray *newArray = [self.alarms mutableCopy];
		[newArray addObject:object];
		self.alarms = newArray;
	}
	
	return object;
}

- (void) checkAlarms
{
	for (AlarmObject *object in self.alarms)
	{
		if ([object highValueAlarm])
		{
			SensorTagAlarmAlert *alert = [[SensorTagAlarmAlert alloc] init];
			alert.sensorType = (SensorType) object.sensorType;
			alert.alarmValue = object.maxValue;
			[alert presentAlarmAlert];
		}
		else if ([object lowValueAlarm])
		{
			SensorTagAlarmAlert *alert = [[SensorTagAlarmAlert alloc] init];
			alert.sensorType = (SensorType) object.sensorType;
			alert.below = YES;
			alert.alarmValue = object.minValue;
			[alert presentAlarmAlert];
		}
	}
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	if (self.peripheral == nil)
	{
		[[BluetoothLEManager sharedManager] stopScanning];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	if (self.peripheral == nil)
	{
		[[BluetoothLEManager sharedManager] discoverDevices];
	}
}
@end
