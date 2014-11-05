//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Alex on 11/4/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import "RootViewController.h"
#import "BusStop.h"
#import "DetailViewController.h"
#import <MapKit/MapKit.h>

#define kJSON @"https://s3.amazonaws.com/mobile-makers-lib/bus.json"

@interface RootViewController () <MKMapViewDelegate, UITabBarControllerDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *busStopArray;
@property (strong, nonatomic) NSMutableArray *busStopClassArray;
@property (strong, nonatomic) NSMutableDictionary *detailByTitleDict;
@property (strong, nonatomic) NSMutableDictionary *pinColorByTransferDict;
@property (nonatomic, assign) BOOL *isTransferMetra;
@property (nonatomic, assign) BOOL *isTransferPace;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.detailByTitleDict = [NSMutableDictionary dictionary];
    self.pinColorByTransferDict = [NSMutableDictionary dictionary];
    self.busStopClassArray = [NSMutableArray array];
    [self dataArrayWithURLString:kJSON];
    [self zoomInWithPlaceString:@"Chicago, IL"];



}
#pragma mark - delegation methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.busStopArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    cell.textLabel.text =  self.busStopArray[indexPath.row][@"cta_stop_name"];
    cell.detailTextLabel.text = self.busStopArray[indexPath.row][@"routes"];
//    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"bustStopDetailInfo" sender:(BusStop *)self.busStopClassArray[indexPath.row]];
}



#pragma mark - annotation pin methods

//WHAT: pin callout accessory and color change
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

//    pin.pinColor = MKPinAnnotationColorGreen;
//    pin.pinColor = MKPinAnnotationColorPurple;

if ([[self.pinColorByTransferDict objectForKey:[annotation title]] isEqualToString:@"Metra"])
{
pin.pinColor = MKPinAnnotationColorGreen;
}
else if ([[self.pinColorByTransferDict objectForKey:[annotation title]] isEqualToString:@"Pace"])
{
pin.pinColor = MKPinAnnotationColorPurple;
}

//    if ([annotation isEqual:self.mobileMakersAnnotation])
//    {
//        pin.image = [UIImage imageNamed:@"mobilemakers"];
//    }

    return pin;

}

//WHAT: pin accessory button action

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D center = [view.annotation coordinate];
    NSString *busStopTitle = [view.annotation title];
    NSDictionary *busStopDict = [self.detailByTitleDict objectForKey:busStopTitle];
    BusStop *busStopInfo = [[BusStop alloc] initWithDictionary:busStopDict];
    [self performSegueWithIdentifier:@"bustStopDetailInfo" sender:(BusStop *)busStopInfo];

    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = .05;
    coordinateSpan.longitudeDelta = .05;

    MKCoordinateRegion region = MKCoordinateRegionMake(center, coordinateSpan);
    [self.mapView setRegion:region animated:YES];
    
}

#pragma mark - custom methods

- (void) zoomInWithPlaceString:(NSString *)address
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error)
        {
            [self networkAlertWindow:error.localizedDescription];
        }
        else
        {
            for (CLPlacemark *placemark in placemarks)
            {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = placemark.location.coordinate;
                annotation.title = placemark.name; //placemark.subLocality
                CLLocationCoordinate2D center = annotation.coordinate;
                MKCoordinateSpan coordinateSpan;
                coordinateSpan.latitudeDelta = 0.5;
                coordinateSpan.longitudeDelta = 0.5;

                MKCoordinateRegion region = MKCoordinateRegionMake(center, coordinateSpan);
                [self.mapView setRegion:region animated:YES];
//                [self.mapView addAnnotation:annotation];
            }
        }
    }];

    
}

-(void)dataArrayWithURLString:(NSString *)urlString
{

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                           if (connectionError)
                                           {
                                               [self networkAlertWindow:connectionError.localizedDescription];
                                           }
                                           else
                                           {
                                               NSDictionary *rawDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                               self.busStopArray = [rawDict objectForKey:@"row"];
                                               for (NSDictionary *busStopDict in self.busStopArray)
                                               {
                                                   BusStop *busStop = [[BusStop alloc] initWithDictionary:busStopDict];
                                                   [self.busStopClassArray addObject:busStop];

                                                   MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                                   CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(busStop.latitude, busStop.longitude);
                                                   annotation.title = busStop.name;
                                                   [self.detailByTitleDict setObject:busStopDict forKey:busStop.name];
                                                   [self.pinColorByTransferDict setObject:busStop.intermodal forKey:busStop.name];
                                                   annotation.subtitle = [NSString stringWithFormat:@"Routes: %@",busStop.routes];
                                                   annotation.coordinate = coord;
                                                   [self.mapView addAnnotation:annotation];
                                               }

                                           }
                                       }];
    
}


-(void)networkAlertWindow:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"MKay..." style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


-(IBAction)segmentedCotrolValueChanged:(UISegmentedControl *)sControl
{
    if (sControl.selectedSegmentIndex==1)
    {
        [UIView transitionFromView:self.mapView toView:self.tableView duration:.5 options:(UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromRight) completion:^(BOOL finished)
        {
//            [self.tableView layoutIfNeeded];
            [self.tableView reloadData];
        }];
    }
    else
    {
        [UIView transitionFromView:self.tableView toView:self.mapView duration:.5 options:(UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromRight)completion:^(BOOL finished)
        {

//            [self dataArrayWithURLString:kJSON];
//            [self zoomInWithPlaceString:@"Chicago, IL"];
//            [self.mapView layoutIfNeeded];
        }];

    }


}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(BusStop *)busStopInfo
{
    DetailViewController *vc = segue.destinationViewController;
    vc.detailInfo = busStopInfo;
}


@end
