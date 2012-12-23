//
//  TableSection.h
//  SensorApp
//
//  Created by Scott Gruby on 12/23/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableSection : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *rows;
@end
