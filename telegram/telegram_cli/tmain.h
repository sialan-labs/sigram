#ifndef TMAIN_H
#define TMAIN_H

int tmain (int argc, char **argv);
void sendCommand( char *data );

int dateYear( long t );
int dateMonth( long t );
int dateDay( long t );
int dateHour( long t );
int dateMinute( long t );
int dateSecond( long t );

#endif //TMAIN_H
