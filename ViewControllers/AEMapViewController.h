//
//  AEMapViewController.h
//  PicturesNearMe
//
//  Created by Amanda Jones on 5/14/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

/**
 Displays map, zoned in on user's location, and a slider for the radius within which to find pictures. When the user touches any point on the map, they are taken to the next screen (AENearbyPicturesView). User can change radius by using the slider.
 */
@interface AEMapViewController : UIViewController <MKMapViewDelegate>

/**
 The map view
 */
@property (strong, nonatomic) IBOutlet MKMapView *myMapView;
/**
 The UISlider for the radius within which the user would like to view pictures
 */
@property (strong, nonatomic) IBOutlet UISlider *sliderRadius;
/**
 The label to display the radius chosen
 */
@property (strong, nonatomic) IBOutlet UILabel *labelRadius;
/**
 Gesture recognizer for single taps on map view
 */
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mapGestureRecognizer;
/**
 Point user touched
 */
@property (nonatomic) CLLocationCoordinate2D pointTouched;
/**
 Called when the value of the UISlider changes; updates radius label
 */
- (IBAction)sliderChanged:(id)sender;
/**
 Called when the user taps anywhere in the map view; saves point
 */
- (IBAction)tapRecognizer:(id)sender;
@end
