//
//  DashBoardViewController.m
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "DashBoardViewController.h"
#import "DataBaseManager.h"
#import "MyUserDefaults.h"
#import "DashBoardTableViewCell.h"

NSString* dateFormat = @"yyyy-MM-dd HH:mm";

@interface DashBoardViewController ()
@property (nonatomic, strong) NSMutableArray* upcomingAppointmentsTableDataSource;
@property (nonatomic, strong) IBOutlet UITableView* upcomingAppointmentsTable;
@end

@implementation DashBoardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.upcomingAppointmentsTable.dataSource = self;
    self.upcomingAppointmentsTable.delegate = self;
    
    self.upcomingAppointmentsTableDataSource = [[NSMutableArray alloc] init];
    
    NSString* patientID = [MyUserDefaults retrievePatientId];
    
    [[DataBaseManager sharedInstance] retreivePatientAppointmentWithResponseCallback:^(NSDictionary* appointments){
        
        for (NSString* key in appointments)
        {
            NSDictionary* appointment = [appointments objectForKey:key];
            
            if ([[appointment objectForKey:@"patientID"] isEqualToString:patientID])
            {
                [self.upcomingAppointmentsTableDataSource addObject:appointment];
            }
        }
        
        [self reloadData];
        
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)reloadData
{
    [self.upcomingAppointmentsTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DashBoardTableViewCell";
    
    NSDictionary* appointment = [self.upcomingAppointmentsTableDataSource objectAtIndex:indexPath.row];
    
    DashBoardTableViewCell* cell = (DashBoardTableViewCell* )[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DashBoardTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSDate* date = [dateFormatter dateFromString:[appointment objectForKey:@"date"]];
    
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dayFormatter stringFromDate:date];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era])
    {
       dayName = @"Today";
    }
    
    cell.dayLabel.text = dayName;
    
    
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"MMMM dd, YYYY"];
    
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    cell.timeLabel.text = [formatter stringFromDate:date];
    
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.upcomingAppointmentsTable isEqual:tableView])
    {
        return [self.upcomingAppointmentsTableDataSource count];
    }
    return 0;
}



@end