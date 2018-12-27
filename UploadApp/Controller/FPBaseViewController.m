//
//  FPBaseViewController.m
//  UploadApp
//
//  Created by 方世沛 on 2018/11/30.
//  Copyright © 2018 方世沛. All rights reserved.
//

#import "FPBaseViewController.h"
#import "FSButton.h"
#import "FSView.h"
#import "FSTextField.h"
#import "Masonry.h"
#import "FSTextFieldCell.h"
#import "FSTexrtActionCell.h"
#import "NSTextField+Past.h"

#import <sys/sysctl.h>
#import <AFNetworking/AFNetworking.h>
@interface FPBaseViewController ()

@property (nonatomic, strong) NSTextView *pathText;

@end
//蒲公英上传文档地址:https://www.pgyer.com/doc/api#uploadApp

#define UPLOADURL @"https://www.pgyer.com/apiv2/app/upload"
//---蒲公英配置---
#define PGY_KEY    @"YOUR KEY"
#define PGY_APIKEY @"YOUR KEY"
#define PGY_APPKEY @"YOUR KEY"
#define UPLOADDIALOG @"YOUR DESCRIPTION" //iOS-V1.1.0-Build9


@implementation FPBaseViewController
{
    FSTextField *panArcField;   //打包路径
    FSTextField *panSaveField;  //保存路径
    FSTextField *schemeField;   //应用scheme 可用xcodebuild -list 查看
    FSTextField *debugField;    //debug或release包
    NSTextField *uploadField;   //打包按钮
    NSTextField *canceldField;  //取消按钮
    
    NSScrollView *logView;
    
    NSMenu *menu;
    NSMenu *contextMenu;
    
    NSTask *task;
    NSPipe *pipe;
    NSFileHandle *readEnd;
    
    NSString *finaPath;
}

//MARK:初始化view

- (void)loadView{
    NSRect frame = [[[NSApplication sharedApplication] mainWindow] frame];
    FSView *view = [[FSView alloc] initWithFrame:frame];
    view.backgroundColor = NSColorFromRGB(0xf5f5f4);
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.layer.backgroundColor = [NSColor blackColor].CGColor;
    [self.view setNeedsDisplay:YES];
    [self configText];
    [self addAction];
    
    menu = [[NSMenu alloc] initWithTitle:@"请选择"];
    contextMenu = [[NSMenu alloc] init];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"debug"
                                                  action:@selector(debugAct)
                                           keyEquivalent:@"abc"];
    NSMenuItem *item1 = [[NSMenuItem alloc] initWithTitle:@"release"
                                                  action:@selector(releaseAct)
                                           keyEquivalent:@"abcd"];
    [contextMenu addItem:item];
    [contextMenu addItem:item1];
    debugField.menu = contextMenu;
    
    
}

//MARK: DEBUG状态

- (void)debugAct {
    debugField.cell.title = @"debug";
}

//MARK: RELEASE状态

- (void)releaseAct {
    debugField.cell.title = @"release";
}

//MARK:添加事件

- (void)addAction {
    [panArcField setTarget:self];
    [panArcField setAction:@selector(arcivePathAct)];
    NSClickGestureRecognizer *click = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(arcivePathAct)];
    [panArcField addGestureRecognizer:click];
    NSClickGestureRecognizer *click1 = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(saveAct)];
    [panSaveField addGestureRecognizer:click1];
    NSClickGestureRecognizer *click2 = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(chooseAct)];
    [debugField addGestureRecognizer:click2];
    NSClickGestureRecognizer *click3 = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(uploadAct)];
    [uploadField addGestureRecognizer:click3];
    
    NSClickGestureRecognizer *click4 = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(cancelAct)];
    [canceldField addGestureRecognizer:click4];
    
}

//MARK:上传事件

- (void)uploadAct {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->uploadField.cell.title = @"正在打包中";
        self->uploadField.enabled = NO;
    });
    NSString *arcPath    = [panArcField.cell.title stringByRemovingPercentEncoding];
    NSString *savPath    = [panSaveField.cell.title stringByRemovingPercentEncoding];
    NSString *scheme     = [schemeField.cell.title stringByRemovingPercentEncoding];
    NSString *debug      = [debugField.cell.title uppercaseString];
    NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"FSUpload" ofType:@"command"];
    finaPath = [NSString stringWithFormat:@"%@%@.ipa",savPath,scheme];
    task = [[NSTask alloc] init];
    [task setLaunchPath:scriptPath];
    [task setTerminationHandler:^(NSTask *ts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->uploadField.cell.title = @"打包";
            self->uploadField.enabled = YES;
        });
        [ts terminate];
        [self upload_pgy];
    }];
    NSMutableArray *arg = [NSMutableArray new];
    [arg addObject:[NSString stringWithFormat:@"%@%@.xcworkspace",arcPath,scheme]];
    [arg addObject:scheme];
    [arg addObject:[NSString stringWithFormat:@"%@build",savPath]];
    [arg addObject:scheme];
    [arg addObject:savPath];
    [arg addObject:debug];
    task.arguments = arg;
    
//    pipe = [[NSPipe alloc] init];
//    readEnd = pipe.fileHandleForReading;
//    [task setStandardOutput:pipe];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(outputAct)
//                                                 name:NSFileHandleDataAvailableNotification
//                                               object:readEnd];
//    [readEnd waitForDataInBackgroundAndNotify];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self->task launch];
        [self->task waitUntilExit];
    });
}

- (void)cancelAct {
    [task terminate];
}

//MARK:输出显示

- (void)outputAct {
    NSData *output = readEnd.availableData;
    NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    NSString *nextOutput = [NSString stringWithFormat:@"%@ \n %@",self.pathText.string,outputString];
    NSRange range = NSMakeRange([nextOutput length], 0);
    self.pathText.string = nextOutput;
    [self.pathText scrollRangeToVisible:range];
    [readEnd waitForDataInBackgroundAndNotify];
}

//MARK:选择要打包的文件路径

- (void)arcivePathAct {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTreatsFilePackagesAsDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSArray *array = [openPanel URLs];
            NSString *p = [[array[0] absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            self->panArcField.cell.title = [p stringByRemovingPercentEncoding];
        }
    }];
}

//MARK: 选择要保存的路径

- (void)saveAct {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTreatsFilePackagesAsDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSArray *array = [openPanel URLs];
            NSString *p = [[array[0] absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            self->panSaveField.cell.title = [p stringByRemovingPercentEncoding];
        }
    }];
}

//MARK: 选择NSMume

- (void)chooseAct {
    NSPoint point = debugField.frame.origin;
    point.y = point.y - 10;
    contextMenu.minimumWidth = debugField.frame.size.width;
    [contextMenu popUpMenuPositioningItem:nil atLocation:point inView:self.view];
}

//MARK: UI

- (void)configText {
    FSTextField *textField1 = [self configFieldWithTitle:@"请选择编译路径"];
    [self.view addSubview:textField1];
    [textField1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(40);
        make.left.equalTo(self.view).offset(15);
        make.width.equalTo(@90);
        make.height.equalTo(@40);
    }];
    
    panArcField = [self configPanelWithTitle:@"请选择路径"];
    [self.view addSubview:panArcField];
    [panArcField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textField1.mas_right).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(textField1);
        make.height.equalTo(@40);
    }];
    
    
    FSTextField *textField2 = [self configFieldWithTitle:@"请选择储存路径"];
    [self.view addSubview:textField2];
    [textField2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField1.mas_bottom).offset(15);
        make.left.equalTo(self.view).offset(15);
        make.width.equalTo(textField1);
        make.height.equalTo(@40);
    }];
    
    panSaveField = [self configPanelWithTitle:@"请选择要保存的路径"];
    [self.view addSubview:panSaveField];
    [panSaveField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textField2.mas_right).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(textField2);
        make.height.equalTo(@40);
    }];
    
    FSTextField *textField3 = [self configFieldWithTitle:@"工程名"];
    [self.view addSubview:textField3];
    [textField3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField2.mas_bottom).offset(15);
        make.left.equalTo(self.view).offset(15);
        make.width.equalTo(textField1);
        make.height.equalTo(@40);
    }];
    
    schemeField = [self configPanelWithTitle:@"请填写工程名"];
    schemeField.editable=YES;
    schemeField.bordered=NO;
    schemeField.wantsLayer = YES;
    schemeField.layer.borderColor = [NSColor whiteColor].CGColor;
    schemeField.layer.borderWidth = 2;
    schemeField.layer.cornerRadius = 0;
    schemeField.drawsBackground=NO;
    [self.view addSubview:schemeField];
    [schemeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textField3.mas_right).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(textField3);
        make.height.equalTo(@30);
    }];
    
    FSTextField *textField4 = [self configFieldWithTitle:@"应用打包模式"];
    [self.view addSubview:textField4];
    [textField4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField3.mas_bottom).offset(15);
        make.left.equalTo(self.view).offset(15);
        make.width.equalTo(textField1);
        make.height.equalTo(@40);
    }];
    
    debugField = [self configCornerWithTitle:@"release"];
    [self.view addSubview:debugField];
    [debugField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textField4.mas_right).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(textField4);
        make.height.equalTo(@30);
    }];
    
    uploadField = [self configCornerWithTitle:@"打包"];
    uploadField.textColor = NSColorFromRGB(0x333333);
    [self.view addSubview:uploadField];
    [uploadField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField4.mas_bottom).offset(30);
        make.centerX.equalTo(self->debugField).offset(-90);
        make.size.equalTo(@(CGSizeMake(150, 44)));
    }];
    
    canceldField = [self configCornerWithTitle:@"取消"];
    canceldField.textColor = NSColorFromRGB(0x333333);
    [self.view addSubview:canceldField];
    [canceldField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField4.mas_bottom).offset(30);
        make.centerX.equalTo(self->debugField).offset(90);
        make.size.equalTo(@(CGSizeMake(150, 44)));
    }];
    
    logView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [logView setBorderType:NSNoBorder];
    [logView setHasVerticalScroller:YES];
    [logView setHasHorizontalScroller:NO];
    logView.backgroundColor = NSColorFromRGB(0xf5f5f4);
    [self.view addSubview:logView];
    [logView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->uploadField.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.bottom.equalTo(self.view).offset(-20);
    }];
    
    self.pathText = [[NSTextView alloc] initWithFrame:NSMakeRect(30, 30, ScreenWidth - 60, 120)];
    self.pathText.string = @"输出结果:";
    self.pathText.textColor = NSColorFromRGB(0x999999);
    self.pathText.alignment = NSTextAlignmentLeft;
    [self.view addSubview:self.pathText];
    
    
    
    self.pathText.maxSize = NSMakeSize(700, 1000000);
    self.pathText.minSize = NSMakeSize(700, 1000);
    [self.pathText setFont:[NSFont fontWithName:@"PingFang-SC-Regular" size:12.0]];
    [logView setDocumentView:self.pathText];
    [self.pathText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self->logView);
        make.height.equalTo(@1000000);
    }];
}

//MARK:UI控件

- (FSTextField *)configFieldWithTitle:(NSString *)title {
    FSTextField *textField = [[FSTextField alloc] initWithFrame:NSMakeRect(30, 30, ScreenWidth - 60, 40)];
    FSTextFieldCell *cell = [[FSTextFieldCell alloc] init];
    cell.font = [NSFont systemFontOfSize:14];
    textField.cell = cell;
    textField.cell.title = title;
    textField.textColor = NSColorFromRGB(0x999999);
    textField.alignment = NSTextAlignmentLeft;
    return textField;
}

- (FSTextField *)configPanelWithTitle:(NSString *)title {
    FSTextField *panArcField = [[FSTextField alloc] initWithFrame:NSMakeRect(30, 30, ScreenWidth - 60, 40)];
    FSTexrtActionCell *panCell = [[FSTexrtActionCell alloc] init];
    panCell.bgColor = NSColor.whiteColor;
    panCell.font = [NSFont systemFontOfSize:14];
    panCell.alignment = NSTextAlignmentCenter;
    panArcField.cell = panCell;
    panCell.title = title;
    panArcField.layer.cornerRadius = 20;
    panArcField.layer.masksToBounds= YES;
    panArcField.textColor = NSColorFromRGB(0x333333);
    return panArcField;
}

- (FSTextField *)configCornerWithTitle:(NSString *)title {
    FSTextField *panArcField = [[FSTextField alloc] initWithFrame:NSMakeRect(30, 30, ScreenWidth - 60, 40)];
    FSTexrtActionCell *panCell = [[FSTexrtActionCell alloc] init];
    panCell.bgColor = NSColorFromRGB(0xf5f5f4);
    panCell.bezeled = YES;
    panCell.font = [NSFont systemFontOfSize:14];
    panCell.alignment = NSTextAlignmentCenter;
    panArcField.cell = panCell;
    panCell.title = title;
    panArcField.layer.cornerRadius = 20;
    panArcField.layer.masksToBounds= YES;
    panArcField.textColor = NSColorFromRGB(0x333333);
    return panArcField;
}

//MARK:上传到蒲公英

- (void)upload_pgy {
    NSData *data = [NSData dataWithContentsOfFile:finaPath];
    if (!data) {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes= [NSSet setWithObjects:@"application/json",@"text/plain",@"text/html", nil];
    NSDictionary *dict = @{@"uKey":PGY_KEY,
                           @"appKey":PGY_APPKEY,
                           @"_api_key":PGY_APIKEY,
                           @"buildInstallType":@(1),
                           @"password":@"",
                           @"buildUpdateDescription":UPLOADDIALOG
                           };
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:UPLOADURL
       parameters:dict
    constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"XKEastEducation.ipa" mimeType:@".ipa"];
        NSLog(@"%@",formData);
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error.userInfo);
    }];
    
}

@end
