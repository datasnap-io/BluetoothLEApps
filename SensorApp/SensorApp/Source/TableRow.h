//
//  TableRow.h
//  SensorApp
//
//  Created by Scott Gruby on 12/23/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableRow : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) UIView *accessoryView;
@end
