uniform sampler2D ourTexture;

varying lowp vec2 TexCoordOut;

void main()
{
    gl_FragColor = texture2D(ourTexture, TexCoordOut);
}
