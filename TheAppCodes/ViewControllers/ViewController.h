//
//  ViewController.h
//  ReleaseTest1
//
//  Created by InfoSapex on 7/11/17.
//  Copyright © 2017 Infosapex Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppUtility.h"

#import "Charts-Swift.h"

#import "LazyPDFKit/LazyPDFKit.h"

#import "ColorsListingCell.h"

#import "LazyPDFKit/HeadersExposedFromLazyPDFKit.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, LazyPDFViewControllerDelegate>
{
    AppUtility *appUtil;
}
#pragma mark - Properties

//Start For UITableView
@property (nonatomic, strong) IBOutlet UITableView* vwColorsListing;
//End For UITableView


#pragma mark - LazyPDFKit
- (IBAction)openPDF:(id)sender;

- (IBAction)openChart:(id)sender;

- (IBAction)crashButtonTapped:(id)sender;

@end

