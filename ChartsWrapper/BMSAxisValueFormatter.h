//
//  BMSAxisValueFormatter.h
//  Boardmeeting
//
//  Created by InfoSapex on 1/31/17.
//  Copyright © 2017 InfoSapex Limited. All rights reserved.
//

#ifndef BMSAxisValueFormatter_h
#define BMSAxisValueFormatter_h

#import <UIKit/UIKit.h>
#import "Charts-Swift.h"

@interface BMSAxisValueFormatter : NSObject <IChartAxisValueFormatter>
@property (retain, nonatomic) NSString *xAxisText;
@end

#endif /* BMSAxisValueFormatter_h */
