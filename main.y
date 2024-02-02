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

#include <string>
#include <unordered_map>
#include <iostream>
#include <stdio.h>
#include <cstring>

std::unordered_map<std::string, int> hashtable;

extern "C" int yylex(void);
extern int yyparse();
extern FILE *yyin;
extern "C" void yyerror(const char *s);

// static int value = 0;
// std::string var_name;
// bool postincr = false;
extern void ensureinitted(std::string s);
%}

%token  END 0
%token STR INT PLUSPLUS

// %union{
//   // 
//   char* S;
//   int I;
//   } //
// %type <I> INT expr add
// %type <S> STR term comp

%%

expr: term '=' expr {
  std::string var_name;
  if ($1.e == TOK_TYPE_S) {
    var_name = $1.v.S;
  } else if ($1.e == TOK_TYPE_INC) {
    var_name = $1.v.INC.S;
  } else {
    YYERROR;
  }

  $$.e = TOK_TYPE_I;
  hashtable[var_name] = $3.v.I;

  if ($1.e == TOK_TYPE_INC)
    if ($1.v.INC.post)
      hashtable[var_name]++;
    else
      ++hashtable[var_name];

  $$.v.I = hashtable[var_name];
}

expr: add {
  $$.e = TOK_TYPE_I;
  $$.v.I = $1.v.I;
}

add: add '+' term {
  int value;
  switch ($3.e) {
    case TOK_TYPE_I:
      value = $3.v.I;
      break;
    case TOK_TYPE_S:
      ensureinitted(std::string($3.v.S));
      value = hashtable[std::string($3.v.S)];
      break;
    case TOK_TYPE_INC:
      ensureinitted(std::string($3.v.INC.S));
      value = ($3.v.INC.post) ? hashtable[std::string($3.v.S)]++ : ++hashtable[std::string($3.v.S)];
      break;
  }

  $$.e = TOK_TYPE_I;
  $$.v.I = $1.v.I + value;
}

add: term {
  // $$ = value;
  $$.e = TOK_TYPE_I;
  switch ($1.e) {
    case TOK_TYPE_I:
      $$.v.I = $1.v.I;
      break;
    case TOK_TYPE_S:
      ensureinitted(std::string($1.v.S));
      $$.v.I = hashtable[std::string($1.v.S)];
      break;
    case TOK_TYPE_INC:
      ensureinitted(std::string($1.v.INC.S));
      $$.v.I = ($1.v.INC.post) ? hashtable[std::string($1.v.S)]++ : ++hashtable[std::string($1.v.S)];
      break;
  }
}

term: PLUSPLUS STR {
  // var_name = std::string($3);
  // value = hashtable[var_name];
  // std::cout << "DBG: ++STR: ++" << $3 << " = ++" << value << std::endl;
  // ++value;
  // std::cout << "DBG: = " << value << std::endl;
  // hashtable[var_name] = value;
  // postincr = false;
  // $$ = strdup($3);
  $$.e = TOK_TYPE_INC;
  ensureinitted(std::string($2.v.S));
  // $$.v.INC.S = strdup($3.v.S);
  strncpy($$.v.INC.S, $2.v.S, 200);
  $$.v.INC.post = false;
}

term: STR {
  // var_name = std::string($1);
  // value = hashtable[var_name];
  // postincr = false;
  // $$ = strdup($1);
  $$.e = $1.e;
  ensureinitted(std::string($1.v.S));
  // $$.v.S = strdup($1.v.S);
  strncpy($$.v.S, $1.v.S, 200);
}

term: comp {
  $$.e = $1.e;
  if ($1.e == TOK_TYPE_I) {
    $$.v.I = $1.v.I;
  } else {
    ensureinitted(std::string($1.v.INC.S));
    // $$.v.INC.S = strdup($1.v.INC.S);
    strncpy($$.v.INC.S, $1.v.INC.S, 200);
  }
}

comp: STR PLUSPLUS {
  // postincr = true;
  // var_name = std::string($1);
  // value = hashtable[var_name]++;
  // $$ = strdup($1);
  $$.e = TOK_TYPE_INC;
  ensureinitted(std::string($1.v.S));
  // $$.v.INC.S = strdup($1.v.S);
  strncpy($$.v.INC.S, $1.v.S, 200);
  $$.v.INC.post = true;
}

comp: INT {
  // std::cout << "value:"<< value;
  // value = $1;
  // std::cout << "; value_new:"<< value << "\n";
  // $$ = strdup("");
  $$.e = $1.e;
  $$.v.I = $1.v.I;
}

%%

int main(int, char**) {
  FILE *myfile = fopen("test", "r");
  if (!myfile) {
    std::cout << "I can't open test file!" << std::endl;
    return -1;
  }
  //yyin = myfile;
  yyin = stdin;

  yyparse();

  for (const auto &p : hashtable) {
    std::cout << p.first << " : " << p.second << std::endl;
  }
}


void yyerror(const char *s) {
  std::cout << "EEK, parse error!  Message: " << s << std::endl;
  exit(-1);
}


void ensureinitted(std::string s) {
  if (hashtable.find(s) == hashtable.end()) {
    hashtable[s] = 0;
  }
}
