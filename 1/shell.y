/* Author: Will Crawford <wacrawfo@ucsc.edu> */
%{

%}

%error-verbose
%token TOK_WORD TOK_EXIT TOK_NEWLINE
%start sentence

%%

sentence : exit                  { exit(0); }
         | exit ';'              { exit(0); }
         | command               { }
         ;

command  : clause ';'            { }
         | command clause        { }
         | clause                { }
         ;


pipe     : clause '|'
         | clause_w '|'
         | clause_r '|'
         | clause_rw '|'
         ;

clause_rw: clause_w '>' word
         | clause_r '<' word
         ;

clause_w : clause '<' word
         ;

clause_r : clause '>' word
         ;

clause   :  TOK_WORD
         |  clause TOK_WORD
         ;
exit     : TOK_EXIT
         | TOK_EXIT ';'
         ;
