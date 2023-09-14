/**
 * Pacman-x86: a Pacman implementation in pure x86 assembly.
 * @file The game's debug functions.
 * @author Rodrigo Siqueira <rodriados@gmail.com>
 * @copyright 2021-present Rodrigo Siqueira
 */
#include <time.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

/**
 * Retrieves the current time since UNIX epoch.
 * @return The current time.
 */
extern uint64_t getTime()
{
    struct timespec t;
    timespec_get(&t, TIME_UTC);
    return (t.tv_sec * 1000L) + (t.tv_nsec / 1000000L);
}

/**
 * Calculates the game's frame rate based on this function's last call.
 * @return The game's current frame rate.
 */
extern double getFrameRate()
{
    static uint64_t lastFrameTime = 0;

    uint64_t previousTime = lastFrameTime;
    uint64_t currentTime = lastFrameTime = getTime();
    double elapsedTime = currentTime - previousTime;
    return (double) 1000.0f / elapsedTime;
}

double x1 = 0, y1 = 0;
double deltaX = 0.0, deltaY = 0.0;

extern void logArrowUpPress()
{
    deltaX = 0;
    deltaY = -.1;
}

extern void logArrowDownPress()
{
    deltaX = 0;
    deltaY = +.1;
}

extern void logArrowLeftPress()
{
    deltaX = -.1;
    deltaY = 0;
}

extern void logArrowRightPress()
{
    deltaX = +.1;
    deltaY = 0;
}

extern void logSpacePress()
{
    deltaX = 0;
    deltaY = 0;
}

float angle = 0.0;
bool loaded = false;
GLuint textureID = 0;

unsigned uint_big_endianness(unsigned char bytes[4])
{
    return bytes[3] | (bytes[2] << 8) | (bytes[1] << 16) | (bytes[0] << 24);
}

// GLuint loadTexture(const char *filename)
// {
//     FILE *file = fopen(filename, "rb");

//     unsigned char bytes[4];
//     unsigned int height, width;

//     fread(bytes, 4, sizeof(unsigned char), file);
//     height = uint_big_endianness(bytes);

//     fread(bytes, 4, sizeof(unsigned char), file);
//     width = uint_big_endianness(bytes);

//     unsigned int imageSize = height * width * 4;

//     unsigned char *image = (unsigned char*) malloc(imageSize * sizeof(unsigned char));

//     fread(image, imageSize, sizeof(unsigned char), file);

//     fclose(file);

//     GLuint texture;
//     glGenTextures(1, &texture);
//     glBindTexture(GL_TEXTURE_2D, texture);
//     glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
//     glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, image);
//     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
//     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

//     loaded = true;

//     return texture;

//     // const unsigned char data[] = {
//     //   255, 0,   0,   0, 255,   0,
//     //     0, 0, 255, 255, 255, 255
//     // };

//     // const GLsizei GLwidth = 2;
//     // const GLsizei GLheight = 2;

//     // glGenTextures(1, &textureID);
//     // glBindTexture(GL_TEXTURE_2D, textureID);
//     // glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
//     // glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, GLwidth, GLheight, 0, GL_BGR, GL_UNSIGNED_BYTE, data);
//     // glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
//     // glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
//     // glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP);
//     // glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP);

//     // loaded = true;

//     // return textureID;
// }

extern void testScene()
{
    // if (!loaded) {
    //     textureID = loadTexture("resources/pacman.bin");
    // }

    // glMatrixMode(GL_PROJECTION);
    // glLoadIdentity();

    // glOrtho(-2, 2, -2, 2, 2, -2);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    double halfside = .1 / 2.0;

    glColor3d(0,0,1.f);
    glBegin(GL_POLYGON);

    glVertex2d(x1 + halfside, y1 + halfside);
    glVertex2d(x1 + halfside, y1 - halfside);
    glVertex2d(x1 - halfside, y1 - halfside);
    glVertex2d(x1 - halfside, y1 + halfside);

    x1 += deltaX * 5;
    y1 += deltaY * 5;

    glEnd();

    // glEnable(GL_TEXTURE_2D);
    // glBindTexture(GL_TEXTURE_2D, textureID);
    // glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

    // glBegin(GL_QUADS);
    //     glTexCoord2f( 0, 0 );
    //     glVertex2i( -1, -1 );
    //     glTexCoord2f( 1, 0 );
    //     glVertex2i(  1, -1 );
    //     glTexCoord2f( 1, 1 );
    //     glVertex2i(  1,  1 );
    //     glTexCoord2f( 0, 1 );
    //     glVertex2i( -1,  1 );
    // glEnd();

   // glMatrixMode(GL_MODELVIEW);
   // glLoadIdentity();
 
   // glPushMatrix();
   // glTranslatef(-0.5f, 0.4f, 0.0f);
   // glRotatef(angle, 0.0f, 0.0f, 1.0f);
   // glBegin(GL_QUADS);
   //    glColor3f(1.0f, 0.0f, 0.0f);
   //    glVertex2f(-0.3f, -0.3f);
   //    glVertex2f( 0.3f, -0.3f);
   //    glVertex2f( 0.3f,  0.3f);
   //    glVertex2f(-0.3f,  0.3f);
   // glEnd();
   // glPopMatrix();
 
   // glPushMatrix();
   // glTranslatef(-0.4f, -0.3f, 0.0f);
   // glRotatef(angle, 0.0f, 0.0f, 1.0f);
   // glBegin(GL_QUADS);
   //    glColor3f(0.0f, 1.0f, 0.0f);
   //    glVertex2f(-0.3f, -0.3f);
   //    glVertex2f( 0.3f, -0.3f);
   //    glVertex2f( 0.3f,  0.3f);
   //    glVertex2f(-0.3f,  0.3f);
   // glEnd();
   // glPopMatrix();
 
   // glPushMatrix();
   // glTranslatef(-0.7f, -0.5f, 0.0f);
   // glRotatef(angle, 0.0f, 0.0f, 1.0f);
   // glBegin(GL_QUADS);
   //    glColor3f(0.2f, 0.2f, 0.2f);
   //    glVertex2f(-0.2f, -0.2f);
   //    glColor3f(1.0f, 1.0f, 1.0f);
   //    glVertex2f( 0.2f, -0.2f);
   //    glColor3f(0.2f, 0.2f, 0.2f);
   //    glVertex2f( 0.2f,  0.2f);
   //    glColor3f(1.0f, 1.0f, 1.0f);
   //    glVertex2f(-0.2f,  0.2f);
   // glEnd();
   // glPopMatrix();
 
   // glPushMatrix();
   // glTranslatef(0.4f, -0.3f, 0.0f);
   // glRotatef(angle, 0.0f, 0.0f, 1.0f);
   // glBegin(GL_TRIANGLES);
   //    glColor3f(0.0f, 0.0f, 1.0f);
   //    glVertex2f(-0.3f, -0.2f);
   //    glVertex2f( 0.3f, -0.2f);
   //    glVertex2f( 0.0f,  0.3f);
   // glEnd();
   // glPopMatrix();
 
   // glPushMatrix();
   // glTranslatef(0.6f, -0.6f, 0.0f);
   // glRotatef(180.0f + angle, 0.0f, 0.0f, 1.0f);
   // glBegin(GL_TRIANGLES);
   //    glColor3f(1.0f, 0.0f, 0.0f);
   //    glVertex2f(-0.3f, -0.2f);
   //    glColor3f(0.0f, 1.0f, 0.0f);
   //    glVertex2f( 0.3f, -0.2f);
   //    glColor3f(0.0f, 0.0f, 1.0f);
   //    glVertex2f( 0.0f,  0.3f);
   // glEnd();
   // glPopMatrix();
 
   // glPushMatrix();
   // glTranslatef(0.5f, 0.4f, 0.0f);
   // glRotatef(angle, 0.0f, 0.0f, 1.0f);
   // glBegin(GL_POLYGON);
   //    glColor3f(1.0f, 1.0f, 0.0f);
   //    glVertex2f(-0.1f, -0.2f);
   //    glVertex2f( 0.1f, -0.2f);
   //    glVertex2f( 0.2f,  0.0f);
   //    glVertex2f( 0.1f,  0.2f);
   //    glVertex2f(-0.1f,  0.2f);
   //    glVertex2f(-0.2f,  0.0f);
   // glEnd();
   // glPopMatrix();
 
   // angle += 0.2f;
}
