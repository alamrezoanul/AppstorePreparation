//
//  ViewController.h
//  ReleaseTest1
//
//  Created by InfoSapex on 7/11/17.
//  Copyright © 2017 Infosapex Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Charts-Swift.h"

#import "LazyPDFKit/LazyPDFKit.h"

@interface ViewController : UIViewController<LazyPDFViewControllerDelegate>

#pragma mark - Chart
//Start For Chart
@property (nonatomic, strong) IBOutlet HorizontalBarChartView* chartViewPollResult;
//End For Chart

#pragma mark - LazyPDFKit
- (IBAction)openPDF:(id)sender;

- (IBAction)openChart:(id)sender;
@end

