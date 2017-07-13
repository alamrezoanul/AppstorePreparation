//
//  BMSAxisValueFormatter.m
//  Boardmeeting
//
//  Created by InfoSapex on 1/31/17.
//  Copyright © 2017 InfoSapex Limited. All rights reserved.
//

#import "BMSAxisValueFormatter.h"

@implementation BMSAxisValueFormatter
{
}

- (NSString *)stringForValue:(double)value
						axis:(ChartAxisBase *)axis
{
	
	return self.xAxisText;
}

@end
