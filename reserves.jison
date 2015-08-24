/* vim: set nu ai et ts=4 sw=4: */

/*
 * definitions section
 */
%lex

/*
 * rules section
 */
%%

[0-9]+                  return 'DIGIT-LIST'
[0-9A-Fa-f]+            return 'HEXDIGIT-LIST'
"ABORT"					return 'ABORT'
"ACTION"				return 'ACTION'
"ADD"					return 'ADD'
"AFTER"					return 'AFTER'
"ALL"					return 'ALL'
"ALTER"					return 'ALTER'
"ANALYZE"				return 'ANALYZE'
"AND"					return 'AND'
"AS"					return 'AS'
"ASC"					return 'ASC'
"ATTACH"				return 'ATTACH'
"AUTOINCREMENT"			return 'AUTOINCREMENT'
"BEFORE"				return 'BEFORE'
"BEGIN"					return 'BEGIN'
"BETWEEN"				return 'BETWEEN'
"BY"					return 'BY'
"CASCADE"				return 'CASCADE'
"CASE"					return 'CASE'
"CAST"					return 'CAST'
"CHECK"					return 'CHECK'
"COLLATE"				return 'COLLATE'
"COLUMN"				return 'COLUMN'
"COMMIT"				return 'COMMIT'
"CONFLICT"				return 'CONFLICT'
"CONSTRAINT"			return 'CONSTRAINT'
"CREATE"				return 'CREATE'
"CROSS"					return 'CROSS'
"CURRENT_DATE"			return 'CURRENT_DATE'
"CURRENT_TIME"			return 'CURRENT_TIME'
"CURRENT_TIMESTAMP"		return 'CURRENT_TIMESTAMP'
"DATABASE"				return 'DATABASE'
"DEFAULT"				return 'DEFAULT'
"DEFERRABLE"			return 'DEFERRABLE'
"DEFERRED"				return 'DEFERRED'
"DELETE"				return 'DELETE'
"DESC"					return 'DESC'
"DETACH"				return 'DETACH'
"DIGIT"					return 'DIGIT'
"DISTINCT"				return 'DISTINCT'
"DROP"					return 'DROP'
"EACH"					return 'EACH'
"ELSE"					return 'ELSE'
"END"					return 'END'
"EOF"					return 'EOF'
"ESCAPE"				return 'ESCAPE'
"EXCEPT"				return 'EXCEPT'
"EXCLUSIVE"				return 'EXCLUSIVE'
"EXISTS"				return 'EXISTS'
"EXPLAIN"				return 'EXPLAIN'
"FAIL"					return 'FAIL'
"FOR"					return 'FOR'
"FOREIGN"				return 'FOREIGN'
"FROM"					return 'FROM'
"GLOB"					return 'GLOB'
"GROUP"					return 'GROUP'
"HAVING"				return 'HAVING'
"HEXDIGIT"				return 'HEXDIGIT'
"IF"					return 'IF'
"IGNORE"				return 'IGNORE'
"IMMEDIATE"				return 'IMMEDIATE'
"IN"					return 'IN'
"INDEX"					return 'INDEX'
"INDEXED"				return 'INDEXED'
"INITIALLY"				return 'INITIALLY'
"INNER"					return 'INNER'
"INSERT"				return 'INSERT'
"INSTEAD"				return 'INSTEAD'
"INTERSECT"				return 'INTERSECT'
"INTO"					return 'INTO'
"IS"					return 'IS'
"ISNULL"				return 'ISNULL'
"JOIN"					return 'JOIN'
"KEY"					return 'KEY'
"LEFT"					return 'LEFT'
"LIKE"					return 'LIKE'
"LIMIT"					return 'LIMIT'
"LIST"					return 'LIST'
"MATCH"					return 'MATCH'
"NATUAL"				return 'NATUAL'
"NO"					return 'NO'
"NOT"					return 'NOT'
"NOTNULL"				return 'NOTNULL'
"NULL"					return 'NULL'
"OF"					return 'OF'
"OFFSET"				return 'OFFSET'
"ON"					return 'ON'
"OR"					return 'OR'
"ORDER"					return 'ORDER'
"OUTER"					return 'OUTER'
"PLAN"					return 'PLAN'
"PRAGMA"				return 'PRAGMA'
"PRIMARY"				return 'PRIMARY'
"QUERY"					return 'QUERY'
"RAISE"					return 'RAISE'
"RECURSIVE"				return 'RECURSIVE'
"REFERENCE"				return 'REFERENCE'
"REGEXP"				return 'REGEXP'
"REINDEX"				return 'REINDEX'
"RELEASE"				return 'RELEASE'
"RENAME"				return 'RENAME'
"REPLACE"				return 'REPLACE'
"RESTRICT"				return 'RESTRICT'
"ROLLBACK"				return 'ROLLBACK'
"ROW"					return 'ROW'
"ROWID"					return 'ROWID'
"SAVEPOINT"				return 'SAVEPOINT'
"SELECT"				return 'SELECT'
"SET"					return 'SET'
"TABLE"					return 'TABLE'
"TEMP"					return 'TEMP'
"TEMPORARY"				return 'TEMPORARY'
"THEN"					return 'THEN'
"TO"					return 'TO'
"TRANSACTION"			return 'TRANSACTION'
"TRIGGER"				return 'TRIGGER'
"UNION"					return 'UNION'
"UNIQUE"				return 'UNIQUE'
"UPDATE"				return 'UPDATE'
"USING"					return 'USING'
"VACUUM"				return 'VACUUM'
"VALUES"				return 'VALUES'
"VIEW"					return 'VIEW'
"VIRTUAL"				return 'VIRTUAL'
"WHEN"					return 'WHEN'
"WHERE"					return 'WHERE'
"WITH"					return 'WITH'
"WITHOUT"				return 'WITHOUT'
<<EOF>>                 return 'EOF'

/lex

%start sql-stmt-list EOF

/*
 * user code section
 */
%%

sql-stmt-list
    | sql-stmt
    | sql-stmt-list ';' sql-stmt
    ;

sql-stmt
    : sql-stmt-impl
    | EXPLAIN sql-stmt-impl
    | EXPLAIN QUERY PLAN sql-stmt-impl
    ;

sql-stmt-impl
    : alter-table-stmt
    | analyze-stmt
    | attach-stmt
    | begin-stmt
    | commit-stmt
    | create-index-stmt
    | create-table-stmt
    | create-trigger-stmt
    | create-virtual-table-stmt
    | delete-stmt
    | delete-stmt-limited
    | detach-stmt
    | drop-index-stmt
    | drop-table-stmt
    | drop-trigger-stmt
    | drop-view-stmt
    | insert-stmt
    | pragma-stmt
    | reindex-stmt
    | release-stmt
    | rollback-stmt
    | savepoint-stmt
    | select-stmt
    | update-stmt
    | update-stmt-limited
    | vacuum-stmt
    ;

alter-table-stmt
    : ALTER TABLE ADD column-def
    | ALTER TABLE ADD COLUMN column-def
    | ALTER TABLE table-name-full RENAME TO table-name
    ;

table-name-full
    : table-name
    | database-name '.' table-name
    ;
analyze-stmt
    : ANALYZE
    | ANALYZE database-name
    | ANALYZE table-or-index-name-full
    ;
table-or-index-name-full
    : table-or-index-name
    | database-name '.' table-or-index-name
    ;
attach-stmt
    : ATTACH expr AS database-name
    | ATTACH DATABASE expr AS database-name
    ;

begin-stmt
    : BEGIN TRANSACTION
    | BEGIN DEFERRED TRANSACTION
    | BEGIN IMMEDIATE TRANSACTION
    | BEGIN EXCLUSIVE TRANSACTION
    ;

commit-stmt
    : COMMIT TRANSACTION
    | END TRANSACTION
    ;

rollback-stmt
    : ROLLBACK
    | ROLLBACK TO savepoint-name
    | ROLLBACK TO SAVEPOINT savepoint-name
    | ROLLBACK TRANSACTION
    | ROLLBACK TRANSACTION TO savepoint-name
    | ROLLBACK TRANSACTION TO SAVEPOINT savepoint-name
    ;

savepoint-stmt
    : SAVEPOINT savepoint-name
    ;

release-stmt
    : RELEASE savepoint-name
    | RELEASE SAVEPOINT savepoint-name
    ;

create-index-stmt
    : create-index-prefix index-name-full ON table-name \
        '(' indexed-column-list ')'
    | create-index-prefix index-name-full ON table-name \
        '(' indexed-column-list ')' WHERE expr
    ;
index-name-full
    : index-name
    | database-name '.' index-name
    ;

create-index-prefix
    : CREATE INDEX if-not-exists
    | CREATE UNIQUE INDEX if-not-exists
    ;
if-not-exists
    :
    | IF NOT EXISTS
    ;
indexed-column-list
    : indexed-column
    | indexed-column-list ',' indexed-column
    ;
indexed-column
    : column-name
    | column-name asc-or-desc
    | column-name COLLATE collation-name
    | column-name COLLATE collation-name asc-or-desc
    ;
asc-or-desc
    : ASC
    | DESC
    ;
create-table-stmt
    : CREATE temporary TABLE if-not-exists AS select-stmt
    | CREATE temporary TABLE if-not-exists table-name-full \
        '(' create-table-def-list ')'
    | CREATE temporary TABLE if-not-exists table-name-full \
        '(' create-table-def-list ')' WITHOUT ROWID
    ;
temporary
    :
    | TEMP
    | TEMPORARY
    ;
create-table-def-list
    : column-def-list
    | column-def-list ',' table-constraint-list
    ;

column-def-list
    : column-def
    | column-def-list ',' column-def
    ;
column-def
    : column-name
    | column-name type-name
    | column-name column-constraint-list
    | column-name type-name column-constraint-list
    ;
column-constraint-list
    : column-constraint
    | column-constraint-list column-constraint
    ;
type-name
    : name-list
    | name-list '(' signed-number ')'
    | name-list '(' signed-number ',' signed-number ')'
    ;
signed-number
    : numberic-literal
    | '+' numberic-literal
    | '-' numberic-literal
    ;
name-list
    : name
    | name-list name
    ;
column-constraint
    : column-constraint-impl
    | CONSTRAINT name column-constraint-impl
    ;
column-constraint-impl
    : PRIMARY KEY conflict-clause
    | PRIMARY KEY asc-or-desc conflict-clause
    | PRIMARY KEY conflict-clause AUTOINCREMENT
    | PRIMARY KEY asc-or-desc conflict-clause AUTOINCREMENT
    | NOT NULL conflict-clause
    | UNIQUE conflict-clause
    | CHECK '(' expr ')'
    | DEFAULT signed-number
    | DEFAULT literal-value
    | DEFAULT '(' expr ')'
    | COLLATE collation-name
    | foreign-key-clause
    ;

table-constraint-list
    : table-constraint
    | table-constraint-list ',' table-constraint
    ;
table-constraint
    : table-constraint-impl
    | CONSTRAINT name table-constraint-impl
    ;
table-constraint-impl
    : PRIMARY KEY '(' indexed-column-list ')' conflict-clause
    | UNIQUE '(' indexed-column-list ')' conflict-clause
    | CHECK '(' expr ')'
    | FOREIGN KEY '(' column-name-list ')' foreign-key-clause
    ;
column-name-list
    : column-name
    | column-name-list ',' column-name
    ;

foreign-key-clause
    : REFERENCE foreign-table
    | REFERENCE foreign-table foreign-key-clause-impl
    | REFERENCE foreign-table '(' column-name-list ')' foreign-key-clause-impl
    ;
foreign-key-clause-impl
    : foreign-key-on-match-list
    | foreign-key-deferrable-clause
    | foreign-key-on-match-list foreign-key-deferrable-clause
    ;
foreign-key-on-match-list
    : foreign-key-on-match-item
    | foreign-key-on-match-list foreign-key-on-match-item
    ;
foreign-key-on-match-item
    | MATCH name
    | ON DELETE foreign-key-match-suffix
    | ON UPDATE foreign-key-match-suffix
    ;
foreign-key-match-suffix
    : SET NULL
    | SET DEFAULT
    | CASCADE
    | RESTRICT
    | NO ACTION
    ;
foreign-key-deferrable-clause
    : foreign-key-deferrable-clause-impl
    | NOT foreign-key-deferrable-clause-impl
    ;
foreign-key-deferrable-clause-impl
    : DEFERRABLE
    | DEFERRABLE INITIALLY DEFERRED
    | DEFERRABLE INITIALLY IMMEDIATE
    ;

conflict-clause
    :
    | ON CONFLICT ROLLBACK
    | ON CONFLICT ABORT
    | ON CONFLICT FAIL
    | ON CONFLICT IGNORE
    | ON CONFLICT REPLACE
    ;

create-trigger-stmt
    : CREATE temporary TRIGGER if-not-exists trigger-name-full \
        create-trigger-when create-trigger-condition ON table-name \
        create-trigger-options \
        BEGIN create-trigger-action-list END
    ;
trigger-name-full
    : trigger-name
    | database-name '.' trigger-name
    ;
create-trigger-when
    : BEFORE
    | AFTER
    | INSTEAD OF
    ;
create-trigger-condition
    : DELETE
    | INSERT
    | UPDATE
    | UPDATE OF column-name-list
    ;
create-trigger-options
    :
    | FOR EACH ROW
    | WHEN expr
    | FOR EACH ROW WHEN expr
    ;
create-trigger-action-list
    : create-trigger-action
    | create-trigger-action-list ';' create-trigger-action
    ;
create-trigger-action-action
    : update-stmt
    | insert-stmt
    | delete-stmt
    | select-stmt
    ;

create-view-stmt
    : CREATE temporary VIEW if-not-exists view-name-full AS select-stmt
    ;
view-name-full
    : view-name
    | database-name '.' view-name
    ;

create-virtual-table-stmt
    : CREATE VIRTUAL TABLE if-not-exists table-name-full USING module-name
    | CREATE VIRTUAL TABLE if-not-exists table-name-full USING module-name \
        '(' module-argument-list ')'
    ;
module-argument-list
    : module-argument
    | module-argument-list ',' module-argument
    ;

with-clause
    :
    | WITH with-clause-list
    | WITH RECURSIVE with-clause-list
    ;
with-clause-list
    : cte-table-name AS '(' select-stmt ')'
    | with-clause-list ',' cte-table-name AS '(' select-stmt ')'
    ;
cte-table-name
    : table-name 
    | table-name '(' column-name-list ')'
    ;

recursive-cte
    : cte-table-name AS '(' initial-select UNION recursive-select ')'
    | cte-table-name AS '(' initial-select UNION ALL recursive-select ')'
    ;


delete-stmt
    : with-clause DELETE FROM qualified-table-name
    | with-clause DELETE FROM qualified-table-name WHERE expr
    ;
delete-stmt-limited
    | delete-stmt order-by-clause limit-clause
    ;
order-by-clause
    :
    | order-by-clause-not-null
    ;
order-by-clause-not-null
    : ORDER BY ordering-term-list
    ;
order-term-list
    : ordering-term
    | order-term-list ',' ordering-term
    ;
order-term
    : expr
    | expr asc-or-desc
    | expr COLLATE collation-name
    | expr COLLATE collation-name asc-or-desc
limit-clause
    :
    | limit-clause-not-null
    ;
limit-clause-not-null
    : LIMIT expr
    | LIMIT expr ',' expr
    | LIMIT expr OFFSET expr
    ;

detach-stmt
    : DETACH database-name
    | DETACH DATABASE database-name
    ;

drop-index-stmt
    : DROP INDEX if-exists index-name-full
    ;
if-exists
    :
    | IF EXISTS
    ;

drop-table-stmt
    : DROP TABLE if-exists table-name-full
    ;

drop-trigger-stmt
    : DROP TRIGGER if-exists trigger-name-full
    ;

drop-view-stmt
    : DROP VIEW if-exists view-name-full
    ;

expr
    : literal-value
    | bind-parameter
    | column-name
    | table-name-full '.' column-name
    | unary-operator expr
    | expr binary-operator expr
    | function-name '(' ')'
    | function-name '(' expr-list ')'
    | function-name '(' DISTINCT expr-list ')'
    | function-name '(' '*' ')'
    | '(' expr ')'
    | CAST '(' expr AS type-name ')'
    | expr COLLATE collation-name
    | expr like-glob-regexp-match expr
    | expr NOT like-glob-regexp-match expr
    | expr like-glob-regexp-match expr ESCAPE expr
    | expr NOT like-glob-regexp-match expr ESCAPE expr
    | expr isnull-notnull
    | expr IS expr
    | expr IS NOT expr
    | expr BETWEEN expr AND expr
    | expr NOT BETWEEN expr AND expr
    | expr IN '(' select-stmt ')'
    | expr IN '(' expr-list ')'
    | expr IN table-name-full
    | expr NOT IN '(' select-stmt ')'
    | expr NOT IN '(' expr-list ')'
    | expr NOT IN table-name-full
    | '(' select-stmt ')'
    | EXISTS '(' select-stmt ')'
    | NOT EXISTS '(' select-stmt ')'
    | CASE expr-when-then-list END
    | CASE expr-when-then-list ELSE expr END
    | CASE expr expr-when-then-list END
    | CASE expr expr-when-then-list ELSE expr END
    | raise-function
    ;
expr-list
    : expr
    | expr-list ',' expr
    ;
like-glob-regexp-match 
    : LIKE
    | GLOB
    | REGEXP
    | MATCH
    ;
isnull-notnull
    : ISNULL
    | NOTNULL
    | NOT NULL
    ;
expr-when-then-list 
    : WHEN expr THEN expr
    | expr-when-then-list WHEN expr THEN expr
    ; 
raise-function
    : RAISE '(' IGNORE ')'
    | RAISE '(' ROLLBACK ',' error-message ')'
    | RAISE '(' ABORT ',' error-message ')'
    | RAISE '(' FAIL ',' error-message ')'
    ;

literal-value
    : numeric-literal
    | string-literal
    | blob-literal
    | NULL
    | CURRENT_TIME
    | CURRENT_DATE
    | CURRENT_TIMESTAMP
    ;
numeric-literal
    : decimal-numberic-literal
    | decimal-numberic-literal 'E' '+' DIGIT-LIST
    | decimal-numberic-literal 'E' '-' DIGIT-LIST
    | '0x' HEXDIGIT-LIST
    ;
decimal-numeric-literal
    : DIGIT-LIST
    | DIGIT-LIST '.' DIGIT-LIST
    | '.' DIGIT-LIST
    ;

insert-stmt
    : insert-stmt-prefix VALUES value-group-list
    | insert-stmt-prefix select-stmt
    | insert-stmt-prefix DEFAULT VALUES
    ;
insert-stmt-prefix
    : with-clause insert-stmt-action INTO table-name-full
    | with-clause insert-stmt-action INTO table-name-full '(' column-name-list ')' 
    ;
insert-stmt-action
    : INSERT or-clause
    | REPLACE
    ;
or-clause
    :
    | OR REPLACE
    | OR ROLLBACK
    | OR ABORT
    | OR FAIL
    | OR IGNORE
    ;
value-group-list
    : '(' expr-list ')'
    | value-group-list ',' '(' expr-list ')'
    ;

pragma-stmt
    : PRAGMA pragma-name-full
    | PRAGMA pragma-name-full '=' pragma-value
    | PRAGMA pragma-name-full '(' pragma-value ')
    ;
pragma-name-full
    : pragma-name
    | database-name '.' pragma-name
    ;
pragma-value
    : signed-number
    | name
    | string-literal
    ;

reindex-stmt
    : REINDEX
    | REINDEX collation-name
    | REINDEX table-name-full
    | REINDEX index-name-full
    ;

select-stmt
    : with-common-table-clause select-core-list order-by-clause limit-clause
    ;
with-common-table-clause
    :
    | WITH common-table-expression-list
    | WITH RECURSIVE common-table-expression-list
    ;
common-table-expression-list
    : common-table-expression
    | common-table-expression-list ',' common-table-expression
    ;
common-table-expression
    : table-name AS '(' select-stmt ')'
    | table-name '(' column-name-list ')' AS '(' select-stmt ')'
    ;
select-core-list
    : select-core
    | select-core-list component-operator select-core
    ;
component-operator
    : UNION
    | UNION ALL
    | INTERSECT
    | EXCEPT
    ;
select-core
    : SELECT select-range result-column-list from-clause where-clause \
        group-by-clause
    | VALUES value-group-list
    ;
select-range
    :
    | DISTINCT
    | ALL
    ;
result-column-list
    : result-column
    | result-column-list ',' result-column
    ;
result-column
    : '*'
    | table-name '.' '*'
    | expr
    | expr column-alias
    | expr AS column-alias
    ;
from-clause
    :
    | FROM table-or-subquery-list
    | FROM join-clause
    ;
table-or-subquery-list
    : table-or-subquery
    | table-or-subquery-list ',' table-or-subquery
    ;
where-clause
    :
    | WHERE expr
    ;
group-by-clause
    :
    | GROUP BY expr-list
    | GROUP BY expr-list HAVING expr
    ;
join-clause
    : table-or-subquery
    | table-or-subquery join-operator table-or-subquery join-constraint
    ;
join-operator
    : ','
    | join-direction-clause JOIN
    | NATUAL join-direction-clause JOIN
    ;
join-direction-clause
    :
    | LEFT
    | LEFT OUTER
    | INNER
    | CROSS
    ;
join-constraint
    :
    | ON expr
    | USING '(' column-name-list ')'
    ;
table-or-subquery
    : table-name-full as-table-alias indexed-by-or-not
    | '(' table-or-subquery-list ')'
    | '(' join-clause ')'
    | '(' select-stmt ')' as-table-alias
    ;
as-table-alias
    :
    | table-alias
    | AS table-alias
    ;
indexed-by-or-not
    :
    | INDEXED BY index-name
    | NOT INDEXED
    ;
/*
forced-select-stmt
    : select-stmt
    ;
compound-select-stmt
    : select-stmt
    ;
 */
simple-select-stmt
    : with-common-table-clause select-core order-by-clause limit-clause
    ;

update-stmt
    : with-clause UPDATE or-clause qualified-table-name SET \
        update-column-list update-where-clause
    ;
update-column-list
    : column-name '=' expr
    | update-column-list ',' column-name '=' expr
    ;
update-where-clause
    :
    | WHERE expr
    ;
update-stmt-limited
    : update-stmt
    | update-stmt order-by-clause-not-null limit-clause-not-null
    ;

qualified-table-name
    : table-name-full index-by-or-not
    ;

vacuum-stmt
    : VACUUM
    ;

comment-syntax
    : '--' newline
    | '--' EOF
    | '--' anything-except-newline newline
    | '--' anything-except-newline EOF
    | '/*' '*/'
    | '/*' EOF
    | '/*' anything-except-star-slash '*/'
    | '/*' anything-except-star-slash EOF
    ;




