//
//  MyGLView.m
//  OpenGLES-01
//
//  Created by 黎仕仪 on 17/11/3.
//  Copyright © 2017年 shiyi.Li. All rights reserved.
//

#import "MyGLView.h"
#import <OpenGLES/ES3/gl.h>

@interface MyGLView ()
{
    CAEAGLLayer *_eaglLayer;  //OpenGL内容只会在此类layer上描绘
    EAGLContext *_context;    //OpenGL渲染上下文
    GLuint _renderBuffer;     //
    GLuint _frameBuffer;      //

}

@end

@implementation MyGLView

+(Class)layerClass{
    //OpenGL内容只会在此类layer上描绘
    return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self render];
    }
    
    return self;
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见,性能最好
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    // 指定 OpenGLES 渲染API的版本，在这里我们使用OpenGLES 3.0，由于3.0兼容2.0并且功能更强，为何不用更好的呢
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 3.0 context");
    }
    
    // 设置为当前上下文
    [EAGLContext setCurrentContext:_context];
}

-(void)setupRenderBuffer{
    glGenRenderbuffers(1, &_renderBuffer); //生成和绑定render buffer的API函数
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    //为其分配空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

-(void)setupFrameBuffer{
    glGenFramebuffers(1, &_frameBuffer);   //生成和绑定frame buffer的API函数
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //将renderbuffer跟framebuffer进行绑定
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

-(void)render
{
    //设置清屏颜色,默认是黑色，如果你的运行结果是黑色，问题就可能在这儿
    glClearColor(0.3, 0.5, 0.8, 1.0);
    /*
    glClear指定清除的buffer
    共可设置三个选项GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT
    也可组合如:glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    这里我们只用了color buffer，所以只需清除GL_COLOR_BUFFER_BIT
     */
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_context presentRenderbuffer:_renderBuffer];
}

@end
