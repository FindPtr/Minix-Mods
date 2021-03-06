%{
/* Author: Will Crawford <wacrawfo@ucsc.edu> */
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <stdlib.h>

int _numargs = 200;
char **_args;
extern int *cmds;
int _argcount = 0;
extern int cmd_count;
int pipe_count; /* NOT shared with dshell.c */
int _wordop = 0;
int operror = 0;
int redir_in, redir_out;
void add_arg(void);
void new_word(void);
int new_semicolon(void);
void new_op(int);
/* Notes for new_op:
-1 EOL
-2 ;
-10 <
-11 >
-12 |
*/
%}
%option noyywrap
%option 8bit
%option noinput
%option nounput
%option verbose

WORD [a-zA-Z0-9\/\.-]+
BADOP [()]

%%
  _argcount = _wordop = cmd_count = pipe_count = operror = 0; 
  redir_in = redir_out = 0; _args[1] = NULL; cmds[0] = -1;
exit                 {  if(!_wordop)
                           exit(1); /* Kludge. */
                        new_word();
                        add_arg();
                     }
{WORD}               {
                        new_word();
                        add_arg();
                     }
[>]                  {
                        new_op(-11);
                        add_arg();
                        if(redir_out){
                           fprintf(stderr, "Syntax error: detected two or more '>'\n");
                           operror = 1;
                        } else redir_out = 1;
                     }
[<]                  {
                        new_op(-10);
                        add_arg();
                        if(pipe_count){
                           fprintf(stderr, "Syntax error: detected pipe before '<'.\n");
                           operror = 1;
                        }
                        if(redir_in){
                           fprintf(stderr, "Syntax error: detected two or more '<'\n");
                           operror = 1;
                        } else redir_in = 1;
                     }
[|]                  {
                        new_op(-12);
                        add_arg();
                        pipe_count++;
                        if(redir_out){
                           fprintf(stderr,"Syntax error: detected pipe after '>'.\n");
                           operror = 1;
                        }
                     }
[;]                  {
                        if(new_semicolon())
                           add_arg();
                     }
{BADOP}              {  operror = 1; 
                        fprintf(stderr, "Syntax error: parentheses not supported.");
                     }


\n                    {cmds[cmd_count + 1] = -1; return 1; }

[ \t]+               {}
<<EOF>>              {
                     if(cmds[0] = -1)
                        exit(0);
                     else
                        operror=1;}
.                    {}

%%

char **getline(void) { return (char **)yylex(); }

void add_arg(void){
   if(_argcount < _numargs - 1) {
      _args[_argcount++] = (char*)strdup(yytext);
      _args[_argcount] = NULL;
   }
}

void new_op(int sigil){
   if(_wordop){
      _wordop = 0;
      _args[_argcount++] = NULL;
      cmds[cmd_count++] = sigil;
      cmds[cmd_count] = -1;
   } else {
      fprintf(stderr, "Syntax error: adjacent operators detected.\n");
      operror = 1;
   }
}

void new_word(void){
   if(!_wordop){
      _wordop = 1;
      _args[_argcount++] = NULL;
      cmds[cmd_count++] = _argcount;
      cmds[cmd_count] = -1;
   }
}

int new_semicolon(void){
   if(_wordop){
      _wordop = 0;
      _args[_argcount++] = NULL;
      cmds[cmd_count++] = -2;
      cmds[cmd_count] = -1;
      redir_in = redir_out = pipe_count =  0;
      return 1;
   } else {
      if(cmd_count == 0 || cmds[cmd_count-1] == -2){
         return 0;
      }
      else{
         fprintf(stderr, "Syntax error: did not expect semi-colon after redirection operator.\n");
         operror = 1;
         return 1;
      }
   }
}

