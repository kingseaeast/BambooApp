//
//  BambooFlipsideViewController.h
//  Bamboo
//
//  Created by Haidong Wang on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BambooFlipsideViewController;

@protocol BambooFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(BambooFlipsideViewController *)controller;
@end

@interface BambooFlipsideViewController : UIViewController

@property (weak, nonatomic) id <BambooFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
