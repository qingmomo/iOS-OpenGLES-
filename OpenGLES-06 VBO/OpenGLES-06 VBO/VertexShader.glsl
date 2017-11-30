uniform mat4 projection;  //新加
uniform mat4 modelView;   //新加

attribute vec4 vPosition;

attribute vec4 vSourceColor;
varying vec4 vDestinationColor;

void main(void)
{
    gl_Position = projection * modelView * vPosition; //新加
    vDestinationColor = vSourceColor;
}
