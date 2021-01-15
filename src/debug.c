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
