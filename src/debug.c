/**
 * Pacman-x86: a Pacman implementation in pure x86 assembly.
 * @file The game's debug functions.
 * @author Rodrigo Siqueira <rodriados@gmail.com>
 * @copyright 2021-present Rodrigo Siqueira
 */
#include <time.h>
#include <stdio.h>
#include <stdint.h>

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

#include <GL/glut.h> 

float angle = 0.0;

void testScene()
{
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
 
   glPushMatrix();
   glTranslatef(-0.5f, 0.4f, 0.0f);
   glRotatef(angle, 0.0f, 0.0f, 1.0f);
   glBegin(GL_QUADS);
      glColor3f(1.0f, 0.0f, 0.0f);
      glVertex2f(-0.3f, -0.3f);
      glVertex2f( 0.3f, -0.3f);
      glVertex2f( 0.3f,  0.3f);
      glVertex2f(-0.3f,  0.3f);
   glEnd();
   glPopMatrix();
 
   glPushMatrix();
   glTranslatef(-0.4f, -0.3f, 0.0f);
   glRotatef(angle, 0.0f, 0.0f, 1.0f);
   glBegin(GL_QUADS);
      glColor3f(0.0f, 1.0f, 0.0f);
      glVertex2f(-0.3f, -0.3f);
      glVertex2f( 0.3f, -0.3f);
      glVertex2f( 0.3f,  0.3f);
      glVertex2f(-0.3f,  0.3f);
   glEnd();
   glPopMatrix();
 
   glPushMatrix();
   glTranslatef(-0.7f, -0.5f, 0.0f);
   glRotatef(angle, 0.0f, 0.0f, 1.0f);
   glBegin(GL_QUADS);
      glColor3f(0.2f, 0.2f, 0.2f);
      glVertex2f(-0.2f, -0.2f);
      glColor3f(1.0f, 1.0f, 1.0f);
      glVertex2f( 0.2f, -0.2f);
      glColor3f(0.2f, 0.2f, 0.2f);
      glVertex2f( 0.2f,  0.2f);
      glColor3f(1.0f, 1.0f, 1.0f);
      glVertex2f(-0.2f,  0.2f);
   glEnd();
   glPopMatrix();
 
   glPushMatrix();
   glTranslatef(0.4f, -0.3f, 0.0f);
   glRotatef(angle, 0.0f, 0.0f, 1.0f);
   glBegin(GL_TRIANGLES);
      glColor3f(0.0f, 0.0f, 1.0f);
      glVertex2f(-0.3f, -0.2f);
      glVertex2f( 0.3f, -0.2f);
      glVertex2f( 0.0f,  0.3f);
   glEnd();
   glPopMatrix();
 
   glPushMatrix();
   glTranslatef(0.6f, -0.6f, 0.0f);
   glRotatef(180.0f + angle, 0.0f, 0.0f, 1.0f);
   glBegin(GL_TRIANGLES);
      glColor3f(1.0f, 0.0f, 0.0f);
      glVertex2f(-0.3f, -0.2f);
      glColor3f(0.0f, 1.0f, 0.0f);
      glVertex2f( 0.3f, -0.2f);
      glColor3f(0.0f, 0.0f, 1.0f);
      glVertex2f( 0.0f,  0.3f);
   glEnd();
   glPopMatrix();
 
   glPushMatrix();
   glTranslatef(0.5f, 0.4f, 0.0f);
   glRotatef(angle, 0.0f, 0.0f, 1.0f);
   glBegin(GL_POLYGON);
      glColor3f(1.0f, 1.0f, 0.0f);
      glVertex2f(-0.1f, -0.2f);
      glVertex2f( 0.1f, -0.2f);
      glVertex2f( 0.2f,  0.0f);
      glVertex2f( 0.1f,  0.2f);
      glVertex2f(-0.1f,  0.2f);
      glVertex2f(-0.2f,  0.0f);
   glEnd();
   glPopMatrix();
 
   glutSwapBuffers();
 
   angle += 0.2f;
}
