attribute vec4 vPosition;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

void main(void)
{
    gl_Position = vPosition; 
//    TexCoordOut = TexCoordIn;
    TexCoordOut = vec2(TexCoordIn.x, 1.0-TexCoordIn.y);
}
