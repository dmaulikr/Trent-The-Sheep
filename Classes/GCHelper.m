//
//  GCHelper.m
//  Perm and Comb
//
//  Created by Matt Bilker on 12/19/11.
//  Copyright (c) 2011 mbilker. All rights reserved.
//

#import "GCHelper.h"
#import "cocos2d.h"

@implementation GCHelper

@synthesize gameCenterAvailable;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer 
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
			// Load player achievements
			[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
				if (error != nil)
				{
					// handle errors
				}
				if (achievements != nil)
				{
					// process array of achievements
					for (GKAchievement* achievement in achievements)
						[achievementsDictionary setObject:achievement forKey:achievement.identifier];
				}
			}];
        }
    }
    return self;
}

- (void)authenticationChanged {    
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;           
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

#pragma mark User functions

- (void)authenticateLocalUser { 
    
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {     
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];        
    } else {
        NSLog(@"Already authenticated!");
    }
}

#pragma mark -
#pragma mark Achievement methods

/**
 * Get an achievement object in the locally stored dictionary
 */
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier
{
	if (gameCenterAvailable)
	{
		GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
		if (achievement == nil)
		{
			achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
			[achievementsDictionary setObject:achievement forKey:achievement.identifier];
		}
		return [[achievement retain] autorelease];
	}
	return nil;
}


/**
 * Send a completion % for a specific achievement to Game Center - increments an existing achievement object
 */
- (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent
{
	if (gameCenterAvailable)
	{
		// Instantiate GKAchievement object for an achievement (set up in iTunes Connect)
		GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
		if (achievement)
		{
			achievement.percentComplete = percent;
			[achievement reportAchievementWithCompletionHandler:^(NSError *error)
			 {
				 if (error != nil)
				 {
					 // Retain the achievement object and try again later
					 [unsentAchievements addObject:achievement];
					 
					 NSLog(@"Error sending achievement!");
				 }
			 }];
		}
	}
}

/**
 * Create a GKAchievementViewController and display it on top of cocos2d's OpenGL view
 */
- (void)showAchievements
{
	if (gameCenterAvailable)
	{
		GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
		if (achievements != nil)
		{
			achievements.achievementDelegate = self;
			
			// Create an additional UIViewController to attach the GKAchievementViewController to
			myViewController = [[UIViewController alloc] init];
            
			// Add the temporary UIViewController to the main OpenGL view
            [[CCDirector sharedDirector] pause];
            [[CCDirector sharedDirector] stopAnimation];
			[[[CCDirector sharedDirector] openGLView] addSubview:myViewController.view];
			
			[myViewController presentModalViewController:achievements animated:YES];
		}
		[achievements release];
	}
}

/**
 * Dismiss an active GKAchievementViewController
 */
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[myViewController dismissModalViewControllerAnimated:YES];
	[myViewController release];
}


@end