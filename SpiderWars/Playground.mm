//
//  Playground.m
//  SpiderWars
//
//  Created by Simone Vicentini on 13/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Playground.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32


@implementation Playground
- (id)init {
    self = [super init];
    if (self) {
        [self performSelector:@selector(setupBox2DWorld)];
        [self performSelector:@selector(defineStickyBlocks)];
        [self performSelector:@selector(defineSpider)];
        [self schedule: @selector(tick:)];
        //
    }
    return self;
}


-(void) defineSpider
{
    // Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
    
    bodyDef.type = b2_dynamicBody;
    
	bodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);

    
    
	spider = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 1.0f;
	spider->CreateFixture(&fixtureDef);
    
    
    
    //anchor
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    b2BodyDef spiderAnchorDef;
    
    
	spiderAnchorDef.position.Set(100/PTM_RATIO, screenSize.height / PTM_RATIO - 1.0f);
    
    
    
	spiderAnchor = world->CreateBody(&spiderAnchorDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox1;
	dynamicBox1.SetAsBox(.1f, .1f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef1;
	fixtureDef1.shape = &dynamicBox1;	
	fixtureDef1.density = 1.0f;
	fixtureDef1.friction = 1.0f;
	spiderAnchor->CreateFixture(&fixtureDef1);
    
    
    // +++ Create box2d joint
    b2RopeJointDef jd;
    jd.bodyA = spiderAnchor; //define bodies
    jd.bodyB = spider;
    jd.localAnchorA = b2Vec2(0,0);
    jd.localAnchorB = b2Vec2(0,0);
    jd.collideConnected = true;
    
    
    
    
    
    
    jd.maxLength= (spider->GetPosition() - spiderAnchor->GetPosition()).Length(); //define max length of joint = current distance between bodies
    web = world->CreateJoint(&jd); //create joint
    
    
    //buttons
    CCMenuItemImage* swingSpiderButton = [CCMenuItemImage itemFromNormalImage:@"Icon-72.png"
                                                              selectedImage: @"Icon-72.png"
                                                                     target:self
                                                                   selector:@selector(swingSpider)];
    
    
    CCMenuItemImage* webButton = [CCMenuItemImage itemFromNormalImage:@"Icon-72.png"
                                                                selectedImage: @"Icon-72.png"
                                                                       target:self
                                                                     selector:@selector(createWeb)];
    
    
    

    
    
    // Create a menu and add your menu items to it
    CCMenu * myMenu = [CCMenu menuWithItems:swingSpiderButton, webButton, nil];
    
    // Arrange the menu items vertically
    [myMenu alignItemsHorizontally];
    [myMenu setPosition:ccp(400, 30)];
    // add the menu to your scene
    [self addChild:myMenu];

}

-(void) createWeb
{
    if (web != nil)
    {
        world->DestroyJoint(web);
        web = nil;
        return;
    }
    
    spiderAnchor->SetTransform(b2Vec2(spider->GetWorldCenter().x, spiderAnchor->GetWorldCenter().y), spiderAnchor->GetAngle());
    
    // +++ Create box2d joint
    b2RopeJointDef jd;
    jd.bodyA = spiderAnchor; //define bodies
    jd.bodyB = spider;
    jd.localAnchorA = b2Vec2(0,0);
    jd.localAnchorB = b2Vec2(0,0);
    jd.collideConnected = true;
    
    
    
    
    
    
    jd.maxLength= (spider->GetPosition() - spiderAnchor->GetPosition()).Length(); //define max length of joint = current distance between bodies
    web = world->CreateJoint(&jd); //create joint
    
    
}


-(void) swingSpider
{

    spider->ApplyForceToCenter(b2Vec2(50,0));
    
}

-(void) setupBox2DWorld
{
    // Define the gravity vector.
    b2Vec2 gravity;
    gravity.Set(0.0f, -9.8f);
    
    
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
    groundBodyDef.position.Set(screenSize.width / PTM_RATIO * .5f,screenSize.height / PTM_RATIO - .5f); // top-left corner
    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    b2Body* groundBody = world->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2PolygonShape groundBox;		
    
    b2Vec2 vertices[4];
    vertices[0] = b2Vec2(-screenSize.width / PTM_RATIO * .5f, -.5f);
    vertices[1] = b2Vec2(screenSize.width / PTM_RATIO * .5f,-.5f);
    vertices[2] = b2Vec2(screenSize.width / PTM_RATIO * .5f,.5f);
    vertices[3] = b2Vec2(-screenSize.width / PTM_RATIO * .5f,.5f);
    
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
@end
