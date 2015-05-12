//
//  FileDocument.h
//  DayOne
//
//  Created by pfl on 15/2/9.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol fileDocumentDelegate;



@interface FileDocument : UIDocument
@property (nonatomic,weak) id<fileDocumentDelegate>delegate;
@property (nonatomic, strong) NSFileWrapper *mainFileWrapper;
@property (nonatomic, copy) NSString *documentText;
@property (nonatomic, strong) UIImage * myImage;
@property (nonatomic, copy) NSString *imageStr;


@end

@protocol fileDocumentDelegate <NSObject>

- (void)fileContentDidChanged:(FileDocument*)document;

@end