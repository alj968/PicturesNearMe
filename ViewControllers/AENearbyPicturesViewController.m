//
//  AENearbyPicturesViewController.m
//  PicturesNearMe
//
//  Created by Amanda Jones on 5/15/14.
//  Copyright (c) 2014 Amanda Jones. All rights reserved.
//

#import "AENearbyPicturesViewController.h"
#import "AEProjectConstants.h"
#import "AFNetworking.h"
#import "AEPictureCell.h"

//The number of pictures we're requesting
static int const count = 100;

@implementation AENearbyPicturesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Hide "No Pictures Found" label
    [_labelNoPictures setHidden:YES];
    
    //Make cache for images & put placeholder image in it
    _imagesCache = [[NSCache alloc] init];
    UIImage *placeholderImage = [UIImage imageNamed:@"amanda_icon.png"];
    [_imagesCache setObject:placeholderImage forKey:@"placeholder"];
    
    [self requestNearbyPictures];
    
}

#pragma mark  - Get pictures

/**
 Make API call to media/search endpoint, using information from previous screen
 Set the content of the picturesFoundArray here
 */
-(void)requestNearbyPictures
{
    //Form request
    float distanceInMeters = _radiusInKm * 1000;
    NSString *requestString = [self formNearbyPicturesRequestStringWithDistance:distanceInMeters latitude:_pointTouched.latitude longitude:_pointTouched.longitude pictureCount:count];
    NSURL *nearbyPicturesURL = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:nearbyPicturesURL];
    
    //Make request
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //On success, set content on picturesFoundArray
        self.picturesFoundArray = [responseObject objectForKey:@"data"];
        if([_picturesFoundArray count] > 0)
        {
            [_labelNoPictures setHidden:YES];
            [self.collectionView reloadData];
        }
        //If no pictures found, let user know this in label
        else
        {
            //Show "No Pictures Found" label
            [_labelNoPictures setHidden:NO];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //On failure, display alert view
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Images"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
}

/**
 Forms a string to be used in the request to get nearby pictures.
 */
- (NSString *)formNearbyPicturesRequestStringWithDistance:(float)distance latitude:(float)lat longitude:(float)lng pictureCount:(int)count
{
    return [NSString stringWithFormat:@"%@media/search?distance=%f&lat=%f&lng=%f&client_id=%@&count=%d",kAE_API_URL,distance,lat,lng,kAE_CLIENT_ID,count];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.picturesFoundArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Use custom cell I created
    AEPictureCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"PictureCell" forIndexPath:indexPath];
    
    //Get the dictionary entry with all picture info for the given index path
    NSDictionary *pictureDictionaryEntry = [_picturesFoundArray objectAtIndex:indexPath.row];
    
    //Get label info for PictureCell
    NSString *labelInfo = [self labelTextFromDictionary:pictureDictionaryEntry];

    //Get image for PictureCell
    NSDictionary *imagesDict = [pictureDictionaryEntry objectForKey:@"images"];
    NSDictionary *thumbnailDict = [imagesDict objectForKey:@"thumbnail"];
    NSString *thumbnailString = [thumbnailDict objectForKey:@"url"];
    //Get image from cache if possible, otherwise get from url
    UIImage *image = [_imagesCache objectForKey:thumbnailString];
    if(image)
    {
        cell.imageView.image = image;
        cell.labelInfo.text = labelInfo;
    }
    else
    {
        //While getting images, have placeholder image showing
        cell.imageView.image = [_imagesCache objectForKey:@"placeholder"];
        //Get image on background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSURL *thumbnailURL = [NSURL URLWithString:thumbnailString];
            NSData *imageData = [NSData dataWithContentsOfURL:thumbnailURL];
            UIImage *image = [UIImage imageWithData:imageData];
            [_imagesCache setObject:image forKey:thumbnailString];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Set image and label on main thread
                cell.imageView.image = image;
                cell.labelInfo.text = labelInfo;
            });
        });
    }
    return cell;
}

/**
 Creates a label for the PictureCell using the username and location of the Instagram picture
 */
- (NSString *)labelTextFromDictionary:(NSDictionary *)pictureDictionaryEntry
{
    //Get username
    NSString *username = [self usernameFromDictionary:pictureDictionaryEntry];
    
    //Get location of picture and use to find distance from original point touched
    CLLocation *pictureLocation = [self pictureLocationFromDictionary:pictureDictionaryEntry];
    CLLocation *originalLocation = [[CLLocation alloc] initWithLatitude:_pointTouched.latitude longitude:_pointTouched.longitude];
    CLLocationDistance distance = [originalLocation distanceFromLocation:pictureLocation]/1000;
    NSString *distanceString = [NSString stringWithFormat:@"%.2f km",distance];
    
    return [NSString stringWithFormat:@"%@\n%@",distanceString,username];
}

/**
 Returns the username as a string from the picture information dictionary
 */
- (NSString *)usernameFromDictionary:(NSDictionary *)pictureDictionaryEntry
{
    NSDictionary *userDict = [pictureDictionaryEntry objectForKey:@"user"];
    return [userDict objectForKey:@"username"];
}

/**
 Returns the location as a CLLocation from the picture information dictionary
 */
- (CLLocation *)pictureLocationFromDictionary:(NSDictionary *)pictureDictionaryEntry
{
    NSDictionary *locationDict = [pictureDictionaryEntry objectForKey:@"location"];
    NSString *latitude = [locationDict objectForKey:@"latitude"];
    double latitudeDouble = [latitude doubleValue];
    NSString *longitude = [locationDict objectForKey:@"longitude"];
    double longitudeDouble = [longitude doubleValue];
    return [[CLLocation alloc] initWithLatitude:latitudeDouble longitude:longitudeDouble];
}

@end
