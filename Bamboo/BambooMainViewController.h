//
//  BambooMainViewController.h
//  Bamboo
//
//  Created by Haidong Wang on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BambooFlipsideViewController.h"

@interface BambooMainViewController : UIViewController <BambooFlipsideViewControllerDelegate, UIAccelerometerDelegate>
{
    // data for HTTP response
    NSMutableData *receivedData;
    
    // Timer for last data transfer
    NSDate *lastTransferTime;
    
    // data for the range content
    NSMutableArray *rangeArray;
    
    NSString *dataToSend;
    
    float accelX;
    float accelY;
    float accelZ;
    
    BOOL isTrackingOn;
}

- (void)sendDataToServer;
- (void)startAccel;
- (void)stopAccel;
- (NSMutableArray*)arrayAverage:(NSMutableArray *)array;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

- (IBAction)switchClicked:(id)sender;
@end
