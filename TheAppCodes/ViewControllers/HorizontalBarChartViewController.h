//
//  HorizontalBarChartViewController.h
//  ReleaseTest1
//
//  Created by TAHIYAH ALAM KHAN on 7/11/17.
//  Copyright © 2017 Infosapex Limited. All rights reserved.
//

#ifndef HorizontalBarChartViewController_h
#define HorizontalBarChartViewController_h

//
//  HorizontalBarChartViewController.h
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import <UIKit/UIKit.h>
#import "Charts-Swift.h"

@interface HorizontalBarChartViewController : UIViewController<ChartViewDelegate>
@property (nonatomic, strong) IBOutlet HorizontalBarChartView *chartView;
@end

#endif /* HorizontalBarChartViewController_h */
