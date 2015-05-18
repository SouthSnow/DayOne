//
//  DetailViewController.m
//  DayOne
//
//  Created by pfl on 15/2/9.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import "DetailViewController.h"
#import "FileDocument.h"

@interface DetailViewController ()<fileDocumentDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIImageView *iamgeView;
@property (nonatomic, strong) FileDocument *document;
@property (nonatomic, strong) UIImagePickerController *imagePicke;
@property (nonatomic, strong) UIImage *theImage;
@property (nonatomic, strong) NSURL *path;
@end

@implementation DetailViewController
@synthesize imagePicke,theImage,path;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addImageView];


    FileDocument *fileDocument = [[FileDocument alloc]initWithFileURL:_fileURL];
    fileDocument.delegate = self;
    _document = fileDocument;
    
    if (fileDocument.documentState & UIDocumentStateClosed) {
        [fileDocument openWithCompletionHandler:nil];
    }
}

- (void)fileContentDidChanged:(FileDocument *)document
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        _iamgeView.image = [document myImage];
        
        
    });
}



- (void)addImageView
{
    self.iamgeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
    [self.view addSubview:_iamgeView];
    self.iamgeView.layer.cornerRadius = 3.0f;
    self.iamgeView.layer.masksToBounds = YES;
    self.iamgeView.layer.borderColor = [UIColor redColor].CGColor;
    self.iamgeView.backgroundColor = [UIColor grayColor];
    self.iamgeView.userInteractionEnabled = YES;
    [self.iamgeView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getImage:)]];
    
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    _document.myImage = theImage;
    
    [_document closeWithCompletionHandler:nil];
}


- (void)getImage:(UITapGestureRecognizer*)tap
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"更改相册封面" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"手机相册",@"拍照", nil];
    [sheet showInView:self.view];
    
}

#pragma mark UIAlertViewDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0)
    {
        
        [self pickImageFromAlbum];
        
        
    }
    else if (buttonIndex == 1)
    {
        [self pickImageFromCamera];
    }
    else
    {
        NSLog(@"======theimge=====%@",theImage);
    }
}


- (void)edit:(UITapGestureRecognizer*)tap
{
    
}
#pragma mark 从用户相册获取活动图片
- (void)pickImageFromAlbum
{
    imagePicke = [[UIImagePickerController alloc]init];
    imagePicke.delegate = self;
    imagePicke.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicke.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicke.allowsEditing = YES;
    [self presentViewController:imagePicke animated:YES completion:^{}];
}
#pragma mark 从摄像头获取活动图片
- (void)pickImageFromCamera
{
    imagePicke = [[UIImagePickerController alloc]init];
    imagePicke.delegate = self;
    imagePicke.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicke.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicke.allowsEditing = YES;
    [self presentViewController:imagePicke animated:YES completion:^{}];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    theImage = info[UIImagePickerControllerEditedImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImageWriteToSavedPhotosAlbum(theImage, nil, nil, nil);
    }
    
    NSData *imageData = UIImageJPEGRepresentation(theImage, 0);
//    path = [NSHomeDirectory() stringByAppendingPathComponent:@"image"];
//    [imageData writeToFile:path atomically:YES];
    _iamgeView.image = [UIImage imageWithData:imageData];
    _iamgeView.image = theImage;
    _document.myImage = theImage;
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

@end














