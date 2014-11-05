//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Alex on 11/4/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import "RootViewController.h"
#import "BusStop.h"
#import <MapKit/MapKit.h>

#define kJSON @"https://s3.amazonaws.com/mobile-makers-lib/bus.json"

@interface RootViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *busStopArray;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self dataArrayWithURLString:kJSON];
}

#pragma mark - changing the pin icon

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    if ([annotation isEqual:self.mobileMakersAnnotation])
//    {
//        pin.image = [UIImage imageNamed:@"mobilemakers"];
//    }

    return pin;

}

#pragma mark - pin accessory button action

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D center = [view.annotation coordinate];
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = .05;
    coordinateSpan.longitudeDelta = .05;

    MKCoordinateRegion region = MKCoordinateRegionMake(center, coordinateSpan);
    [self.mapView setRegion:region animated:YES];
    
}

#pragma mark - custom methods

- (void) addAnnotationWithPlaceString:(NSString *)address
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
                [self.mapView addAnnotation:annotation];
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
                                                   MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                                   CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(busStop.latitude, busStop.longitude);
                                                   annotation.title = busStop.name;
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


@end
