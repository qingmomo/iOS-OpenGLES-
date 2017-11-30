//
//  TextureManager.m
//  LearnOpenGLES
//
//  Created by aj on 2017/3/8.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import "TextureManager.h"
#import <OpenGLES/ES3/gl.h>

@implementation TextureManager

/*
 *  通过UIImage的方式获取纹理对象
 */
+ (GLuint)getTextureImage:(UIImage *)image {
    
    // 获取UIImage并转换成CGImage
    CGImageRef spriteImage = image.CGImage;
    
    if(!spriteImage) {
        return 0;
    }
    
    // 获取图片的大小
    GLsizei width  = (GLsizei)CGImageGetWidth(spriteImage);
    GLsizei height = (GLsizei)CGImageGetHeight(spriteImage);
    
    
    // 分配内存，并初始化该内存空间为零, 因为一个像素有4个通道(RGBA)所以乘4
    GLubyte * spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    
    /*
     *  创建位图上下文
     */
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 在上下文中绘制图片
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    // 释放上下文
    CGContextRelease(spriteContext);
    
    // 创建纹理对象并且绑定, 纹理对象用无符号整数表示, 这个纹理对象相当于我们在C语言文件操作里面的句柄
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    //设置纹理循环模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    //设置纹理过滤模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 加载图像数据, 并上传纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    // 解绑纹理对象(在本文这里解不解绑都一样，因为后面还是要绑定)
    glBindTexture(GL_TEXTURE_2D, 0);
    // 释放分配的内存空间
    free(spriteData);
    
    return texName;
}



@end
