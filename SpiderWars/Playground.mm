//
//  Playground.m
//  SpiderWars
//
//  Created by Simone Vicentini on 13/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Playground.h"
#import "SpiderWebDistance.h"
#import "SpiderWebRope.h"
#import "MultiNodeDistanceRope.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32
#define ptm(__x__) (__x__/PTM_RATIO)



@implementation Playground

@synthesize joints;
@synthesize anchors;
@synthesize webs;

- (id)init {
    self = [super init];
    if (self) {
        self.isTouchEnabled = YES;
        [self setJoints:[NSMutableArray array]];
        [self setAnchors:[NSMutableArray array]];        
        [self setWebs:[NSMutableArray array]];
        [self setupBox2DWorld];
        [self defineStickyBlocks];
        [self defineSpider];
        [self schedule: @selector(tick:)];
        
    }
    return self;
}





- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    b2Vec2 t =  [self getPointFromTouch:touch];

//    for (NSValue* b in [self anchors]) 
//    {
//        b2Body *temp = (b2Body *)[b pointerValue];
//        if (temp->GetFixtureList()->TestPoint(t))
//        {
//            currentRollingAnchor = temp;
//            break;
//        }
//    }

    prevTouch = t;
    
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (currentRollingAnchor == Nil)
        return;
    
    UITouch *touch = [touches anyObject];
    b2Vec2 currentV = [self getPointFromTouch:touch];
    
    NSLog(@"-----");
    float oppositeOverAdjacent = (currentRollingAnchor->GetPosition().y - prevTouch.y) / (currentRollingAnchor->GetPosition().x - prevTouch.x);
    
    NSLog(@" %f", oppositeOverAdjacent);

    float angle = atan(oppositeOverAdjacent);
    if (prevTouch.x < currentRollingAnchor->GetPosition().x)
    {
        angle = M_PI + angle;
    }
    oppositeOverAdjacent = (currentRollingAnchor->GetPosition().y - currentV.y) / 
    (currentRollingAnchor->GetPosition().x - currentV.x);
    
    float angle1 = atan(oppositeOverAdjacent);
    if (currentV.x < currentRollingAnchor->GetPosition().x)
    {
        angle1 = M_PI + angle1;
    }
    NSLog(@"current Angle %f", currentRollingAnchor->GetAngle());
    
    currentRollingAnchor->SetTransform(currentRollingAnchor->GetPosition(), currentRollingAnchor->GetAngle() + (angle1 -  angle));
    
    NSLog(@" %f", oppositeOverAdjacent);
    NSLog(@"angle1 %f angle %f", angle1, angle);
    
    prevTouch = currentV;
    
    
    //need to change the length of the joint!!! 
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

        UITouch *touch = [touches anyObject];
        b2Vec2 t =  [self getPointFromTouch:touch];
        [self createWebToX: t.x andY:t.y];
        //in your touchesEnded event, you would want to see if you touched
        //down and then up inside the same place, and do your logic there.
    currentRollingAnchor = Nil;
}


-(void) defineSpider
{
    // Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
    
    bodyDef.type = b2_dynamicBody;
    
	bodyDef.position.Set(ptm(200), ptm(500));
    
    
    
	spider = world->CreateBody(&bodyDef);
	
    
    b2CircleShape circleAnchor;
    circleAnchor.m_p = b2Vec2(0,0);
    circleAnchor.m_radius = 0.5f;

	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circleAnchor;	
	fixtureDef.density = 2.0f;
	fixtureDef.friction = 0.0f;
	spider->CreateFixture(&fixtureDef);
    spider->SetLinearDamping(0.1f);
    
    
    //    // Define another box shape for our dynamic body.
//	b2PolygonShape dynamicBox2;
//	dynamicBox2.SetAsBox(.5f, .5f, b2Vec2(0.0f, -4.0f), 0.0f);
//	// Define the dynamic body fixture.
//	b2FixtureDef fixtureDef2;
//	fixtureDef2.shape = &dynamicBox2;	
//	fixtureDef2.density = 1.0f;
//	fixtureDef2.friction = 0.0f;
//    
//	spider->CreateFixture(&fixtureDef2);
    
    
    
    
    //anchor
    [self resetPlayground];
    
    
    //buttons
    CCMenuItemImage* swingSpiderButton = [CCMenuItemImage itemFromNormalImage:@"Icon-72.png"
                                                              selectedImage: @"Icon-72.png"
                                                                     target:self
                                                                   selector:@selector(resetPlayground)];
    
    

    
    
    

    
    
    // Create a menu and add your menu items to it
    CCMenu * myMenu = [CCMenu menuWithItems:swingSpiderButton, nil];
    
    // Arrange the menu items vertically
    [myMenu alignItemsHorizontally];
    [myMenu setPosition:ccp(400, 30)];
    // add the menu to your scene
    [self addChild:myMenu];


    
    
    
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(7,4);

    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    b2Body *ground = world->CreateBody(&groundBodyDef);
    
    // Define another box shape for our dynamic body.
	b2PolygonShape box;
	box.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef boxDef;
	boxDef.shape = &box;	
	boxDef.density = 1.0f;
	boxDef.friction = 1.0f;
    boxDef.restitution = 0.2f;
	ground->CreateFixture(&boxDef);
    
    
}

-(void) resetPlayground
{
    spider->SetTransform(b2Vec2(ptm(200), ptm(500)), 0.0f);
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    b2Vec2 touch = b2Vec2(ptm(400), ptm(screenSize.height) - 1.0f);
    
    while ([[self webs] count] > 0)
    {
        [[self webs] removeLastObject];
    }

    [self createWebToX:ptm(touch.x) andY:touch.y];
}

-(b2Vec2)getPointFromTouch:(UITouch *)touch
{
    
    return [self getBox2Dpoint:[self convertTouchToNodeSpace:touch]]; 
}

-(b2Vec2)getBox2Dpoint:(CGPoint)point
{
    
    return b2Vec2(ptm(point.x), ptm(point.y));
}

-(void) createWebToX: (float32)x andY:(float32)y
{

//    if ([[self joints] count] == 2)
//    {
//        world->DestroyJoint((b2Joint *)[[[self joints] lastObject] pointerValue]);
//        [[self joints] removeLastObject];
//        world->DestroyBody((b2Body *)[[[self anchors] lastObject] pointerValue]);
//        
//        [[self anchors] removeLastObject];
//        
//    }
    if ([[self webs] count] == 2)
    {
        [[self webs] removeLastObject];
    }
        
    
    
//    double angle = 0.0f;
//    @try {
//        float oppositeOverAdjacent = (spider->GetPosition().x - spiderAnchor->GetPosition().x) / 
//        -(spider->GetPosition().y - spiderAnchor->GetPosition().y);
//        
//        angle = atan(oppositeOverAdjacent);
//        
//        
//    }
//    @catch (NSException *exception) {
//        angle = 0.0f;
//        NSLog(@"crap ");
//    }
    
    
    spider->SetFixedRotation(true);
    
    id<SpiderWeb> web = [MultiNodeDistanceRope createWebWithAnchorAt:b2Vec2(x, y) andAnchoredBody:spider inWorld:world];
    
       
//    [[self joints] insertObject:[NSValue valueWithPointer:web] atIndex:0];
//    [[self anchors] insertObject:[NSValue valueWithPointer:anchor] atIndex:0];

    [[self webs] insertObject:web atIndex:0];
    
//    web->SetFrequency(20.0f);
//    web->SetDampingRatio(1.0f);
    
    
//    web->SetDampingRatio(10.0f);
    
//    b2RevoluteJointDef *fjd = new b2RevoluteJointDef();
//    fjd->Initialize(spiderAnchor, spider, spiderAnchor->GetWorldCenter());
//    fjd->enableMotor = true;
//    fjd->motorSpeed = 0.0f;
//    fjd->maxMotorTorque = 1.0f;
//    world->CreateJoint(fjd);
    
    
}


-(void) swingSpider
{

    
    
    short direction = 1;
    if (spider->GetLinearVelocity().x < 0)
          direction = -1;
    spider->ApplyForceToCenter(b2Vec2(20 * direction,0));
    

}

-(void) setupBox2DWorld
{
    // Define the gravity vector.
    b2Vec2 gravity;
    gravity.Set(0.0f, -50.8f);
    
    
    // Construct a world object, which will hold and simulate the rigid bodies.
    world = new b2World(gravity);
    
    world->SetContinuousPhysics(false);
    
    // Debug Draw functions
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
    //		flags += b2DebugDraw::e_aabbBit;
    //		flags += b2DebugDraw::e_pairBit;
    //		flags += b2DebugDraw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);		

}

-(void) defineStickyBlocks
{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(ptm(screenSize.width) * .5f, ptm(screenSize.height) - .5f); // top-left corner
    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    b2Body* groundBody = world->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2PolygonShape groundBox;		
    
    b2Vec2 vertices[4];
    vertices[0] = b2Vec2(-ptm(screenSize.width) * .5f, -.5f);
    vertices[1] = b2Vec2(ptm(screenSize.width) * .5f,-.5f);
    vertices[2] = b2Vec2(ptm(screenSize.width) * .5f,.5f);
    vertices[3] = b2Vec2(-ptm(screenSize.width) * .5f,.5f);
    
    groundBox.Set(vertices, sizeof(vertices) / sizeof(vertices[0]) );
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &groundBox;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    groundBody->CreateFixture(&fixtureDef);

    
    
}

-(void) tick:(ccTime)dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
    
    
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Playground *layer = [Playground node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)dealloc {
    
    delete world;
    world = NULL;
    [self setWebs:Nil];
    [self setJoints:Nil];
    [self setAnchors:Nil]; 
    [super dealloc];
}
@end
