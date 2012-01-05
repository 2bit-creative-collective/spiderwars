//
//  Playground.h
//  SpiderWars
//
//  Created by Simone Vicentini on 13/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#include "vector"


@interface Playground : CCLayer
{
    @private
    b2World* world;
    GLESDebugDraw* m_debugDraw;
    b2Body* spider;
    b2Body* spiderAnchor;
    b2Body *currentRollingAnchor;
    b2Vec2 prevTouch;
}
@property (nonatomic, retain) NSMutableArray *joints;
@property (nonatomic, retain) NSMutableArray *anchors;
@property (nonatomic, retain) NSMutableArray *webs;

-(void) defineSpider;
-(void) setupBox2DWorld;
-(void) defineStickyBlocks;
-(void) createWebToX: (float32)x andY:(float32)y;
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(b2Vec2)getBox2Dpoint:(CGPoint)point;
-(b2Vec2)getPointFromTouch:(UITouch *)touch;
-(void) resetPlayground;


// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;



@end