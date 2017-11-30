precision mediump float;

varying vec4 vDestinationColor;   //新加

void main()
{
    gl_FragColor = vDestinationColor;  //修改
}
