//
//  MyGLView.m
//  OpenGLES-01
//
//  Created by 黎仕仪 on 17/11/3.
//  Copyright © 2017年 shiyi.Li. All rights reserved.
//

#import "MyGLView.h"
#import "GLESUtils.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>

@interface MyGLView ()
{
    CAEAGLLayer *_eaglLayer;  //OpenGL内容只会在此类layer上描绘
    EAGLContext *_context;    //OpenGL渲染上下文
    GLuint _renderBuffer;     //
    GLuint _frameBuffer;      //
    GLuint _depthBuffer;      //深度缓存

    GLuint _programHandle;
    GLuint _positionSlot; //顶点槽位
    GLuint _colorSlot;   //颜色槽位
    
    //新加
    GLKMatrix4 _projectionMatrix;
    GLKMatrix4 _modelViewMatrix;
    GLuint _projectionSlot;
    GLuint _modelViewSlot;
    
    //新加手势
    UIPanGestureRecognizer *_panGesture;      //平移
    UIPinchGestureRecognizer *_pinchGesture;  //缩放
    UIRotationGestureRecognizer *_rotationGesture; //旋转
    
    //新加变换数值变量
    float TX,TY,TZ;   //平移
    float RX,RY,RZ;   //旋转
    float S_XYZ;      //缩放

}

@end

@implementation MyGLView

+(Class)layerClass{
    //OpenGL内容只会在此类layer上描绘
    return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        //赋值
        TX = 0; TY = 0; TZ = -6;
        RX = 0, RY = 0; RZ = 0;
        S_XYZ = 1;
        
        //实例化手势
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewTranslate:)];
        [self addGestureRecognizer:_panGesture];
        
        _pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(viewZoom:)];
        [self addGestureRecognizer:_pinchGesture];
        
        _rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(viewRotation:)];
        [self addGestureRecognizer:_rotationGesture];
        
        [self setupLayer];
        [self setupContext];
        
        [self setupDepthBuffer];   //新加
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupProgram];  //配置program
        
        [self setupProjectionMatrix];
        [self setupModelViewMatrix];
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

-(void)setupDepthBuffer{
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
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
    //将depthBuffer跟framebuffer进行绑定
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
}

- (void)setupProgram
{
    // Load shaders
    //
    NSString * vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader"
                                                                  ofType:@"glsl"];
    NSString * fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader"
                                                                    ofType:@"glsl"];
    GLuint vertexShader = [GLESUtils loadShader:GL_VERTEX_SHADER
                                   withFilepath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadShader:GL_FRAGMENT_SHADER
                                     withFilepath:fragmentShaderPath];
    
    // Create program, attach shaders.
    _programHandle = glCreateProgram();
    if (!_programHandle) {
        NSLog(@"Failed to create program.");
        return;
    }
    
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    
    // Link program
    //
    glLinkProgram(_programHandle);
    
    // Check the link status
    GLint linked;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linked );
    if (!linked)
    {
        GLint infoLen = 0;
        glGetProgramiv (_programHandle, GL_INFO_LOG_LENGTH, &infoLen );
        
        if (infoLen > 1)
        {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog (_programHandle, infoLen, NULL, infoLog );
            NSLog(@"Error linking program:\n%s\n", infoLog );
            
            free (infoLog );
        }
        
        glDeleteProgram(_programHandle);
        _programHandle = 0;
        return;
    }
    
    glUseProgram(_programHandle);
    
    // Get attribute slot from program
    //
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _colorSlot    = glGetAttribLocation(_programHandle, "vSourceColor");
    //新加
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
}

-(void)setupProjectionMatrix{
    float aspect = self.frame.size.width/self.frame.size.height;
    _projectionMatrix = GLKMatrix4MakePerspective(45.0*M_PI/180.0, aspect, 0.1, 100);
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, _projectionMatrix.m);
}

-(void)setupModelViewMatrix{
    _modelViewMatrix = GLKMatrix4Identity;   //初始矩阵   单位矩阵
    _modelViewMatrix = GLKMatrix4MakeTranslation(TX, TY, TZ); //平移
    _modelViewMatrix = GLKMatrix4RotateX(_modelViewMatrix, RX);  //旋转
    _modelViewMatrix = GLKMatrix4RotateY(_modelViewMatrix, RY);
    _modelViewMatrix = GLKMatrix4RotateZ(_modelViewMatrix, RZ);
    _modelViewMatrix = GLKMatrix4Scale(_modelViewMatrix, S_XYZ, S_XYZ, S_XYZ);  //缩放
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, _modelViewMatrix.m);
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
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);  //添加
    
    // Setup viewport
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.5f, 1.0, 0.0, 0.0, 1.0,     // red
        -0.5f, 0.5f, 0.5f, 1.0, 1.0, 0.0, 1.0,      // yellow
        0.5f, 0.5f, 0.5f, 0.0, 0.0, 1.0, 1.0,       // blue
        0.5f, -0.5f, 0.5f, 1.0, 1.0, 1.0, 1.0,      // white
        
        0.5f, -0.5f, -0.5f, 1.0, 1.0, 0.0, 1.0,     // yellow
        0.5f, 0.5f, -0.5f, 1.0, 0.0, 0.0, 1.0,      // red
        -0.5f, 0.5f, -0.5f, 1.0, 1.0, 1.0, 1.0,     // white
        -0.5f, -0.5f, -0.5f, 0.0, 0.0, 1.0, 1.0,    // blue
    };

//    GLfloat vertices[] = {
//        -0.5f, -0.5f, 0.5f,
//        -0.5f, 0.5f, 0.5f,
//        0.5f, 0.5f, 0.5f,
//        0.5f, -0.5f, 0.5f,
//        
//        0.5f, -0.5f, -0.5f,
//        0.5f, 0.5f, -0.5f,
//        -0.5f, 0.5f, -0.5f,
//        -0.5f, -0.5f, -0.5f,
//    };
    
    GLubyte indices[] = {
        // Front face
        0, 3, 2, 0, 2, 1,
        
        // Back face
        7, 5, 4, 7, 6, 5,
        
        // Left face
        0, 1, 6, 0, 6, 7,
        
        // Right face
        3, 4, 5, 3, 5, 2,
        
        // Up face
        1, 2, 5, 1, 5, 6,
        
        // Down face
        0, 7, 4, 0, 4, 3
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices+3);
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
     
    
    [_context presentRenderbuffer:_renderBuffer];
}

-(void)viewTranslate:(UIPanGestureRecognizer *)panGesture{
    CGPoint transPoint = [panGesture translationInView:self];
    float x = transPoint.x / self.frame.size.width;
    float y = transPoint.y / self.frame.size.height;
    TX += x;
    TY -= y;

    TZ += 0.0;
    
    [self updateTransform];
    [panGesture setTranslation:CGPointMake(0, 0) inView:self];
}

-(void)viewRotation:(UIRotationGestureRecognizer *)rotationGesture{
    float rotate = rotationGesture.rotation;
    RX += rotate/2.0;
    RY += rotate/3.0;
    RZ += rotate;
    
    [self updateTransform];
    rotationGesture.rotation = 0;
}

-(void)viewZoom:(UIPinchGestureRecognizer *)pinchGesture{
    float scale = pinchGesture.scale;
    
    S_XYZ *= scale;

    [self updateTransform];
    pinchGesture.scale = 1.0;
}

-(void)updateTransform{
    [self setupProjectionMatrix];
    [self setupModelViewMatrix];
    [self render];
}


@end
