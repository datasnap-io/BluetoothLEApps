//
//  ViewController.m
//  HeartRateApp
//
//  Created by Scott Gruby on 1/7/13.
//  Copyright (c) 2013 Scott Gruby. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothLEManager.h"
#import "BluetoothLEService.h"

@interface ViewController () <BluetoothLEManagerDelegateProtocol, BluetoothLEServiceProtocol>
@property (nonatomic, assign) CBPeripheral *peripheral; // We only connect with 1 device at a time
@property (nonatomic, strong) BluetoothLEService *service;
@property (weak, nonatomic) IBOutlet UILabel *beatsPerMinute;
@property (weak, nonatomic) IBOutlet UILabel *legendLabel;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"HeartRate App", nil);
	[BluetoothLEManager sharedManagerWithDelegate:self];
	[self setupConnectButton];
}

- (void) didDiscoverPeripheral:(CBPeripheral *) peripheral advertisementData:(NSDictionary *) advertisementData
{
	// Determine if this is the peripheral we want. If it is,
	// we MUST stop scanning before connecting
	
	CBUUID *heartRateUUID = [CBUUID UUIDWithString:@"0x180D"];
	NSArray *advertisementUUIDs = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
	for (CBUUID *uuid in advertisementUUIDs)
	{
		if ([uuid isEqual:heartRateUUID])
		{
			NSLog(@"found heartrate monitor");
			[[BluetoothLEManager sharedManager] stopScanning];
			if (self.peripheral == nil)
			{
				self.peripheral = peripheral;
				[self setupConnectButton];
			}
			break;
		}
	}
}

- (void) didConnectPeripheral:(CBPeripheral *) peripheral error:(NSError *)error
{
	DebugLog(@"didConnectPeripheral: %@ - %@", peripheral, error);
	self.peripheral = peripheral;
	[self setupConnectButton];
	
	self.service = [[BluetoothLEService alloc] initWithPeripheral:self.peripheral withServiceUUIDs:@[@"0x180D"] delegate:self];
	[self.service discoverServices];
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
	[self setupConnectButton];
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
	}
	[self setupConnectButton];
}

- (void) didUpdateValue:(BluetoothLEService *) service forServiceUUID:(CBUUID *) serviceUUID withCharacteristicUUID:(CBUUID *) characteristicUUID withData:(NSData *) data
{
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0)
    {
        /* uint8 bpm */
        bpm = reportData[1];
    }
    else
    {
        /* uint16 bpm */
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }

	self.beatsPerMinute.text = [NSString stringWithFormat:@"%d", bpm];
	self.beatsPerMinute.hidden = NO;
	self.legendLabel.hidden = NO;
}

- (void) didDiscoverCharacterisics:(BluetoothLEService *) service
{
	[service startNotifyingForServiceUUID:@"0x180D" andCharacteristicUUID:@"0x2A37"];
	DebugLog(@"finished discovering: %@", service);
}

- (void) setupConnectButton
{
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:self.peripheral.isConnected ? NSLocalizedString(@"Disconnect", nil) : NSLocalizedString(@"Connect", nil) style:UIBarButtonItemStyleBordered  target:self action:@selector(connectAction:)];
	self.navigationItem.leftBarButtonItem = item;
	self.navigationItem.leftBarButtonItem.enabled = (self.peripheral != nil);
	
	self.beatsPerMinute.hidden = !self.peripheral.isConnected;
	self.legendLabel.hidden = !self.peripheral.isConnected;

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

@end
