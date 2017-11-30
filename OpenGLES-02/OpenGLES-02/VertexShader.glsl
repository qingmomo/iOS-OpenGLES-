attribute vec4 vPosition;

void main(void)
{
    gl_Position = vPosition;
    gl_PointSize = 10.0;
}
