//
//  ViewController.m
//  ReleaseTest1
//
//  Created by InfoSapex on 7/11/17.
//  Copyright © 2017 Infosapex Limited. All rights reserved.
//

#import "ViewController.h"
#import <LazyPDFKit/LazyPDFKit.h>

static NSString* segueChart = @"segueChart";

@implementation ViewController
{
    RLMResults *tableDataArray;
}
#pragma mark - UIViewController delegate methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appUtil = [AppUtility new];
    
    self.vwColorsListing.delegate = self;
    self.vwColorsListing.dataSource = self;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    //Load realm data here
    
    NSArray *colorDataArry =  @[
                              @{
                              @"color": @"SILVER",
                              @"value": @"#C0C0C0"
                              },
                              @{
                              @"color": @"RED",
                              @"value": @"#FF0000"
                              },
                              @{
                              @"color": @"MAROON",
                              @"value": @"#800000"
                              },
                              @{
                              @"color": @"YELLOW",
                              @"value": @"#FFFF00"
                              },
                              @{
                              @"color": @"OLIVE",
                              @"value": @"#808000"
                              },
                              @{
                              @"color": @"LIME",
                              @"value": @"#00FF00"
                              },
                              @{
                              @"color": @"GREEN",
                              @"value": @"#008000"
                              }
                              ];
    
    tableDataArray = [appUtil saveAndLoadToRealmResultsFromArray: colorDataArry forKey: @"color"];
    
    NSLog(@"Loaded data to Realm table and printing from Realm Array: %@", [tableDataArray description]);
    
    
    [self.vwColorsListing reloadData];
    
}

#pragma mark - Button Actions
- (IBAction)crashButtonTapped:(id)sender {
    [appUtil forceACrash];
}

- (IBAction)openChart:(id)sender {
    [self performSegueWithIdentifier:segueChart sender:self];
}
- (IBAction)openPDF:(id)sender {
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    NSString *filePath = [pdfs firstObject]; assert(filePath != nil); // Path to first PDF file
    
    LazyPDFDocument *document = [LazyPDFDocument withDocumentFilePath:filePath password:phrase];
    
    if (document != nil) // Must have a valid LazyPDFDocument object in order to proceed with things
    {
        LazyPDFViewController *lazyPDFViewController = [[LazyPDFViewController alloc] initWithLazyPDFDocument:document];
        
        lazyPDFViewController.delegate = self; // Set the LazyPDFViewController delegate to self
        
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
        [self.navigationController pushViewController:lazyPDFViewController animated:YES];
        
#else // present in a modal view controller
        
        lazyPDFViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        lazyPDFViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:lazyPDFViewController animated:YES completion:NULL];
        
#endif // DEMO_VIEW_CONTROLLER_PUSH
    }
    else // Log an error so that we know that something went wrong
    {
        NSLog(@"%s [LazyPDFDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
    }
}

#pragma mark - UITableView Datasource and Delegate
static NSString* strColorListingCell = @"ColorsListingCell";
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ColorsListingCell *cell = [tableView dequeueReusableCellWithIdentifier:strColorListingCell];
    if (cell == nil)
    {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:strColorListingCell owner:self options:nil];
        for (id currentObject in objects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (ColorsListingCell *)currentObject;
                break;
            }
        }
    }
    
    ColorDataTable *aColorTbl = tableDataArray[indexPath.row];
    
    cell.backgroundColor = [UIColor colorWithHexString : aColorTbl.value];// or UIColorWithHexString(aColorTbl.value);
    
    
    cell.lblcolor.text = aColorTbl.color;
    cell.lblValue.text = aColorTbl.value;
    
    cell.lblcolor.textColor = kWhiteColor;
    cell.lblValue.textColor = kWhiteColor;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view hideToasts];
    
    ColorDataTable *aColorTbl = tableDataArray[indexPath.row];
    CSToastStyle* toastStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    toastStyle.backgroundColor = UIColorWithHexString(aColorTbl.value);
    toastStyle.cornerRadius = 10.0;
    toastStyle.messageColor = kWhiteColor;
    toastStyle.displayShadow = YES;
    toastStyle.shadowColor = kBlackColor;
    [self.view makeToast:[NSString stringWithFormat:@"Color Name: %@. Color Code: %@", aColorTbl.color, aColorTbl.value] duration:ToastDuration position:CSToastPositionCenter style:toastStyle];
    
    [tableView reloadData];
}
#pragma mark - LazyPDFViewControllerDelegate methods

- (void)dismissLazyPDFViewController:(LazyPDFViewController *)viewController
{
    // dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Segue Callback
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"segueChart"] )
    {
        
    }
}
@end
