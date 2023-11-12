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
#include <stdlib.h>

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

GLuint textureID = 0;

// asm:   bswap <reg>
unsigned uint_big_endianness(unsigned char bytes[4])
{
    return bytes[3] | (bytes[2] << 8) | (bytes[1] << 16) | (bytes[0] << 24);
}

extern GLuint _spriteBoard;

extern void drawBoard()
{
    textureID = _spriteBoard;

    glBegin(GL_QUADS);
    for (unsigned int x =0;x<28;++x)
        for (unsigned int y =0;y<31;++y)
        {
            if ((x+y)&0x00000001) //modulo 2
                glColor3f(0.0f,.3f,0.0f);
            else
                glColor3f(0.0f,0.0f,.3f);

            glVertex2f(    x*1.f,    y*1.f);
            glVertex2f((x+1)*1.f,    y*1.f);
            glVertex2f((x+1)*1.f,(y+1)*1.f);
            glVertex2f(    x*1.f,(y+1)*1.f);

        }
    glEnd();

    glEnable(GL_TEXTURE_2D);
    glColor4d(1.f,1.f,1.f,1.f);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glBegin(GL_POLYGON);

      glTexCoord2f(0.f,  0.f);
      glVertex2d(  0.f,  0.f);

      glTexCoord2f(1.f,  0.f);
      glVertex2d( 28.f,  0.f);

      glTexCoord2f(1.f,  1.f);
      glVertex2d( 28.f, 31.f);

      glTexCoord2f(0.f,  1.f);
      glVertex2d(  0.f, 31.f);

    glEnd();
    glDisable(GL_TEXTURE_2D);

    glColor4d(1.f,0.f,0.f,1.f);
    glBegin(GL_POLYGON);

      glVertex2d(x1 + 0., y1 + 0.);
      glVertex2d(x1 + 1., y1 + 0.);
      glVertex2d(x1 + 1., y1 + 1.);
      glVertex2d(x1 + 0., y1 + 1.);

      x1 += deltaX * 2;
      y1 += deltaY * 2;

    glEnd();
}
