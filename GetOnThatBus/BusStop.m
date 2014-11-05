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
    self.name = dictionary[@"cta_stop_name"];
    self.routes = dictionary[@"routes"];
    self.address = dictionary[@"_address"];

    //checking the inter_modal object in dictionary
    if (dictionary[@"inter_modal"])
    {
        self.intermodal = dictionary[@"inter_modal"];
    } else
    {
        self.intermodal = @"none";
    }

    self.longitude = [dictionary[@"longitude"] doubleValue];
    self.latitude = [dictionary[@"latitude"] doubleValue];

    return self;
}


@end
