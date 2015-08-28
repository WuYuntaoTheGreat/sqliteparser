/* vim: set nu ai et ts=4 sw=4 ft=yacc : */
%{
require("coffee-script/register");
var G = require("../big_handler");
var G_C = G.cmd;

%}

%start input
%%

input
    : cmdlist EOF
        {
            console.log(JSON.stringify($1, null, "  "));
        }
    ;

cmdlist
    : cmdlist ecmd
        { if($2){ $1.push($2); } }
    | ecmd
        { $$ = $1 ? [ $1 ] : []; }
    ;

ecmd
    : SEMI
        { $$ = null; }
    | explain cmd SEMI
        { $$ = $2; $$.explain = $1; }
    ;

explain
    :
        { $$ = []; }
    | EXPLAIN
        { $$ = [ $1 ]; }
    | EXPLAIN QUERY PLAN
        { $$ = [ $1, $2, $3 ]; }
    ;

cmd
    : BEGIN transtype trans_opt
        { $$ = G_C.begin_trans($2, $3); }
    | COMMIT trans_opt
        { $$ = G_C.commit_trans($2); }
    | END trans_opt
        { $$ = G_C.end_trans($2); }
    | ROLLBACK trans_opt
        { $$ = G_C.rollback_trans($2); }
    | SAVEPOINT nm
        { $$ = G_C.savepoint($2); }
    | RELEASE savepoint_opt nm
        { $$ = G_C.release_savepoint($3); }
    | ROLLBACK trans_opt TO savepoint_opt nm
        { $$ = G_C.rollback_savepoint($2, $5); }
    | create_table create_table_args
        { $$ = G_C.create_table($1, $2); }
    | DROP TABLE ifexists fullname
        { $$ = G_C.drop_table($3, $4); }
    | CREATE temp VIEW ifnotexists fullname AS select
    | DROP VIEW ifexists fullname
        { $$ = G_C.drop_view($3, $4); }
    | select
    | with DELETE FROM fullname indexed_opt where_opt
    | with UPDATE orconf fullname indexed_opt SET setlist where_opt
    | with insert_cmd INTO fullname inscollist_opt select
    | with insert_cmd INTO fullname inscollist_opt DEFAULT VALUES
    | CREATE uniqueflag INDEX ifnotexists fullname ON nm LP idxlist RP where_opt
    | DROP INDEX ifexists fullname
        { $$ = G_C.drop_index($3, $3); }
    | VACUUM
        { $$ = G_C.vacuum(); }
    | VACUUM nm
        { $$ = G_C.vacuum($2); }
    | PRAGMA fullname
        { $$ = G_C.pragma($2); }
    | PRAGMA fullname EQ nmnum
        { $$ = G_C.pragma($2, "=", $4); }
    | PRAGMA fullname LP nmnum RP
        { $$ = G_C.pragma($2, "()", $4); }
    | PRAGMA fullname EQ minus_num
        { $$ = G_C.pragma($2, "=", $4); }
    | PRAGMA fullname LP minus_num RP
        { $$ = G_C.pragma($2, "()", $4); }
    | CREATE trigger_decl BEGIN trigger_cmd_list END
    | DROP TRIGGER ifexists fullname
        { $$ = G_C.drop_trigger($3, $4); }
    | ATTACH database_kw_opt expr AS expr key_opt
    | DETACH database_kw_opt expr
    | REINDEX
        { $$ = G_C.reindex(); }
    | REINDEX fullname
        { $$ = G_C.reindex($2); }
    | ANALYZE
        { $$ = G_C.analyze(); }
    | ANALYZE fullname
        { $$ = G_C.analyze($2); }
    | ALTER TABLE fullname RENAME TO nm
        { $$ = G_C.alter_rename($3, $6); }
    | ALTER TABLE add_column_fullname ADD kwcolumn_opt column
        { $$ = G_C.alter_add_column($3, $6); }
    | create_vtab
        { $$ = $1; }
    | create_vtab LP vtabarglist RP
        { $$ = $1; $$.arglist = $3; }
    ;

trans_opt
    :
        { $$ = []; }
    | TRANSACTION
        { $$ = [ $1 ]; }
    | TRANSACTION nm
        { $$ = [ $1, $2 ]; }
    ;

transtype
    :
        { $$ = null; }
    | DEFERRED
        { $$ = $1; }
    | IMMEDIATE
        { $$ = $1; }
    | EXCLUSIVE
        { $$ = $1; }
    ;

savepoint_opt
    :
    | SAVEPOINT
        { /* Ignored */ }
    ;

create_table
    : CREATE temp TABLE ifnotexists fullname
        { $$ = G.create_table($2, $4, $5); }
    ;

ifnotexists
    :
        { $$ = []; }
    | IF NOT EXISTS
        { $$ = [ $1, $2, $3 ]; }
    ;

temp
    :
        { $$ = null; }
    | TEMP
        { $$ = $1; }
    ;

create_table_args
    : LP columnlist conslist_opt RP table_options
        { $$ = G.create_table_args(); }
    | AS select
        { $$ = G.create_table_args_as($2); }
    ;

table_options
    :
        { $$ = []; }
    | WITHOUT nm
        { $$ = [ $1, $2 ]; }
    ;

columnlist
    : columnlist COMMA column
        { $1.push($3); }
    | column
        { $$ = [ $1 ]; }
    ;

column
    : columnid type carglist
        { $$ = G.column($1, $2, $3); }
    ;

columnid
    : nm
        { $$ = $1; }
    ;

nm
    : ID
        { $$ = G.nm($1, "ID");
    /* | INDEXED
        { $$ = G.nm($1, "INDEXED"); } */ /* I think this is wrong */ }
    | STRING
        { $$ = G.nm($1, "STRING"); }
    | JOIN_KW
        { $$ = G.nm($1, "JOIN_KW"); }
    ;

type
    :
        { $$ = null; }
    | typetoken
        { $$ = $1; }
    ;

typetoken
    : typename
        { $$ = G.typetoken($1); }
    | typename LP signed RP
        { $$ = G.typetoken($1, $3); }
    | typename LP signed COMMA signed RP
        { $$ = G.typetoken($1, $3, $5); }
    ;

typename
    : ID
        { $$ = [ $1 ]; }
    | STRING
        { $$ = [ $1 ]; }
    | typename ID
        { $1.push($2); }
    | typename STRING
        { $1.push($2); }
    ;

signed
    : plus_num
        { $$ = $1; }
    | minus_num
        { $$ = $1; }
    ;

carglist
    :
        { $$ = []; }
    | carglist ccons
        { $1.push($2); }
    ;

ccons
    : CONSTRAINT nm
        { $$ = [ $1, $2 ]; }
    | DEFAULT term
        { $$ = [ $1, $2 ]; }
    | DEFAULT LP expr RP
        { $$ = [ $1, $2, $3, $4 ]; }
    | DEFAULT PLUS term
        { $$ = [ $1, $2, $3 ]; }
    | DEFAULT MINUS term
        { $$ = [ $1, $2, $3 ]; }
    | DEFAULT ID
        { $$ = [ $1, $2 ]; }
    | DEFAULT INDEXED
        { $$ = [ $1, $2 ]; }
    | NULL onconf
        { $$ = [ $1 ].concat($2); }
    | NOT NULL onconf
        { $$ = [ $1, $2 ].concat($2); }
    | PRIMARY KEY sortorder onconf autoinc
        { $$ = [ $1, $2, $3, $4, $5 ]; }
    | UNIQUE onconf
        { $$ = [ $1 ].concat($2); }
    | CHECK LP expr RP
        { $$ = [ $1, $2, $3, $4 ]; }
    | REFERENCES nm idxlist_opt refargs
        { $$ = [ $1, $2, $3, $4 ]; }
    | defer_subclause
        { $$ = $1; }
    | COLLATE ID
        { $$ = [ $1, $2 ]; }
    | COLLATE STRING
        { $$ = [ $1, $2 ]; }
    ;

autoinc
    :
        { $$ = null; }
    | AUTOINCR
        { $$ = $1; }
    ;

refargs
    :
        { $$ = []; }
    | refargs refarg
        { $1.push($2); }
    ;

refarg
    : MATCH nm
        { $$ = [ $1, $2 ]; }
    | ON INSERT refact
        { $$ = [ $1, $2].concat($3); }
    | ON DELETE refact
        { $$ = [ $1, $2].concat($3); }
    | ON UPDATE refact
        { $$ = [ $1, $2].concat($3); }
    ;

refact
    : SET NULL
        { $$ = [ $1, $2 ]; }
    | SET DEFAULT
        { $$ = [ $1, $2 ]; }
    | CASCADE
        { $$ = [ $1 ]; }
    | RESTRICT
        { $$ = [ $1 ]; }
    | NO ACTION
        { $$ = [ $1, $2 ]; }
    ;

defer_subclause
    : NOT DEFERRABLE init_deferred_pred_opt
        { $$ = [ $1, $2 ].concat($3); }
    | DEFERRABLE init_deferred_pred_opt
        { $$ = [ $1, $2 ].concat($3); }
    ;

init_deferred_pred_opt
    :
        { $$ = []; }
    | INITIALLY DEFERRED
        { $$ = [ $1, $2 ]; }
    | INITIALLY IMMEDIATE
        { $$ = [ $1, $2 ]; }
    ;

conslist_opt
    :
        { $$ = []; }
    | COMMA conslist
        { $$ = $2; }
    ;

conslist
    : conslist tconscomma tcons
        { $1.push($3); }
    | tcons
        { $$ = [ $1 ]; }
    ;

tconscomma
    :
    | COMMA
        { /* Ignored */ }
    ;

tcons
    : CONSTRAINT nm
        { $$ = G.tcons.constraint($2); }
    | PRIMARY KEY LP idxlist autoinc RP onconf
        { $$ = G.tcons.primary_key($4, $5, $7); }
    | UNIQUE LP idxlist RP onconf
        { $$ = G.tcons.unique($3, $5); }
    | CHECK LP expr RP onconf
        { $$ = G.tcons.check($3, $5); }
    | FOREIGN KEY LP idxlist RP REFERENCES nm idxlist_opt refargs defer_subclause_opt {
    /*1       2   3  4       5  6          7  8           9       10 */
          $$ = G.tcons.foreign_key($4, $7, $8, $9, $10);  }
    ;

defer_subclause_opt
    :
        { $$ = null; }
    | defer_subclause
        { $$ = $1; }
    ;

onconf
    :
        { $$ = []; }
    | ON CONFLICT resolvetype
        { $$ = [ $1, $2, $3 ]; }
    ;

orconf
    :
        { $$ = []; }
    | OR resolvetype
        { $$ = [ $1, $2 ]; }
    ;

resolvetype
    : raisetype
        { $$ = $1; }
    | IGNORE
        { $$ = $1; }
    | REPLACE
        { $$ = $1; }
    ;

ifexists
    :
        { $$ = []; }
    | IF EXISTS
        { $$ = [ $1, $2 ]; }
    ;

select
    : with selectnowith
        { $$ = G.select($1, $2); }
    ;

selectnowith
    : oneselect
        { $$ = [ $1 ]; }
    | selectnowith multiselect_op oneselect
        { $1.push($2); $1.push($3); }
    ;

multiselect_op
    : UNION
        { $$ = $1; }
    | UNION ALL
        { $$ = $1; }
    | EXCEPT
        { $$ = $1; }
    | INTERSECT
        { $$ = $1; }
    ;

oneselect
    : SELECT distinct selcollist from where_opt groupby_opt having_opt orderby_opt limit_opt
        { $$ = G.oneselect([$2, $3, $4, $5, $6, $7, $8]); }
    | values
        { $$ = G.oneselect_values($1); }
    ;

values
    : VALUES LP nexprlist RP
        { $$ = [ $3 ]; }
    | values COMMA LP exprlist RP
        { $1.push($4); }
    ;

distinct
    :
        { $$ = null; }
    | DISTINCT
        { $$ = $1; }
    | ALL
        { $$ = $1; }
    ;

sclp
    :
    | selcollist COMMA
    ;

selcollist
    : sclp expr as
    | sclp STAR
    | sclp nm DOT STAR
    ;

as
    :
    | AS nm
    | ID
    | STRING
    ;

from
    :
    | FROM seltablist
    ;

stl_prefix
    :
    | seltablist joinop
    ;

seltablist
    : stl_prefix fullname as indexed_opt on_opt using_opt
    | stl_prefix fullname LP exprlist RP as on_opt using_opt
    | stl_prefix LP select RP as on_opt using_opt
    | stl_prefix LP seltablist RP as on_opt using_opt
    ;

dbnm
    :
        { $$ = G.dbnm(); }
    | DOT nm
        { $$ = G.dbnm($2); }
    ;

fullname
    : nm dbnm
        { $$ = G.fullname($1, $2); }
    ;

joinop
    : COMMA
        { $$ = [ $1 ]; }
    | JOIN
        { $$ = [ $1 ]; }
    | JOIN_KW JOIN
        { $$ = [ $1, $2 ]; }
    | JOIN_KW nm JOIN
        { $$ = [ $1, $2, $3 ]; }
    | JOIN_KW nm nm JOIN
        { $$ = [ $1, $2, $3, $4 ]; }
    ;

on_opt
    :
    | ON expr
    ;

indexed_opt
    :
    | INDEXED BY nm
    | NOT INDEXED
    ;

using_opt
    :
    | USING LP idlist RP
    ;

orderby_opt
    :
    | ORDER BY sortlist
    ;

sortlist
    : sortlist COMMA expr sortorder
    | expr sortorder
    ;

sortorder
    :
        { $$ = null; }
    | ASC
        { $$ = $1; }
    | DESC
        { $$ = $1; }
    ;

groupby_opt
    :
        { $$ = []; }
    | GROUP BY nexprlist
        { $$ = [ $1, $2, $3 ]; }
    ;

having_opt
    :
        { $$ = []; }
    | HAVING expr
        { $$ = [ $1, $2 ]; }
    ;

limit_opt
    :
        { $$ = []; }
    | LIMIT expr
        { $$ = [ $1, $2 ]; }
    | LIMIT expr OFFSET expr
        { $$ = [ $1, $2, $3, $4 ]; }
    | LIMIT expr COMMA expr
        { $$ = [ $1, $2, $3, $4 ]; }
    ;

where_opt
    :
        { $$ = []; }
    | WHERE expr
        { $$ = [ $1, $2 ]; }
    ;

setlist
    : setlist COMMA nm EQ expr
        { $1.push([ $1, $2, $3 ]); }
    | nm EQ expr
        { $$ = [ [ $1, $2, $3 ] ]; }
    ;

insert_cmd
    : INSERT orconf
    | REPLACE
    ;

inscollist_opt
    :
    | LP idlist RP
    ;

idlist
    : idlist COMMA nm
    | nm
    ;

expr
    : term
    | LP expr RP
    | ID
    | INDEXED
    | JOIN_KW
    | nm DOT nm
    | nm DOT nm DOT nm
    | VARIABLE
    | expr COLLATE ID
    | expr COLLATE STRING
    | CAST LP expr AS typetoken RP
    | ID LP distinct exprlist RP
    | INDEXED LP distinct exprlist RP
    | ID LP STAR RP
    | INDEXED LP STAR RP
    | expr AND expr
    | expr OR expr
    | expr LT expr
    | expr GT expr
    | expr GE expr
    | expr LE expr
    | expr EQ expr
    | expr NE expr
    | expr BITAND expr
    | expr BITOR expr
    | expr LSHIFT expr
    | expr RSHIFT expr
    | expr PLUS expr
    | expr MINUS expr
    | expr STAR expr
    | expr SLASH expr
    | expr REM expr
    | expr CONCAT expr
    | expr likeop expr
    | expr likeop expr ESCAPE expr
    | expr ISNULL
    | expr NOTNULL
    | expr NOT NULL
    | expr IS expr
    | expr IS NOT expr
    | NOT expr
    | BITNOT expr
    | MINUS expr
    | PLUS expr
    | expr between_op expr AND expr
    | expr in_op LP exprlist RP
    | LP select RP
    | expr in_op LP select RP
    | expr in_op fullname
    | EXISTS LP select RP
    | CASE case_operand case_exprlist case_else END
    | RAISE LP IGNORE RP
    | RAISE LP raisetype COMMA nm RP
    ;

term
    : NULL
        { $$ = G.term("NULL"); }
    | INTEGER
        { $$ = G.term("INTEGER", $1); }
    | FLOAT
        { $$ = G.term("FLOAT", $1); }
    | BLOB
        { $$ = G.term("BLOB", $1); }
    | STRING
        { $$ = G.term("STRING", $1); }
    | CTIME_KW
        { $$ = G.term("CTIME_KW", $1); }
    ;

likeop
    : LIKE_KW
    | MATCH
    | NOT LIKE_KW
    | NOT MATCH
    ;

between_op
    : BETWEEN
    | NOT BETWEEN
    ;

in_op
    : IN
    | NOT IN
    ;

case_exprlist
    : case_exprlist WHEN expr THEN expr
    | WHEN expr THEN expr
    ;

case_else
    :
    | ELSE expr
    ;

case_operand
    :
    | expr
    ;

exprlist
    :
        { $$ = null; }
    | nexprlist
        { $$ = $1; }
    ;

nexprlist
    : nexprlist COMMA expr
        { $1.push($3); }
    | expr
        { $$ = [ $1 ]; }
    ;

uniqueflag
    :
        { $$ = null; }
    | UNIQUE
        { $$ = $1; }
    ;

idxlist_opt
    :
        { $$ = []; }
    | LP idxlist RP
        { $$ = $2; }
    ;

idxlist
    : nm collate sortorder
        { $$ = [ G.idx_item($1, $2, $3) ]; }
    | idxlist COMMA nm collate sortorder
        { $1.push(G.idx_item($3, $4, $5)); }
    ;

collate
    :
        { $$ = collate(); }
    | COLLATE ID
        { $$ = collate($2); }
    | COLLATE STRING
        { $$ = collate($2); }
    ;

nmnum
    : plus_num
        { $$ = G.nmnum("PLUS_NUM", $1); }
    | nm
        { $$ = G.nmnum("NM", $1); }
    | ON
        { $$ = G.nmnum("ON"); }
    | DELETE
        { $$ = G.nmnum("DELETE"); }
    | DEFAULT
        { $$ = G.nmnum("DEFAULT"); }
    ;

plus_num
    : PLUS INTEGER
        { $$ = $1; }
    | PLUS FLOAT
        { $$ = $1; }
    | INTEGER
        { $$ = $1; }
    | FLOAT
        { $$ = $1; }
    ;

minus_num
    : MINUS INTEGER
        { $$ = $2.toNegative(); }
    | MINUS FLOAT
        { $$ = $2.toNegative(); }
    ;

trigger_decl
    : temp TRIGGER ifnotexists fullname trigger_time trigger_event ON fullname foreach_clause when_clause
    ;

trigger_time
    :
    | BEFORE
    | AFTER
    | INSTEAD OF
    ;

trigger_event
    : DELETE
    | INSERT
    | UPDATE
    | UPDATE OF idlist
    ;

foreach_clause
    :
    | FOR EACH ROW
    ;

when_clause
    :
    | WHEN expr
    ;

trigger_cmd_list
    : trigger_cmd_list trigger_cmd SEMI
    | trigger_cmd SEMI
    ;

trnm
    : nm
    | nm DOT nm
    ;

tridxby
    :
    | INDEXED BY nm
    | NOT INDEXED
    ;

trigger_cmd
    : UPDATE orconf trnm tridxby SET setlist where_opt
    | insert_cmd INTO trnm inscollist_opt select
    | DELETE FROM trnm tridxby where_opt
    | select
    ;

raisetype
    : ROLLBACK
        { $$ = $1; }
    | ABORT
        { $$ = $1; }
    | FAIL
        { $$ = $1; }
    ;

key_opt
    :
    | KEY expr
    ;

database_kw_opt
    :
    | DATABASE
    ;

add_column_fullname
    : fullname
        { $$ = $1; }
    ;

kwcolumn_opt
    :
    | COLUMNKW
    ;

create_vtab
    : CREATE VIRTUAL TABLE ifnotexists fullname USING nm
        { $$ = [ $1, $2, $3, $4, $5, $6, $7 ]; }
    ;

vtabarglist
    : vtabarg
        { $$ = [ $1 ]; }
    | vtabarglist COMMA vtabarg
        { $1.push($3); }
    ;

vtabarg
    :
        { $$ = null;  /* }
            # ========================================
            FIXME: The virtual table creation statement
            can take zero or more comma-separated
            arguments. The arguments can be just about
            ANY text as long as it has balanced
            parentheses. For example:

            CREATE VIRTUAL TABLE IF NOT EXISTS \
                tablename USING module ( arg, arg ... );

            The source code of Sqlite itself use the
            Terminal "ANY", which I don't know if is a
            key word of lemon parser, but it's surely
            not work in Jison. I need to figure out how
            to implement this.

    | vtabarg vtabargtoken
        { $1.push($2); }
    ;

vtabargtoken
    : ANY
    | LP anylist RP
    ;

anylist
    :
    | anylist LP anylist RP
    | anylist ANY
            # ========================================
        {*/}
    ;

with
    :
        { $$ = []; }
    | WITH wqlist
        { $$ = [ $1, $2 ]; }
    | WITH RECURSIVE wqlist
        { $$ = [ $1, $2, $3 ]; }
    ;

wqlist
    : nm idxlist_opt AS LP select RP
        { $$ = [ [ $1, $2, $3, $4, $5, $6 ] ]; }
    | wqlist COMMA nm idxlist_opt AS LP select RP
        { $1.push([ $1, $2, $3, $4, $5, $6 ]); }
    ;



