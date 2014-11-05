//
//  BusStop.h
//  GetOnThatBus
//
//  Created by Alex on 11/4/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusStop : NSObject
@property NSString *name;
@property NSString *routes;
@property NSString *address;
@property NSString *intermodal;

@property double longitude;
@property double latitude;


-(instancetype)initWithDictionary:(NSDictionary *)dictionary;


@end
