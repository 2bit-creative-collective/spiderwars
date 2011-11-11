//
//  HelloWorldLayer.h
//  SpiderWars
//
//  Created by Simone Vicentini on 10/11/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "VRope.h"


// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    b2World* world;
    GLESDebugDraw *m_debugDraw;
    b2Body* anchorBody; //reference to anchor body
    CCSpriteBatchNode* ropeSpriteSheet; //sprite sheet for rope segment
    NSMutableArray* vRopes; //array to hold rope references
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
// adds a new sprite at a given coordinate
-(b2Body *) addNewSpriteWithCoordsPoint:(CGPoint)p;
-(b2Body *) addNewSpriteWithCoordsPoint:(CGPoint)p Dynamic:(BOOL)d;
-(b2Body *) addNewSpriteWithCoordsPoint:(CGPoint)p anchoredTo:(b2Body *)b;



@end
