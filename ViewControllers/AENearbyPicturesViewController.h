//
//  AENearbyPicturesViewController.h
//  PicturesNearMe
//
//  Created by Amanda Jones on 5/15/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

/**
 Displays the Instagram pictures within the radius specified by the user on the MapView, using the point chosen on the MapView as the center from which the radii originate
 */
@interface AENearbyPicturesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 Colection view to display Instagram pictures and information
 */
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
/**
 Label to be displayed when no pictures are found for chosen location
 */
@property (strong, nonatomic) IBOutlet UILabel *labelNoPictures;
/**
 Point user touched on previous screen
 */
@property (nonatomic) CLLocationCoordinate2D pointTouched;
/**
 Radius in km
 */
@property (nonatomic) float radiusInKm;
/**
 The array to hold the pictures. Each entry contrains picture & all information pertaining to it
 */
@property (strong, nonatomic) NSArray *picturesFoundArray;
/**
 The cache for the UIImages retrieved
 */
@property (strong, nonatomic) NSCache *imagesCache;


@end
