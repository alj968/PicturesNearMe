//
//  AEPictureCell.h
//  PicturesNearMe
//
//  Created by Amanda Jones on 5/16/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A custom UICollectionViewCell to display the Instagram imae, the username of the person who posted the picture, and the distance between where the pictures was taken, and the location chosen on the MapView
 */
@interface AEPictureCell : UICollectionViewCell

/**
 Holds the Instagram picture
 */
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
/**
 Display the username and the distance, truncated to two decimal places, in km
 */
@property (strong, nonatomic) IBOutlet UILabel *labelInfo;

@end
