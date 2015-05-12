//
//  DetailViewController.m
//  DayOne
//
//  Created by pangfuli on 15/2/6.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import "DetailViewController.h"
#import "JFWrappedDocument.h"


@interface DetailViewController ()<JFWrappedDocumentDelegate,UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) JFWrappedDocument *document;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, assign) BOOL isNewCreating;
@property (nonatomic, assign) CGRect keyboardRect;
@property (nonatomic, assign) BOOL createFile;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
   
    self.doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemDone) target:self action:@selector(setEditing:animated:)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardAppearanced:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
     [self addTextView];
    
    _document = [[JFWrappedDocument alloc]initWithFileURL:_file.fileURL];
    _document.delegate = self;
    
    if (_createFile) {
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success) {
                   _textView.text = _document.documentText;
               }];
        _createFile = NO;
    }
    else {
        if (self.document.documentState & UIDocumentStateClosed) {
            [self.document openWithCompletionHandler:nil];
        }
    }
    
  
    
}


- (void)viewDidAppear:(BOOL)animated
{
    BOOL isNewCreating = [[NSUserDefaults standardUserDefaults]boolForKey:self.navigationItem.title?:[NSString stringWithFormat:@"entry%ld",_arr.count]];
    
    if (!isNewCreating) {
        _textView.editable = YES;
        [_textView becomeFirstResponder];
        [self setEditing:YES animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:!_isNewCreating forKey:self.navigationItem.title?:[NSString stringWithFormat:@"entry%ld",_arr.count]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
       
        
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    
    self.navigationItem.rightBarButtonItem = editing?self.doneButton:self.editButtonItem;
    _textView.editable = editing;
    (editing)?[_textView becomeFirstResponder]:[_textView resignFirstResponder];
    
    if (!editing) {
//        [_document saveToURL:_file.fileURL forSaveOperation:(UIDocumentSaveForCreating) completionHandler:^(BOOL success) {}];
    }
    else
    {
//        [_textView scrollRangeToVisible:NSMakeRange(0, _textView.contentSize.height)];
        if (_textView.contentSize.height >= CGRectGetHeight(self.view.frame)-252 - 64) {
            CGRect rect = _textView.frame;
            rect.origin.y = CGRectGetHeight(self.view.frame) - (_textView.contentSize.height + 252 + 20);;
            rect.size.height = _textView.contentSize.height;
            _textView.frame = rect;
        }
    }
}

- (void)keyboardAppearanced:(NSNotification*)notification
{
    
    NSDictionary *userInfo = notification.userInfo;
    NSValue *frameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [frameValue CGRectValue];
    _keyboardRect = keyboardFrame;
    
    
}




#pragma mark UITextViewDelegate

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
//{
//    if (textView.contentSize.height >= CGRectGetHeight(self.view.frame)-_keyboardRect.size.height - 64) {
//        CGRect rect = textView.frame;
//        rect.origin.y = - _keyboardRect.size.height;
//        rect.size.height = textView.contentSize.height;
//        textView.frame = rect;
//    }
//    return YES;
//}

- (void)textViewDidChange:(UITextView *)textView
{

    if (textView.contentSize.height >= CGRectGetHeight(self.view.frame)-_keyboardRect.size.height - 64) {
        CGRect rect = textView.frame;
        rect.origin.y = CGRectGetHeight(self.view.frame) - (textView.contentSize.height + _keyboardRect.size.height + 20);
        rect.size.height = textView.contentSize.height;
        textView.frame = rect;
//        textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, textView.contentSize.height-20, 0);
//        [textView scrollRectToVisible:textView.frame animated:YES];
//        [textView setContentOffset:CGPointMake(0, textView.frame.size.height) animated:YES];
    }
    
    NSLog(@"contentSize %@",NSStringFromCGSize(textView.contentSize));
     NSLog(@"_keyboardRect %@",NSStringFromCGSize(_keyboardRect.size));
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGRect rect = textView.frame;
    rect.origin.y = 0;
    rect.size.height = CGRectGetHeight(self.view.frame)-150;
    textView.frame = rect;
}



- (void)addTextView
{
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.view.frame)-20, CGRectGetHeight(self.view.frame)-150)];
    _textView.editable = NO;
    _textView.delegate = self;
    _textView.showsVerticalScrollIndicator = NO;
    _textView.font = [UIFont fontWithName:@"Helvetica" size:18];
    [self.view addSubview:_textView];
}

- (void)documentContentsDidChange:(JFWrappedDocument *)document
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = document.documentText;
    });
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    _document.documentText = _textView.text;
    [_document closeWithCompletionHandler:nil];
    
}

@end






