//
//  ViewController.h
//  MapRouteDemo
//
//  Created by 5dscape on 12-11-26.
//  Copyright (c) 2012年 kai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapView.h"
#import "Place.h"
#import <CoreLocation/CoreLocation.h>
@interface ViewController : UIViewController<CLLocationManagerDelegate,UITextFieldDelegate>
{
    MapView* mapView;
    Place *from_Place;
    Place* to_Place;
    CLLocationManager *locmanager;
}
@property (strong, nonatomic) Place* to_Place;
@property (strong, nonatomic) Place *from_Place;
@property (strong, nonatomic) IBOutlet UITextField *fromText;
@property (strong, nonatomic) IBOutlet UITextField *toText;
- (IBAction)search:(id)sender;

@end
