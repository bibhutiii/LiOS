//
//  LRAboutUSViewController.m
//  Leerink
//
//  Created by Ashish on 22/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRAboutUSViewController.h"

@interface LRAboutUSViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *aboutUsMapView;

@end

@implementation LRAboutUSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"About Us";
    self.aboutUsMapView.delegate = self;
    self.aboutUsMapView.showsUserLocation = YES;
    MKCoordinateRegion mapRegion;
    CLLocationCoordinate2D coordinate = {40.756480,-73.973774};
    
    mapRegion.center = coordinate;
    mapRegion.span.latitudeDelta = 0.08;
    mapRegion.span.longitudeDelta = 0.087;
    
    [self.aboutUsMapView setRegion:mapRegion animated: YES];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coordinate;
    point.title = @"Leerink Partners";
    point.subtitle = @"";
    
    [self.aboutUsMapView addAnnotation:point];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a [LRAppDelegate myStoryBoard]-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
