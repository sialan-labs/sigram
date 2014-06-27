#ifndef TMAIN_H
#define TMAIN_H

int tmain (int argc, char **argv);
void sendCommand( char *data );

int myPeer(int our_id);
void doAddContact(const char *phone, const char *fname, const char *lname , int force);

int dateYear( long t );
int dateMonth( long t );
int dateDay( long t );
int dateHour( long t );
int dateMinute( long t );
int dateSecond( long t );

#endif //TMAIN_H
