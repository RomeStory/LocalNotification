//
//  LocalNotificationCenter.m
//  LocalNotification
//
//  Created by zhangzhenyun on 2018/7/30.
//  Copyright © 2018年 Beijing Youjiu Network. All rights reserved.
//

#import "LocalNotificationCenter.h"

static LocalNotificationCenter *localNoti;

@implementation LocalNotificationCenter
+ (instancetype)sharedCenter {
    if (localNoti == nil) {
        localNoti = [[LocalNotificationCenter alloc] init];
    }
    return localNoti;
}
- (instancetype)init {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self checkIsGranted];
            [self addNotification];
        });
    }
    return self;
}
/**添加通知*/
- (void)addNotiWithTitle:(NSString *)title body:(NSString *)body {
    if (@available(iOS 10.0, *)) {
        [self laterIos10AddNotiWithTitle:title body:body];
    } else {
        [self beforeIos10AddNotiWithTitle:title body:body];
    }
}
/**设置app角标*/
- (void)setApplicationBadgeNum:(NSInteger)num {
    [UIApplication sharedApplication].applicationIconBadgeNumber = num;
}

//MARK: ios10之后通知方式
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
/**注册通知*/
- (void)laterIos10RegisterNoti {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNAuthorizationOptions option = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
    __weak LocalNotificationCenter *wSelf = self;
    [center requestAuthorizationWithOptions:option completionHandler:^(BOOL granted, NSError * _Nullable error) {
        wSelf.isGranted = granted;
    }];
}
/**向center添加通知*/
- (void)laterIos10AddNotiWithTitle:(NSString *)title body:(NSString *)body {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.subtitle = @"";
    content.body = body;
    content.sound = [UNNotificationSound defaultSound];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"messageIdentifier" content:content trigger:nil];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}
/**通知将出现*/
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    UNNotificationTrigger *triger = notification.request.trigger;
    if ([triger isKindOfClass:[UNPushNotificationTrigger class]]) {//远程推送
        
    } else {//通知
        
    }
    //不显示通知
    //    completionHandler(UNNotificationPresentationOptionNone);
    //显示通知
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}
/**点击通知*/
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
}
#pragma clang diagnostic pop


//MARK:ios 10通知方式
- (void)beforerIos10RegisterNoti {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
        
    } else {
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:type categories:nil]];
    }
}
- (void)beforeIos10AddNotiWithTitle:(NSString *)title body:(NSString *)body {
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    noti.fireDate = fireDate;
    noti.timeZone = [NSTimeZone localTimeZone];
    noti.alertTitle = title;
    noti.alertBody = body;
    noti.alertLaunchImage = @"launch";
    noti.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
}

#pragma mark - 添加app进入前台的通知
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIsGranted) name:UIApplicationWillEnterForegroundNotification object:nil];
}
#pragma mark - 检查APP通知的开关是否打开
- (void)checkIsGranted {
    __weak LocalNotificationCenter *wSelf = self;
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            UNAuthorizationStatus status = settings.authorizationStatus;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == UNAuthorizationStatusAuthorized) {
                    wSelf.isGranted = YES;
                } else {
                    wSelf.isGranted = NO;
                }
            });
        }];
    } else {
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
            dispatch_async(dispatch_get_main_queue(), ^{
                wSelf.isGranted = YES;
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                wSelf.isGranted = NO;
            });
        }
    }
}
@end
