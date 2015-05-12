//
//  FileRepresentation.m
//  DayOne
//
//  Created by pfl on 15/2/6.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import "FileRepresentation.h"

@implementation FileRepresentation

- (instancetype)initWith:(NSString *)fileName fileURL:(NSURL *)fileURL
{
    self = [super init];
    if (self) {
        
        _fileName = fileName;
        _fileURL = fileURL;
        
    }
    
    return self;
}


@end
