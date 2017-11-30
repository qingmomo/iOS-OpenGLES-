attribute vec4 vPosition;

attribute vec4 vSourceColor;      //新加
varying vec4 vDestinationColor;   //新加

void main(void)
{
    gl_Position = vPosition;
    vDestinationColor = vSourceColor; //新加
}
