//
//  FileDocument.m
//  DayOne
//
//  Created by pfl on 15/2/9.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import "FileDocument.h"

NSString *textName = @"textName";
NSString *imageName = @"imageName";

@interface FileDocument ()
@property (nonatomic, strong) NSFileWrapper *textFileWrapper;
@property (nonatomic, strong) NSFileWrapper *imageFileWrapper;
@property (nonatomic, copy) NSString *documentString;
@property (nonatomic, strong) UIImage *img;

@end


@implementation FileDocument

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    
    
    if (_mainFileWrapper == nil) {
        _mainFileWrapper = (NSFileWrapper*)contents;
    }
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(fileContentDidChanged:)]) {
        [_delegate fileContentDidChanged:self];
    }
    
    
    
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    
    if (_mainFileWrapper) {
        _mainFileWrapper = [[NSFileWrapper alloc]initDirectoryWithFileWrappers:nil];
    }
  
        
    NSDictionary *dic = [_mainFileWrapper fileWrappers];
    
    if (self.documentText) {
        NSData *data = [_documentString dataUsingEncoding:NSUTF8StringEncoding];
        NSFileWrapper *textFileWrapper = [dic objectForKey:textName];
        if (textFileWrapper) {
            [_mainFileWrapper removeFileWrapper:textFileWrapper];
        }
        
        textFileWrapper = [[NSFileWrapper alloc]initRegularFileWithContents:data];
        [textFileWrapper setPreferredFilename:textName];
        [_mainFileWrapper addFileWrapper:textFileWrapper];
        
        
    }
        
        
 
    if (self.myImage) {
        
        NSData *data;
        UIImage *image = [UIImage imageNamed:_imageStr];
        if ([_imageStr hasSuffix:@"png"] || [_imageStr hasSuffix:@"PNG"]) {
            
        
            data = UIImagePNGRepresentation(image);
        }
        else
        {
            data = UIImageJPEGRepresentation(image, 0);
        }
        
        NSFileWrapper *imageFileWrapper = [dic objectForKey:imageName];
        if (imageFileWrapper) {
            [_mainFileWrapper removeFileWrapper:imageFileWrapper];
            
        }
        
        imageFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
        [imageFileWrapper setPreferredFilename:imageName];
        [_mainFileWrapper addFileWrapper:imageFileWrapper];
    
    }
    
    
    
    return _mainFileWrapper;
}


- (void)setDocumentText:(NSString *)documentText
{
    if (_documentString != documentText) {
        NSString *old = _documentString;
        _documentString = documentText;
        [self.undoManager registerUndoWithTarget:self selector:@selector(setDocumentText:) object:old];
    }
}

- (NSString*)documentText
{
    if (_documentString) {
        return _documentString;
    }
    
    NSDictionary *dic = [_mainFileWrapper fileWrappers];
    if (dic) {
        _textFileWrapper = [dic objectForKey:textName];
        
    }
    
    if (_textFileWrapper) {
        NSData *data = [_textFileWrapper regularFileContents];
        _documentString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return _documentString;
}





- (void)setMyImage:(UIImage *)myImage
{
    if (_img != myImage) {
        UIImage *old = _img;
        _img = myImage;
        [self.undoManager registerUndoWithTarget:self selector:@selector(setMyImage:) object:old];
    }
}

- (UIImage*)myImage
{
    if (_img) {
        return _img;
    }
    
    NSDictionary *dic = [_mainFileWrapper fileWrappers];
    if (dic) {
        _imageFileWrapper = [dic objectForKey:imageName];
    }

    if (_imageFileWrapper) {
        NSData *data = [_imageFileWrapper regularFileContents];
        
        _img = [UIImage imageWithData:data];
    }
    return _img;

}



- (void)saveToURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^)(BOOL))completionHandler
{
    [super saveToURL:url forSaveOperation:saveOperation completionHandler:^(BOOL success){
        if (success) {
            
            
            NSLog(@"===========");
            
            
        }
    }
     ];
}



@end














