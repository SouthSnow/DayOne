//
//  RootViewController.m
//  DayOne
//
//  Created by pfl on 15/2/6.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "FileRepresentation.h"
#import "DetailViewController.h"

NSString *documents = @"Documents";
NSString *fileLastComponent = @"entry";

@interface RootViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMetadataQuery *metaDataQuery;
@property (nonatomic, strong) NSMutableArray *documents;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector (setupQueryiCloud) name: @"setupAndStartQueryNotification" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector (deleteDocumentsFromUI) name: @"deleteDocumentsFromUINotification" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (reloadData) name:@"iCloudDataChanged"object:nil];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"root";
    self.documents = [NSMutableArray arrayWithCapacity:10];
    
    _addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemAdd) target:self action:@selector(addNewFile)];
    self.navigationItem.rightBarButtonItem = _addButton;
    
    [self addTableView];
    
    AppDelegate *dele = [[UIApplication sharedApplication]delegate];
    if (dele.documentsiCloud) {
        [self setupQueryiCloud];
    }
    else
    {
        [self fillDocumentsForLocalStorage];
    }
    
}

- (void)setupQueryiCloud
{
    if (!_metaDataQuery) {
        _metaDataQuery = [[NSMetadataQuery alloc]init];
    }
    
    
    
    [_metaDataQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    NSString *filePattem = [NSString stringWithFormat:@"*.%@",fileLastComponent];
    [_metaDataQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",NSMetadataItemFSNameKey,filePattem]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector (processFiles) name: NSMetadataQueryDidFinishGatheringNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector (processFiles) name: NSMetadataQueryDidUpdateNotification object: nil];
    
    
    [_metaDataQuery startQuery];
    
    
}

- (void)processFiles
{
    [_metaDataQuery disableUpdates];
    
    
    NSMutableArray *temArr = [NSMutableArray array];
     [_documents removeAllObjects];
    
    NSArray *arr = [_metaDataQuery results];
    
    [arr enumerateObjectsUsingBlock:^(NSMetadataItem *item, NSUInteger idx, BOOL *stop) {
        
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        NSURL *fileURL = [item valueForAttribute:NSMetadataItemURLKey];
        NSNumber *aBool = nil;
        [fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
        if (aBool && ![aBool boolValue]) {
            FileRepresentation *file = [[FileRepresentation alloc]initWith:fileName fileURL:fileURL];
            [temArr addObject:file];
        }
    }];
    
   
    [_documents addObjectsFromArray:temArr];
    [_tableView reloadData];
    [_metaDataQuery enableUpdates];
    
    
}


- (void)deleteDocumentsFromUI
{
    _metaDataQuery = nil;
    [_documents removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudDataChange" object:nil userInfo:nil];
    
//    [_tableView reloadData];
}


- (void)fillDocumentsForLocalStorage
{
    
    NSMutableArray *temArr = [NSMutableArray array];
    
    NSURL *fileURL = [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
    
    NSArray *documentsDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:fileURL includingPropertiesForKeys:@[NSURLNameKey] options:(NSDirectoryEnumerationSkipsHiddenFiles) error:nil];
    
    [documentsDirectory enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        
        NSString *fileName = [fileURL lastPathComponent];
        FileRepresentation *file = [[FileRepresentation alloc]initWith:fileName fileURL:fileURL];
        [temArr addObject:file];
        
    }];
    
    [_documents removeAllObjects];
    [_documents addObjectsFromArray:temArr];
    [self.tableView reloadData];
    
}

- (void)addNewFile
{
    
    BOOL usingiCloud = [(AppDelegate*)[[UIApplication sharedApplication] delegate] documentsiCloud];
    if (usingiCloud) _addButton.enabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *newURL = [[NSFileManager defaultManager]URLForUbiquityContainerIdentifier:nil];
        newURL = [newURL URLByAppendingPathComponent:documents isDirectory:YES];
        newURL = [newURL URLByAppendingPathComponent:[self newUntitlePatten]];
        
        FileRepresentation *file = [[FileRepresentation alloc]initWith:[self newUntitlePatten] fileURL:newURL];
        [_documents addObject:file];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_documents.count - 1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPositionMiddle)];
            UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            DetailViewController *detail = [[DetailViewController alloc]init];
            detail.file = file;
            [self.navigationController pushViewController:detail animated:YES];
            detail.title = selectedCell.textLabel.text?:[NSString stringWithFormat:@"entry%ld",_documents.count];
            detail.arr = _documents;
            
        });
        
    });
    
    
    _addButton.enabled = YES;
    
    
}


- (NSString*)newUntitlePatten
{
    NSInteger fileCount = 1;
    
    NSString *newFile = nil;
    BOOL done = NO;
    while (!done) {
    
        newFile = [NSString stringWithFormat:@"entry%ld.%@",fileCount,fileLastComponent];
        
        BOOL exist = NO;
        for (FileRepresentation *file in _documents) {
            if ([file.fileName.lastPathComponent isEqualToString:newFile]) {
                fileCount++;
                exist = YES;
                break;
            }
        }
        
        if (!exist) {
            done = YES;
        }
        
    }

    return newFile;
    
}



- (void)addTableView
{
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:(UITableViewStylePlain)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc]init];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _documents.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        
        
    }

    FileRepresentation *file = (FileRepresentation*)_documents[indexPath.row];
    cell.textLabel.text = [[[file.fileURL URLByDeletingPathExtension]lastPathComponent] description];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileRepresentation *file = _documents[indexPath.row];
    DetailViewController *detail = [[DetailViewController alloc]init];
    detail.file = file;
    [self.navigationController pushViewController:detail animated:YES];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    detail.title = selectedCell.textLabel.text;
}





@end





















