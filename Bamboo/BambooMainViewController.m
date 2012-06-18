//
//  BambooMainViewController.m
//  Bamboo
//
//  Created by Haidong Wang on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BambooMainViewController.h"

#define kFilteringFactor 0.1

@interface BambooMainViewController ()

@end

@implementation BambooMainViewController
@synthesize switchButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor =  [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"b1.jpg"]];
    
    lastTransferTime = [[NSDate alloc] init];
    rangeArray = [[NSMutableArray alloc] init];
    isTrackingOn = false;
    
}

- (void)viewDidUnload
{
    [self setSwitchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)startAccel {
    NSLog(@"Start Accel");
    
    UIAccelerometer *a = [UIAccelerometer sharedAccelerometer];
    
    [a setUpdateInterval:0.1];
    [a setDelegate:self];
    lastTransferTime = [NSDate date];
}

- (void)stopAccel {
    NSLog(@"stop accel");
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

- (void)sendDataToServer {
    dataToSend = [[self arrayAverage:rangeArray ] componentsJoinedByString:@","];
    
    NSString *body = [[NSString alloc] initWithFormat:@"move[range]=%@", dataToSend];
    
    NSURL *url = [NSURL URLWithString:@"http://192.168.2.13:3000/moves.json"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        receivedData = [[NSMutableData data] init];
    } else {
        NSLog(@"theConnection is null");
    }
    
    lastTransferTime = [NSDate date];
    [rangeArray removeAllObjects];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
    NSHTTPURLResponse* resp = (NSHTTPURLResponse *)response;
    NSLog(@"Http status:%d", resp.statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    NSLog(@"%@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
}

-(NSMutableArray*)arrayAverage:(NSMutableArray *)array {
    int total = 0;
    int count = 0;
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    for (id object in array) {
        total = total + [object intValue];
        count++;
        
        if (count > 10) {
            int avr = total / count;
            [result addObject:[NSNumber numberWithInt:avr]];
            count = 0;
            total = 0;
        }
    }
    
    int avr = total / count;
    [result addObject:[NSNumber numberWithInt:avr]];
    return result;
}

- (IBAction)switchClicked:(id)sender {
    if (isTrackingOn) {
        isTrackingOn = false;
        [self stopAccel];
        UIImage *backgroundImage = [UIImage imageNamed:@"bb2.png"];
        [switchButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        [self sendDataToServer];
        
    } else {
        isTrackingOn = true;
        [self startAccel];
        UIImage *backgroundImage = [UIImage imageNamed:@"bb1.jpg"];
        [switchButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    float dx = fabsf(accelX - acceleration.x) * 100;
    float dy = fabsf(accelY - acceleration.y) * 100;
    float dz = fabsf(accelZ - acceleration.z) * 100;
    
    accelX = acceleration.x;
    accelY = acceleration.y;
    accelZ = acceleration.z;
    
    NSLog(@"%f, %f, %f", fabsf(accelX), fabsf(accelY), fabsf(accelZ));
    
    int move = (int)(dx + dy + dz);
    [rangeArray addObject:[NSNumber numberWithInt:move]];
    
    //NSDate *now = [NSDate date];
    //NSTimeInterval interval = [now timeIntervalSinceDate:lastTransferTime];
    if (rangeArray.count > 100) {
        [self sendDataToServer];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(BambooFlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

@end
