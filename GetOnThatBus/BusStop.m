//
//  BusStop.m
//  GetOnThatBus
//
//  Created by Alex on 11/4/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import "BusStop.h"

@implementation BusStop


-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    self.name = dictionary[@"name"];
    self.routes = dictionary[@"routes"];
    self.address = dictionary[@"_address"];
    self.intermodal = dictionary[@"inter_modal"];
    self.longitude = [dictionary[@"longitude"] doubleValue];
    self.latitude = [dictionary[@"latitude"] doubleValue];

    return self;
}


@end
