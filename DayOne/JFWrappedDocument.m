
#import "AppDelegate.h"
#import "JFWrappedDocument.h"

NSString *UbiquityDirectoryComponentForDocuments = @"Documents";   //1

NSString *TextFileName = @"Text.txt";                        //2
NSString *LocationFileName = @"Location.txt";

NSString *nameName = @"name.txt";
NSString *identityName = @"identity.txt";
NSString *birthdateName = @"birthdate.txt";
NSString *ageName = @"age.txt";
NSString *sexName = @"sex.txt";
NSString *colorName = @"color.txt";


NSStringEncoding kTextFileEncoding = NSUTF8StringEncoding;   //3

@interface JFWrappedDocument ()                              //4

@property (strong, nonatomic) NSFileWrapper *wrapperText;
@property (strong, nonatomic) NSFileWrapper *wrapperLocation;

@property (strong, nonatomic) NSFileWrapper *wrapperName;
@property (strong, nonatomic) NSFileWrapper *wrapperIdentity;
@property (strong, nonatomic) NSFileWrapper *wrapperBirthdate;
@property (strong, nonatomic) NSFileWrapper *wrapperAge;
@property (strong, nonatomic) NSFileWrapper *wrapperSex;
@property (strong, nonatomic) NSFileWrapper *wrapperColor;

@property (strong, nonatomic) NSString *fwText;
@property (strong, nonatomic) NSString *fwLocation;
@property (strong, nonatomic) NSString *nameText;
@property (strong, nonatomic) NSString *identityText;
@property (strong, nonatomic) NSString *sexText;
@property (strong, nonatomic) NSString *ageText;
@property (strong, nonatomic) NSString *colorText;
@property (strong, nonatomic) NSString *birthdateText;




@end


@implementation JFWrappedDocument

#pragma mark - Accessors, Undo/Redo

-(NSString*)documentText {

  if (_fwText)
    return _fwText;
  
  NSDictionary *fileWrappers = [_documentFileWrapper fileWrappers];  //5
  
  if (!_wrapperText) {
    _wrapperText = [fileWrappers objectForKey: TextFileName];//6
  }
  
  if (_wrapperText != nil)
  {
    NSData *textData = [_wrapperText regularFileContents];   //7
    _fwText = [[NSString alloc] initWithData:textData encoding:kTextFileEncoding];  //11
  }
  

  
  return _fwText;
}

-(void)setDocumentText: (NSString*)newText {     //8

  if (newText != _fwText )
  {
    NSString *oldText = _fwText;
    _fwText = newText;

    //register undo and cause autosave
    [self.undoManager setActionName: @"Text Change"];
    [self.undoManager registerUndoWithTarget:self
                                    selector: @selector(setDocumentText:)
                                      object: oldText];


  }
}

-(NSString*)documentLocation {  //9
   if (_fwLocation)
    return _fwLocation;
  
  NSDictionary *fileWrappers = [_documentFileWrapper fileWrappers];   //10
  
  if (!_wrapperLocation) {
    _wrapperLocation = [fileWrappers objectForKey: LocationFileName];  //11
  }
  
  if (_wrapperLocation != nil)
  {
    NSData *locationData = [_wrapperLocation regularFileContents];  //12
    
    _fwLocation = [[NSString alloc] initWithData:locationData encoding:kTextFileEncoding];  //11
  } else {
   
  }
  
  
  return _fwLocation;
}

-(void)setDocumentLocation: (NSString*)newLocation {  //13
  if (newLocation != _fwLocation)
  {
    NSString *oldLocation = _fwLocation;
    _fwLocation = newLocation;
    
    [self.undoManager setActionName: @"Location Change"];
    [self.undoManager registerUndoWithTarget:self
                                    selector: @selector(setDocumentLocation:)
                                      object: oldLocation];
  }
  
}

- (void)setName:(NSString *)name
{
    if (_nameText != name) {
        NSString *oldName = _nameText;
        _nameText = name;
        
        [self.undoManager setActionName:@"name Change"];
        [self.undoManager registerUndoWithTarget:self selector:@selector(setName:) object:oldName];
    
    }
}

- (NSString*)name
{
    if (_nameText) {
        return _nameText;
    }
    
    NSDictionary *dic = [_documentFileWrapper fileWrappers];
    if (dic) {
        _wrapperName = [dic objectForKey:nameName];
    }
    if (_wrapperName) {
        NSData *data = [_wrapperName regularFileContents];
        _nameText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    
    return _nameText;
}

- (void)setAge:(NSString *)age
{
    if (age != _ageText) {
        NSString *oldAge = _ageText;
        _ageText = age;
        [self.undoManager setActionName:@"age change"];
        [self.undoManager registerUndoWithTarget:self selector:@selector(setAge:) object:oldAge];
        
    }
}

- (NSString*)age
{
    if (_ageText) {
        return _ageText;
    }
    
    NSDictionary *dict = [_documentFileWrapper fileWrappers];
    if (dict) {
        _wrapperAge = [dict objectForKey:ageName];
    }
    
    if (_wrapperAge) {
        NSData *data = [_wrapperAge regularFileContents];
        _ageText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return _ageText;
}


- (void)setIdentity:(NSString *)identity
{
    if (identity != _identityText) {
        NSString *old = _identityText;
        _identityText = identity;
        [self.undoManager setActionName:@"identity change"];
        [self.undoManager registerUndoWithTarget:self selector:@selector(setIdentity:) object:old];
        
    }
}

- (NSString*)identity
{
    if (_identityText) {
        return _identityText;
    }
    
    NSDictionary *dict = [_documentFileWrapper fileWrappers];
    if (dict) {
        _wrapperIdentity = [dict objectForKey:identityName];
    }
    if (_wrapperIdentity) {
        NSData *data = [_wrapperIdentity regularFileContents];
        _identityText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    
    return _identityText;
}

- (void)setSex:(NSString *)sex
{
    if (sex != _sexText) {
        NSString *oldSex = _sexText;
        _sexText = sex;
        [self.undoManager setActionName:@"sex change"];
        [self.undoManager registerUndoWithTarget:self selector:@selector(setSex:) object:oldSex];
        
        
    }
}


- (NSString*)sex
{
    if (_sexText) {
        return _sexText;
    }
    
    NSDictionary *dic = [_documentFileWrapper fileWrappers];
    if (dic) {
        _wrapperSex = [dic objectForKey:sexName];
    }
    if (_wrapperSex) {
        NSData *data = [_wrapperSex regularFileContents];
        _sexText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    
    return _sexText;
}

- (void)setBirthdate:(NSString *)birthdate
{
    if (_birthdateText != birthdate) {
        NSString *old = _birthdateText;
        _birthdateText = birthdate;
        [self.undoManager setActionName:@"Birthdate change"];
        [self.undoManager registerUndoWithTarget:self selector:@selector(setBirthdate:) object:old];
    }
}

- (NSString*)birthdate
{
    if (_birthdateText) {
        return _birthdateText;
    }
    
    NSDictionary *dic = [_documentFileWrapper fileWrappers];
    if (dic) {
        _wrapperBirthdate = [dic objectForKey:birthdateName];
    }
    if (_wrapperBirthdate) {
        NSData *data = [_wrapperBirthdate regularFileContents];
        _birthdateText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }

    return _birthdateText;
}


- (void)setColor:(NSString *)color
{
    if (_colorText != color) {
        NSString *oldColor = _colorText;
        _colorText = color;
        [self.undoManager setActionName:@"color change"];
        [self.undoManager registerUndoWithTarget:self selector:@selector(setColor:) object:oldColor];
    }
}

- (NSString*)color
{
    if (_colorText) {
        return _colorText;
    }
    
    NSDictionary *dic = [_documentFileWrapper fileWrappers];
    if (dic) {
        _wrapperColor = [dic objectForKey:colorName];
    }
    if (_wrapperColor) {
        NSData *data = [_wrapperColor regularFileContents];
        _colorText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    

    return _colorText;
}



- (IBAction)handleUndo:(id)sender {
  [self.undoManager undo];
}

- (IBAction)handleRedo:(id)sender {
  [self.undoManager redo];
}

#pragma mark - File Wrapper/ Package Support

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName
                   error:(NSError *__autoreleasing *)outError {  //14
  
    _fwText = nil;
    _fwLocation = nil;
    _colorText = nil;
    _documentFileWrapper = (NSFileWrapper *)contents;   //15
    
  if ([_delegate respondsToSelector: @selector (documentContentsDidChange:)]) {
    [_delegate documentContentsDidChange: self];    //16
  }
    
  return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {

  if (_documentFileWrapper == nil)             //17
  {
      _documentFileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];  //18
  }

  NSDictionary *fileWrappersDictionary = [_documentFileWrapper fileWrappers];    //19
    
  if (self.documentText != nil)  //20
    
  {
    
    NSData *textData = [self.documentText dataUsingEncoding: kTextFileEncoding];

    NSFileWrapper *textFileWrapper = [fileWrappersDictionary objectForKey:TextFileName];
    if (textFileWrapper != nil) {
      [_documentFileWrapper removeFileWrapper: textFileWrapper];
    }
    textFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:textData];
    [textFileWrapper setPreferredFilename: TextFileName];
    [_documentFileWrapper addFileWrapper: textFileWrapper];
  }
  
  if ( self.documentLocation != nil)  //21
  {
   
    
    NSData *locationData = [self.documentLocation dataUsingEncoding: kTextFileEncoding];
    
    NSFileWrapper *locationFileWrapper = [fileWrappersDictionary objectForKey:LocationFileName];
    if (locationFileWrapper != nil) {
      [_documentFileWrapper removeFileWrapper: locationFileWrapper];
    }
    locationFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:locationData];
    [locationFileWrapper setPreferredFilename: LocationFileName];
    [_documentFileWrapper addFileWrapper: locationFileWrapper];
  }
    
    
    
    if ( self.name != nil)  //22
    {
        
        
        NSData *nameData = [self.name dataUsingEncoding: kTextFileEncoding];
        
        NSFileWrapper *nameFileWrapper = [fileWrappersDictionary objectForKey:nameName];
        if (nameFileWrapper != nil) {
            [_documentFileWrapper removeFileWrapper: nameFileWrapper];
        }
        nameFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:nameData];
        [nameFileWrapper setPreferredFilename: nameName];
        [_documentFileWrapper addFileWrapper: nameFileWrapper];
    }

    if (self.identity != nil)  //23
        
    {
        
        NSData *textData = [self.identity dataUsingEncoding: kTextFileEncoding];
        
        NSFileWrapper *textFileWrapper = [fileWrappersDictionary objectForKey:identityName];
        if (textFileWrapper != nil) {
            [_documentFileWrapper removeFileWrapper: textFileWrapper];
        }
        textFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:textData];
        [textFileWrapper setPreferredFilename: identityName];
        [_documentFileWrapper addFileWrapper: textFileWrapper];
    }
    
    if (self.birthdate != nil)  //24
        
    {
        
        NSData *textData = [self.birthdate dataUsingEncoding: kTextFileEncoding];
        
        NSFileWrapper *textFileWrapper = [fileWrappersDictionary objectForKey:birthdateName];
        if (textFileWrapper != nil) {
            [_documentFileWrapper removeFileWrapper: textFileWrapper];
        }
        textFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:textData];
        [textFileWrapper setPreferredFilename: birthdateName];
        [_documentFileWrapper addFileWrapper: textFileWrapper];
    }
    if (self.sex != nil)  //24
        
    {
        
        NSData *textData = [self.sex dataUsingEncoding: kTextFileEncoding];
        
        NSFileWrapper *textFileWrapper = [fileWrappersDictionary objectForKey:sexName];
        if (textFileWrapper != nil) {
            [_documentFileWrapper removeFileWrapper: textFileWrapper];
        }
        textFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:textData];
        [textFileWrapper setPreferredFilename: sexName];
        [_documentFileWrapper addFileWrapper: textFileWrapper];
    }
    
    
    if (self.color != nil)  //25
        
    {
  
        NSData *textData = [self.color dataUsingEncoding:kTextFileEncoding];
        NSFileWrapper *textFileWrapper = [fileWrappersDictionary objectForKey:colorName];
        if (textFileWrapper != nil) {
            [_documentFileWrapper removeFileWrapper: textFileWrapper];
        }
        textFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:textData];
        [textFileWrapper setPreferredFilename: colorName];
        [_documentFileWrapper addFileWrapper: textFileWrapper];

        
    }
    
    if (self.age != nil)  //25
        
    {
        
        NSData *textData = [self.age dataUsingEncoding: kTextFileEncoding];
        
        NSFileWrapper *textFileWrapper = [fileWrappersDictionary objectForKey:ageName];
        if (textFileWrapper != nil) {
            [_documentFileWrapper removeFileWrapper: textFileWrapper];
        }
        textFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:textData];
        [textFileWrapper setPreferredFilename: ageName];
        [_documentFileWrapper addFileWrapper: textFileWrapper];
    }
  
    return _documentFileWrapper;
}

#pragma mark - Saving

- (void)saveToURL:(NSURL *)url                           //22
   forSaveOperation:(UIDocumentSaveOperation)saveOperation
  completionHandler:(void (^)(BOOL))completionHandler {
  [super saveToURL:url forSaveOperation:saveOperation completionHandler:^(BOOL success) {
    if (success) {                                       //23
      NSLog (@" %s %d", __PRETTY_FUNCTION__, success);
    }
  }];

}

@end
