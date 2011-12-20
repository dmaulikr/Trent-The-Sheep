//
//  HelloWorldLayer.h
//  Perm and Comb
//
//  Created by mbilker on 12/9/11.
//  Copyright mbilker 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import <Foundation/Foundation.h>

#import "cocos2d.h"

NSUInteger RRFactorial(NSUInteger n);
// Answers the factorial of n, or NSUIntegerMax if factorial exceeds
// NSUInteger type's upper boundary. Uses Foundation framework's NSUInteger
// type to carry factorials.

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor
{
    int _projectilesDestroyed;
	int _maxScore;
	CCLabelTTF *_scoreLabel;
	int _score;
	int _oldScore;
	int _health;
    int _projectileOffScreen;
    CCProgressTimer *_healthBar;
    CCSprite *_player;
    CCSprite *_nextProjectile;
    NSMutableArray *_targets;
    NSMutableArray *_projectiles;
    BOOL openfeintdone;
}

@property (nonatomic, assign) CCLabelTTF *scoreLabel;
@property (nonatomic, retain) CCSprite *nextProjectile;
@property (nonatomic, retain) CCProgressTimer *healthBar;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
