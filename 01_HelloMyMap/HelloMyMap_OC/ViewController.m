//
//  ViewController.m
//  HelloMyMap_OC
//
//  Created by Ariel Ko on 2021/6/19.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
{
    CGFloat longitude;
    CGFloat latiude;
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet MKMapView *mainMap;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeChangedOut;

@end

@implementation ViewController
@synthesize  mapTypeChangedOut;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set MapView Location
    _mainMap.showsUserLocation = YES;
    _mainMap.delegate = self;

    // Set locationManager
    [self location];
    
    // Set pin
    [self MKPointAnnation];
    
}

- (void)location {
    locationManager = [[CLLocationManager alloc]init];
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];

}

-(void)MKPointAnnation{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    
    latiude = locationManager.location.coordinate.latitude;
    longitude = locationManager.location.coordinate.longitude;
    CLLocationCoordinate2D coordForPin = {.latitude = latiude+0.0001, .longitude = longitude+0.0001};
    [annotation setCoordinate:coordForPin];
    [annotation setTitle:@"肯德基"];
    [annotation setSubtitle:@"真好吃"];
    [_mainMap addAnnotation:annotation];

}

// MARK: - selectedSegment
- (IBAction)mapTypeChanged:(id)sender {
    switch (self.mapTypeChangedOut.selectedSegmentIndex) {
        case 0 : {// 標準
            _mainMap.mapType = MKMapTypeStandard;
            [locationManager startUpdatingLocation];
            NSLog(@"標準");
            break;
        }
        case 1 : {// 衛星
            _mainMap.mapType = MKMapTypeSatellite;
            [locationManager startUpdatingLocation];
            NSLog(@"衛星");
            break;
        }
        case 2 : {// 混合
            _mainMap.mapType = MKMapTypeHybrid;
            [locationManager startUpdatingLocation];
            NSLog(@"混合");
            break;
        }
        case 3 : {// 鳥瞰
            NSLog(@"鳥瞰");
            _mainMap.mapType = MKMapTypeSatelliteFlyover;
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(35.710063, 139.8107);
            MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:coordinate fromDistance:800 pitch:60 heading:0];
            _mainMap.camera = camera;
            break;
        }
        default : {
            _mainMap.mapType = MKMapTypeStandard;
            [locationManager startUpdatingLocation];
        }
    }
}

// MARK: - locationManager

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    //取得當前位置
    CLLocation *currentLocation = [locations lastObject];
    if(currentLocation != nil){
        
        longitude = currentLocation.coordinate.longitude;
        latiude = currentLocation.coordinate.latitude;
        
        NSString *Slatitude = [NSString stringWithFormat:@"%.2f",currentLocation.coordinate.latitude];
        NSString *Slongitude = [NSString stringWithFormat:@"%.2f",currentLocation.coordinate.longitude];
        NSLog(@"latitude: %@", Slatitude);
        NSLog(@"longitude: %@", Slongitude);
        [_mainMap setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latiude, longitude), 500, 500) animated:YES];
    
        //停止偵測
        [locationManager stopUpdatingLocation];
    }
}

// MARK: - MKAnnotationView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    // 判斷Pin如果是目前位置就不修改
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        MKPinAnnotationView *customPinView = (MKPinAnnotationView*)[_mainMap dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];

        if (!customPinView){
            customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
        }

        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
//        customPinView.image = [UIImage imageNamed:@"pointRed"];

        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pointRed"]];
        customPinView.leftCalloutAccessoryView = image;
        return customPinView;
    }
    return nil;
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    NSLog(@"點選 DetailDisclosure");
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"肯德基" message:@"是否前往導航" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    [alerController addAction:okAction];
    [alerController addAction:cancelAction];
    [self presentViewController:alerController animated:YES completion:nil];
    
}
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
