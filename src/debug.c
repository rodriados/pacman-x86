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
    puts("           ==== Pacman-x86 Debug Mode ====          ");
    puts("   Debug mode is on, performance may be affected.   ");
    puts("Debugging information may be printed to the console.");
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
typedef enum { BLACK, BLUE, GREEN, YELLOW, RED, PURPLE } checkboard_color_t;

/**
 * Sets the color for the checkboard squares to be rendered next.
 * @param color The color to print the next square with.
 */
static void setCheckboardColor(checkboard_color_t color)
{
    switch (color) {
        case BLACK:  glColor3f(.0f, .0f, .0f); break;
        case BLUE:   glColor3f(.0f, .0f, .1f); break;
        case GREEN:  glColor3f(.0f, .1f, .0f); break;
        case YELLOW: glColor3f(.1f, .1f, .0f); break;
        case RED:    glColor3f(.1f, .0f, .0f); break;
        case PURPLE: glColor3f(.1f, .0f, .1f); break;
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

    for (uint32_t y = 0; y < 31; ++y) {
        for (uint32_t x = 0; x < 28; ++x) {
            setCheckboardColor(getBoardCellState(x, y));
            drawCheckboardSquare(x, y);
        }
    }

    glEnd();
}
