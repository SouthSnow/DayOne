//
//  FileRepresentation.h
//  DayOne
//
//  Created by pfl on 15/2/6.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileRepresentation : NSObject
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSURL *fileURL;

- (instancetype)initWith:(NSString*)fileName fileURL:(NSURL*)fileURL;


@end
