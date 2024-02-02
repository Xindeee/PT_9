%{
  enum TOK_TYPE {
  TOK_TYPE_I,
  TOK_TYPE_S,
  TOK_TYPE_INC
};

struct _Tok_t_INC {
  char S[200];
  bool post;
};

union _Tok_t {
  int I;
  char S[200];
  _Tok_t_INC INC;
};

struct Tok_t {
  TOK_TYPE e;
  _Tok_t v;
};

#define YYSTYPE Tok_t

  #include "main.tab.hh"
  extern "C" int yylex(void);
%}

%%

[a-zA-Z][a-zA-Z0-9]* {
  yylval.e = TOK_TYPE_S;
  // yylval.v.S = strdup(yytext);
  strncpy(yylval.v.S, yytext, 200);
  return STR;
}
[0-9]+ {
  yylval.e = TOK_TYPE_I;
  yylval.v.I = atoi(yytext);
  return INT;
}

\+   { return '+'; }
\=   { return '='; }
\+\+ { return PLUSPLUS; }

%%
