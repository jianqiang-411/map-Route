//
//  ViewController.m
//  MapRouteDemo
//
//  Created by 5dscape on 12-11-26.
//  Copyright (c) 2012年 kai. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"
@interface ViewController () <MKAnnotation>

@end

@implementation ViewController
@synthesize from_Place,to_Place;
@synthesize fromText,toText;

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapView = [[MapView alloc] initWithFrame:
               CGRectMake(0, 44, self.view.frame.size.width,self.view.frame.size.height-44)] ;
	[self.view addSubview:mapView];
	
    
    
    locmanager = [[CLLocationManager alloc] init];
    locmanager.delegate = self;
    locmanager.desiredAccuracy = kCLLocationAccuracyBest;
    locmanager.distanceFilter = kCLDistanceFilterNone;
    [locmanager startUpdatingLocation];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAct:)];
    longPress.minimumPressDuration = 1;
    [mapView addGestureRecognizer:longPress];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)search_Fetch_LaAndLo:(id)sender
{
    UITextField *text = (UITextField *)sender;
    NSString *urlStr = [[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",text.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    
    [request setCompletionBlock:^{
        NSError *error = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:&error];
        
        NSArray *arrResult = [dic objectForKey:@"results"];
        
        NSDictionary *dicGEO = [[arrResult objectAtIndex:0] objectForKey:@"geometry"];
        
        NSDictionary *dicLocation = [dicGEO objectForKey:@"location"];
        float la = [[dicLocation objectForKey:@"lat"] floatValue];
        float lo = [[dicLocation objectForKey:@"lng"] floatValue];
        
       
        if (text == fromText) {
            from_Place = [[Place alloc] init] ;
            from_Place.name = fromText.text;
            from_Place.latitude = la;
            from_Place.longitude = lo;
            
            PlaceMark *pmark = [[PlaceMark alloc] initWithPlace:from_Place];
            
            if ([mapView.mapView.annotations count] > 0) {
                [mapView.mapView removeAnnotations:mapView.mapView.annotations];
            }
            [mapView.mapView addAnnotation:pmark];
        }
        
        if (text == toText) {
            to_Place = [[Place alloc] init] ;
            to_Place.name = toText.text;
            to_Place.latitude = la;
            to_Place.longitude = lo;
            
            
            PlaceMark *pmark = [[PlaceMark alloc] initWithPlace:to_Place];
            
            if ([mapView.mapView.annotations count] > 0) {
                [mapView.mapView removeAnnotations:mapView.mapView.annotations];
            }
            [mapView.mapView addAnnotation:pmark];
        }
        
       
        
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(la,lo);
        float zoomLevel = 0.02;
        MKCoordinateRegion region = MKCoordinateRegionMake(coords, MKCoordinateSpanMake(zoomLevel, zoomLevel));
        
        [mapView.mapView setRegion:[mapView.mapView regionThatFits:region] animated:YES];

        
    }];
    [request setFailedBlock:^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法查找位置，请检查输入或网络连接" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        /*
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:fromText.text completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error != nil) {
                    NSLog(@"error===== %@",error);
                    return ;
                }
                if ([placemarks count] > 0) {
                    CLPlacemark *placemark = [placemarks objectAtIndex:0];
                    CLLocationCoordinate2D coordinate = placemark.location.coordinate;
                    
                    if (text == fromText) {
                        from_Place = [[Place alloc] init] ;
                        from_Place.name = fromText.text;
                        from_Place.latitude = coordinate.latitude;
                        from_Place.longitude = coordinate.longitude;
                        
                        NSLog(@"-----------%f,%f===========",coordinate.latitude,coordinate.longitude);
                        
                        PlaceMark *pmark = [[PlaceMark alloc] initWithPlace:from_Place];
                        
                        if ([mapView.mapView.annotations count] > 0) {
                            [mapView.mapView removeAnnotations:mapView.mapView.annotations];
                        }
                        [mapView.mapView addAnnotation:pmark];
                    }
                    
                    if (text == toText) {
                        to_Place = [[Place alloc] init] ;
                        to_Place.name = toText.text;
                        to_Place.latitude = coordinate.latitude;
                        to_Place.longitude = coordinate.longitude;
                        
                        
                        PlaceMark *pmark = [[PlaceMark alloc] initWithPlace:to_Place];
                        
                        if ([mapView.mapView.annotations count] > 0) {
                            [mapView.mapView removeAnnotations:mapView.mapView.annotations];
                        }
                        [mapView.mapView addAnnotation:pmark];
                        
                        
                        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(coordinate.latitude,coordinate.longitude);
                        float zoomLevel = 0.02;
                        MKCoordinateRegion region = MKCoordinateRegionMake(coords, MKCoordinateSpanMake(zoomLevel, zoomLevel));
                        
                        [mapView.mapView setRegion:[mapView.mapView regionThatFits:region] animated:YES];

                    }
                }
            }];
        
      */  
    }];
    
    [request startSynchronous];
    
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == fromText) {
        if (toText != nil && ![toText.text isEqualToString:@""]) {
            [self search_Fetch_LaAndLo:toText];
        }
    }
    
    if (textField == toText) {
        if (fromText != nil && ![fromText.text isEqualToString:@""]) {
            [self search_Fetch_LaAndLo:fromText];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == fromText) {
        [self search_Fetch_LaAndLo:fromText];
    }
    if (textField == toText) {
        [self search_Fetch_LaAndLo:toText];
    }
    [textField resignFirstResponder];
    return YES;
}



- (IBAction)search:(id)sender
{
    [fromText resignFirstResponder];
    [toText resignFirstResponder];
    
    if (from_Place == nil && [fromText.text length] > 0) {
        [self search_Fetch_LaAndLo:fromText];
    }
    
    if (to_Place == nil && [toText.text length] > 0) {
        [self search_Fetch_LaAndLo:toText];
    }
    
    if (from_Place != nil && to_Place != nil) {
        [mapView showRouteFrom:from_Place to:to_Place];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入起点和终点" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    


}
 


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLLocationCoordinate2D loc = [newLocation coordinate];
    
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(loc.latitude,loc.longitude);
    float zoomLevel = 0.02;
    MKCoordinateRegion region = MKCoordinateRegionMake(coords, MKCoordinateSpanMake(zoomLevel, zoomLevel));

    [mapView.mapView setRegion:[mapView.mapView regionThatFits:region] animated:YES];

}


@end
