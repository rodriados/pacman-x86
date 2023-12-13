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
#include <GL/gl.h>

/**
 * Prints a message to the console informing the player that the game has debug
 * mode on. Therefore, game performance may be negatively affected.
 * @since 1.0
 */
extern void showDebugMessage()
{
    puts("         ==== Pacman-x86 Debug Mode ====        ");
    puts(" Debug mode is on, performance may be affected. ");
    puts("Debugging information may be printed to console.");
}

/**
 * Retrieves the current time since UNIX epoch.
 * @return The current time.
 */
static uint64_t getTime()
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

/**
 * Enumerates the colors that may selected for checkboard squares.
 * @since 1.0
 */
typedef enum { GREEN, BLUE } checkboard_color_t;

/**
 * Sets the color for the checkboard squares to be rendered next.
 * @param color The color to print the next square with.
 */
static void setCheckboardColor(checkboard_color_t color)
{
    switch (color) {
        case GREEN: glColor3f(.0f, .3f, .0f); break;
        case BLUE:  glColor3f(.0f, .0f, .3f); break;
        default:    break;
    }
}

/**
 * Renders a checkboard square with the currently set color.
 * @param x The x-coordinate of the square to be rendered.
 * @param y The y-coordinate of the square to be rendered.
 */
static void drawCheckboardSquare(uint32_t x, uint32_t y)
{
    glVertex2f(      x * 1.f,       y * 1.f);
    glVertex2f((x + 1) * 1.f,       y * 1.f);
    glVertex2f((x + 1) * 1.f, (y + 1) * 1.f);
    glVertex2f(      x * 1.f, (y + 1) * 1.f);
}

/**
 * Renders a colored checkboard over the game's coordinates.
 * @since 1.0
 */
extern void drawCheckboard()
{
    glBegin(GL_QUADS);

    for (uint32_t x = 0, n = 0; x < 28; ++x) {
        for (uint32_t y = 0; y < 31; ++y, ++n) {
            setCheckboardColor((n & 1) ? GREEN : BLUE);
            drawCheckboardSquare(x, y);
        }
    }

    glEnd();
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
