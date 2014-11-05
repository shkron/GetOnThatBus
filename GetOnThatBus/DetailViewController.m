//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Alex on 11/4/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *busStopName;
@property (strong, nonatomic) IBOutlet UILabel *busStopAddress;
@property (strong, nonatomic) IBOutlet UILabel *busStopRoutes;
@property (strong, nonatomic) IBOutlet UILabel *busStopTransfers;


@end

@implementation DetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.detailInfo.name;
    self.busStopAddress.text = self.detailInfo.address;
    self.busStopRoutes.text = [NSString stringWithFormat:@"Routes: %@",self.detailInfo.routes];
    self.busStopTransfers.text = [NSString stringWithFormat:@"Transfer: %@",self.detailInfo.intermodal];


}





@end
