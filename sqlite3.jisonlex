/* vim: set nu ai et ts=4 sw=4 ft=lex: */
%{
%}

%x C_COMMENT
%%

[ \t\f\n\r]     /* Ignored white space */
"--"[^\n]*\n    /* Ignored line comments */

"/*"            { this.begin('C_COMMENT'); }
<C_COMMENT>"*/" { this.begin('INITIAL'); }
<C_COMMENT>.    /* Ignored block comments */
<C_COMMENT>\n   /* Ignored block comments */


";"             return "SEMI";

"<>"            return "NE";
"!="            return "NE";
"="             return "EQ";
"<<"            return "LSHIFT";
">>"            return "RSHIFT";
">="            return "GE";
">"             return "GT";
"<="            return "LE";
"<"             return "LT";
"&"             return "BITAND";
"+"             return "PLUS";
"-"             return "MINUS";
"*"             return "STAR";
"/"             return "SLASH";
"%"             return "REM";
"||"            return "CONCAT";
"|"             return "BITOR";
"~"             return "BITNOT";

"("             return "LP";
")"             return "RP";
","             return "COMMA";

"EXPLAIN"       return "EXPLAIN";
"QUERY"         return "QUERY";
"PLAN"          return "PLAN";
"BEGIN"         return "BEGIN";
"TRANSACTION"   return "TRANSACTION";
"DEFERRED"      return "DEFERRED";
"IMMEDIATE"     return "IMMEDIATE";
"EXCLUSIVE"     return "EXCLUSIVE";
"COMMIT"        return "COMMIT";
"END"           return "END";
"ROLLBACK"      return "ROLLBACK";
"SAVEPOINT"     return "SAVEPOINT";
"RELEASE"       return "RELEASE";
"TO"            return "TO";
"TABLE"         return "TABLE";
"CREATE"        return "CREATE";
"IF"            return "IF";
"NOT"           return "NOT";
"EXISTS"        return "EXISTS";

"TEMP"          return "TEMP"; /* TEMP */
"TEMPORARY"     return "TEMP"; /* TEMP */

"AS"            return "AS";
"WITHOUT"       return "WITHOUT";


"INDEXED"       return "INDEXED";
"ABORT"         return "ABORT";
"ACTION"        return "ACTION";
"AFTER"         return "AFTER";
"ANALYZE"       return "ANALYZE";
"ASC"           return "ASC";
"ATTACH"        return "ATTACH";
"BEFORE"        return "BEFORE";
"BY"            return "BY";
"CASCADE"       return "CASCADE";
"CAST"          return "CAST";
"COLUMN"        return "COLUMNKW"; /* AWARE: Different than terminal name. */
"CONFLICT"      return "CONFLICT";
"DATABASE"      return "DATABASE";
"DESC"          return "DESC";
"DETACH"        return "DETACH";
"EACH"          return "EACH";
"FAIL"          return "FAIL";
"FOR"           return "FOR";
"IGNORE"        return "IGNORE";
"INITIALLY"     return "INITIALLY";
"INSTEAD"       return "INSTEAD";
"MATCH"         return "MATCH";
"NO"            return "NO";
"KEY"           return "KEY";
"OF"            return "OF";
"OFFSET"        return "OFFSET";
"PRAGMA"        return "PRAGMA";
"RAISE"         return "RAISE";
"RECURSIVE"     return "RECURSIVE";
"REPLACE"       return "REPLACE";
"RESTRICT"      return "RESTRICT";
"ROW"           return "ROW";
"TRIGGER"       return "TRIGGER";
"VACUUM"        return "VACUUM";
"VIEW"          return "VIEW";
"VIRTUAL"       return "VIRTUAL";
"WITH"          return "WITH";
"REINDEX"       return "REINDEX";
"RENAME"        return "RENAME";

"CURRENT_DATE"  return "CTIME_KW"; /* CTIME_KW */
"CURRENT_TIME"  return "CTIME_KW"; /* CTIME_KW */
"CURRENT_TIMESTAMP" {
                return "CTIME_KW"; /* CTIME_KW */
                }

"ANY"           return "ANY";
"OR"            return "OR";
"AND"           return "AND";
"IS"            return "IS";
"BETWEEN"       return "BETWEEN";
"IN"            return "IN";
"ISNULL"        return "ISNULL";
"NOTNULL"       return "NOTNULL";
"ESCAPE"        return "ESCAPE";
"COLLATE"       return "COLLATE";


"CONSTRAINT"    return "CONSTRAINT";
"DEFAULT"       return "DEFAULT";
"NULL"          return "NULL";
"PRIMARY"       return "PRIMARY";
"UNIQUE"        return "UNIQUE";
"CHECK"         return "CHECK";
"REFERENCES"    return "REFERENCES";
"AUTOINCREMENT" return "AUTOINCR"; /* AWARE: Different than terminal name. */
"ON"            return "ON";
"INSERT"        return "INSERT";
"DELETE"        return "DELETE";
"UPDATE"        return "UPDATE";
"SET"           return "SET";
"DEFERRABLE"    return "DEFERRABLE";
"FOREIGN"       return "FOREIGN";
"DROP"          return "DROP";
"UNION"         return "UNION";
"ALL"           return "ALL";
"EXCEPT"        return "EXCEPT";
"INTERSECT"     return "INTERSECT";
"SELECT"        return "SELECT";
"VALUES"        return "VALUES";
"DISTINCT"      return "DISTINCT";

"FROM"          return "FROM";
"JOIN"          return "JOIN";
"USING"         return "USING";
"ORDER"         return "ORDER";
"GROUP"         return "GROUP";
"HAVING"        return "HAVING";
"LIMIT"         return "LIMIT";
"WHERE"         return "WHERE";
"INTO"          return "INTO";

"CASE"          return "CASE";
"WHEN"          return "WHEN";
"THEN"          return "THEN";
"ELSE"          return "ELSE";
"INDEX"         return "INDEX";
"ALTER"         return "ALTER";
"ADD"           return "ADD";

"GLOB"          return "LIKE_KW"; /* LIKE_KW */
"LIKE"          return "LIKE_KW"; /* LIKE_KW */
"REGEXP"        return "LIKE_KW"; /* LIKE_KW */

"CROSS"         return "JOIN_KW"; /* JOIN_KW */
"FULL"          return "JOIN_KW"; /* JOIN_KW */
"INNER"         return "JOIN_KW"; /* JOIN_KW */
"LEFT"          return "JOIN_KW"; /* JOIN_KW */
"NATURAL"       return "JOIN_KW"; /* JOIN_KW */
"OUTER"         return "JOIN_KW"; /* JOIN_KW */
"RIGHT"         return "JOIN_KW"; /* JOIN_KW */

[0-9]*\.[0-9]+([Ee][\+\-]?[0-9]+)?  { /* Position matters */
                return "FLOAT";     }
0[xX][0-9A-Fa-f]+                   {
                return "INTEGER";   }
[0-9]+([Ee][\+\-]?[0-9]+)?          {
                return "INTEGER";   }
"."             return "DOT"; /* AWARE: conflict with FLOAT, must after it. */

[xX]\'[^\']+\'  return "BLOB"; /* Ommit that (length % 2 == 0) */
"?"[0-9]*       return "VARIABLE";
[:@\$][_A-Za-z][_A-Za-z0-9]+        {
                return "VARIABLE";  }

"'"[^']*"'"     return "STRING";
"\""[^"]*"\""   return "ID";
"`"[^`]*"`"     return "ID";
"["[^\]]*"]"    return "ID";
[_A-Za-z][_A-Za-z0-9]+              {
                return "ID";        }

<<EOF>>         return "EOF";

