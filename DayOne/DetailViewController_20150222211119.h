//
//  DetailViewController.h
//  DayOne
//
//  Created by pangfuli on 15/2/6.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileRepresentation.h"

@interface DetailViewController : UIViewController
@property (nonatomic, strong) FileRepresentation *file;
@property (nonatomic, strong) NSArray *arr;
@end
