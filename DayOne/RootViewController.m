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
#import "AppDelegate.h"

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"root";
    self.documents = [NSMutableArray arrayWithCapacity:10];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemAdd) target:self action:@selector(addNewFile)];
    self.addButton = self.navigationItem.rightBarButtonItem;
    
    
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processFiles) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processFiles) name:NSMetadataQueryDidUpdateNotification object:nil];
    
    
    [_metaDataQuery startQuery];
    
    
}

- (void)processFiles
{
    [_metaDataQuery disableUpdates];
    
    NSArray *arr = [_metaDataQuery results];
    NSMutableArray *temArr = [NSMutableArray arrayWithCapacity:10];
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
    
    [_documents removeAllObjects];
    [_documents addObjectsFromArray:temArr];
    [_documents sortUsingComparator:^NSComparisonResult(FileRepresentation *obj1, FileRepresentation *obj2) {
       return [obj1.fileURL.lastPathComponent localizedStandardCompare:obj2.fileURL.lastPathComponent];
    }];
    [self.tableView reloadData];
    [_metaDataQuery enableUpdates];
    
    
}


- (void)deleteDocumentsFromUI
{
    _metaDataQuery = nil;
    [_documents removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudDataChange" object:nil userInfo:nil];
    
    
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
    
    
}

- (void)addNewFile
{
    
    self.addButton.enabled = NO;
    
    BOOL iCloudAccess = [(AppDelegate*)[[UIApplication sharedApplication]delegate] documentsiCloud];
    
    if (iCloudAccess) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *newURL = [[NSFileManager defaultManager]URLForUbiquityContainerIdentifier:nil];
            newURL = [newURL URLByAppendingPathComponent:documents isDirectory:YES];
            newURL = [newURL URLByAppendingPathComponent:[self newUntitleFileURL]];
            
            FileRepresentation *file = [[FileRepresentation alloc]initWith:[self newUntitleFileURL] fileURL:newURL];
            [_documents addObject:file];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_documents.count - 1 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPositionMiddle)];
                
                DetailViewController *detail = [[DetailViewController alloc]init];
                detail.navigationItem.title = [NSString stringWithFormat:@"entry%ld",_documents.count];;
                detail.fileURL = [(FileRepresentation*)_documents[indexPath.row] fileURL];
                [self.navigationController pushViewController:detail animated:YES];
            });
            
        });
    }
    
    else
    {
        NSURL *fileURL = [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
        fileURL = [fileURL URLByAppendingPathComponent:documents isDirectory:YES];
        fileURL = [fileURL URLByAppendingPathComponent:[self newUntitleFileURL]];
        
        FileRepresentation *file = [[FileRepresentation alloc]initWith:[self newUntitleFileURL] fileURL:fileURL];
        
        [_documents addObject:file];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_documents.count - 1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPositionMiddle)];
        
        
        DetailViewController *detail = [[DetailViewController alloc]init];
        detail.navigationItem.title = [NSString stringWithFormat:@"entry%ld",_documents.count];;
        detail.fileURL = [(FileRepresentation*)_documents[indexPath.row] fileURL];
        [self.navigationController pushViewController:detail animated:YES];
        
        
        
    }
    
    self.addButton.enabled = YES;
}


- (NSString*)newUntitleFileURL
{
    NSString *newURL = nil;
    NSInteger fileCount = 1;
    BOOL done = NO;
    while (!done)
    {
        
        newURL = [NSString stringWithFormat:@"entry%ld.%@",fileCount++,fileLastComponent];
        
        BOOL exisit = NO;
        
        for (FileRepresentation *file in _documents)
        {
            if ([newURL isEqualToString:file.fileURL.lastPathComponent])
            {
                exisit = YES;
                break;
            }
            
        }
        if (!exisit) {
            done = YES;
        }
    }
    
    return newURL;

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
    cell.textLabel.text = [file.fileURL URLByDeletingPathExtension].lastPathComponent;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    DetailViewController *detail = [[DetailViewController alloc]init];
    detail.title = selectedCell.textLabel.text;
    detail.fileURL = [(FileRepresentation*)_documents[indexPath.row] fileURL];
    [self.navigationController pushViewController:detail animated:YES];
}







@end





















