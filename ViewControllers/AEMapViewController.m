//
//  AEMapViewController.m
//  PicturesNearMe
//
//  Created by Amanda Jones on 5/14/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "AEMapViewController.h"
#import "AENearbyPicturesViewController.h"

@implementation AEMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //My default, radius is 1 km
    _labelRadius.text = @"Radius: 1 km";
    _sliderRadius.value = 1;

    //Set map view delegate
    _myMapView.delegate = self;
    
    [self setUpLocationServices];
}


#pragma mark - Set up
- (void)setUpLocationServices
{
    if([CLLocationManager locationServicesEnabled])
    {
        [self setUpUserLocation];
    }
    else
    {
        //If location services are turned off, show alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot locate user" message:@"Check if Location Services are enabled" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

//Show alert if user did not allow PicturesNearMe to use location services
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSString *errorMessage = [error.userInfo objectForKey:@"NSLocalizedRecoverySuggestion"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

/**
 Configures the map view with its default settings
 */
- (void)setUpUserLocation
{
    _myMapView.showsUserLocation = YES;
    //Zoom in on user's location
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_myMapView.centerCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [_myMapView regionThatFits:viewRegion];
    [_myMapView setRegion:adjustedRegion animated:YES];
}

#pragma mark - MKMapView Delegate

/**
 Update the map's pin when the user's location is updated
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    _myMapView.centerCoordinate = userLocation.location.coordinate;
}

#pragma mark - User Interactions

- (IBAction)sliderChanged:(id)sender
{
    float newValue = _sliderRadius.value;
    //Display new radius, to two decimal places
    _labelRadius.text = [NSString stringWithFormat:@"Radius: %.2f km",newValue];
}

- (IBAction)tapRecognizer:(id)sender {
    
    //Get point user touched and determine what this corresponds to in map view
    CGPoint point = [_mapGestureRecognizer locationInView:_myMapView];
    _pointTouched =  [_myMapView convertPoint:point toCoordinateFromView:_myMapView];
    
    [self updateAnnotations];
    
    //Half second delay so user can see pin
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //Go to NearbyPicturesView
        [self performSegueWithIdentifier:@"pushToPictures" sender:self];;
    });
}

/**
 Removes existing pins & adds a new one for point last touched by user
 */
- (void)updateAnnotations
{
    //Remove last pin
    for(id a in [_myMapView annotations])
    {
        [_myMapView removeAnnotation:a];
    }
    
    //Add new pin for point touched
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    point1.coordinate = _pointTouched;
    [_myMapView addAnnotation:point1];
}

#pragma mark - Segue prep

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"pushToPictures"])
    {
        //Set radius and point chosen
        AENearbyPicturesViewController *vc = [segue destinationViewController];
        vc.pointTouched = _pointTouched;
        vc.radiusInKm = _sliderRadius.value;
    }
}

@end
