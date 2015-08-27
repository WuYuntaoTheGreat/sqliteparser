# vim: set nu ai et ts=4 sw=4 cc=80:
#

ssubstring = (str, start, end)->
    if end > 0
        str.substring start, end
    else
        str.substring start, str.length + end

module.exports = G =
    ecmd: (explain, cmd)->
        explain ?= null
        cmd ?= null
        $$ =
            node: 'ecmd'
            explain: explain
            cmd: cmd
    explain: (explain, queryPlan)->
        $$ =
            node: 'explain'
            explain: explain
            queryPlan: queryPlan

    nm: (subnode, type)->
        switch type
            when 'ID'       then value = subnode.value
            when 'STRING'   then value = subnode.value
            when 'JOIN_KW'  then value = subnode.type
            else
                value = null
        $$ =
            node: 'nm'
            type: type
            value: value
            subnode: subnode

    dbnm: (nm)->
        $$ =
            node: 'dbnm'
            nm: nm

    nmnum: (type, subnode)->
        if 'PLUS_NUM' == type or 'NM' == type
            value = subnode.value
        else
            value = type
        $$ =
            node: 'nmnum'
            type: type
            subnode: subnode
            value: value

    trans_opt: (nm)->
        nm ?= null
        $$ =
            node: 'trans_opt'
            value: nm

    transtype: (type)->
        type ?= null
        $$ =
            node: 'transtype'
            type: type

    fullname: (nm, dbnm)->
        nm ?= null
        dbnm ?= null
        if !nm || !nm.value
            value = null
        else if dbnm && dbnm.nm && dbnm.nm.value
            value = nm.value + "." + dbnm.nm.value
        else
            value = nm.value
        $$ =
            node: "nm_full"
            nm: nm
            dbnm: dbnm
            value: value
    ifexists: (value)->
        $$ =
            node: 'ifexists'
            value: value
    ifnotexists: (value)->
        $$ =
            node: 'ifnotexists'
            value: value
    temp: (value)->
        $$ =
            node: 'temp'
            value: value

    column: (columnid, type, carglist)->
        $$ =
            node: 'column'
            columnid: columnid
            type: type
            carglist: carglist
    typetoken: (typename, param1, param2)->
        param1 ?= null
        param2 ?= null
        $$ =
            node: 'typetoken'
            param1: param1
            param2: param2

    term: (type, subnode)->
        subnode ?= null
        if 'NULL' == type
            value = type
        else
            value = subnode.value
        $$ =
            node: 'term'
            subnode: subnode
            value: value
    autoinc: (value)->
        $$ =
            node: 'autoinc'
            value: value

    idx_item: (nm, collate, sortorder)->
        $$ =
            node: 'idx_item'
            nm: nm
            collate: collate
            sortorder: sortorder
    collate: (subnode)->
        subnode ?= null
        value = if subnode then subnode.value else null
        $$ =
            node: 'collate'
            subnode: subnode
            value: value
    sortorder: (value)->
        value ?= null
        $$ =
            node: 'sortorder'
            value: value
    onconf: (resolvetype)->
        resolvetype ?= null
        $$ =
            node: 'onconf'
            resolvetype: resolvetype
    orconf: (resolvetype)->
        resolvetype ?= null
        $$ =
            node: 'orconf'
            resolvetype: resolvetype
    raisetype: (value)->
        $$ =
            node: 'raisetype'
            value: value
    resolvetype: (value)->
        $$ =
            node: 'resolvetype'
            value: value
    refarg_match: (nm)->
        $$ =
            node: 'refarg'
            type: 'match'
            nm: nm
    refargs: (event, act)->
        $$ =
            node: 'refarg'
            type: 'on'
            event: event
            act: act
    defer_subclause: (no_defer, init_opt)->
        $$ =
            node: 'defer_subclause'
            no_defer: no_defer
            init_opt: init_opt

    table_options: (nm)->
        nm ?= null
        $$ =
            node: 'table_options'
            without: nm

    create_table_args_as: (nm)->
        $$ =
            node: 'create_table_args'
            type: 'as'
            as: nm
    create_table_args: (columnlist, conslist, table_options)->
        $$ =
            node: 'create_table_args'
            type: 'normal'
            columnlist: columnlist
            conslist: conslist
            table_options: table_options
    distinct: (value)->
        value ?= null
        $$ =
            node: 'distinct'
            value: value

    create_table: (temp, ifnotexists, fullname)->
        $$ =
            node: 'create_table'
            temp: temp
            ifnotexists: ifnotexists
            fullname: fullname
    select: (_with, selectnowith)->
        $$ =
            node: 'select'
            with: _with
            selectnowith: selectnowith
    with: (recursive, wqlist)->
        $$ =
            node: 'with'
            recursive: recursive
            wqlist: wqlist
    wqlist_item: (nm, idxlist, select)->
        $$ =
            node: 'wqlist_item'
            nm: nm
            idxlist: idxlist
            select: select
    uniqueflag: (value)->
        $$ =
            node: 'uniqueflag'
            value: value

    ########################################
    # tcons, Table Creation Options
    ########################################
    tcons:
        constraint: (nm)->
            $$ =
                node: 'tcons'
                type: 'constraint'
                nm: nm
        primary_key: (idxlist, autoinc, onconf)->
            $$ =
                node: 'tcons'
                type: 'primary_key'
                idxlist: idxlist
                autoinc: autoinc
                onconf: onconf
        unique: (idxlist, onconf)->
            $$ =
                node: 'tcons'
                type: 'unique'
                idxlist: idxlist
                onconf: onconf
        check: (expr, onconf)->
            $$ =
                node: 'tcons'
                type: 'check'
                expr: expr
                onconf: onconf
        foreign_key: (idxlist, foreign_table, \
                      foreign_idxlist, refargs, defer_subclause)->
            $$ =
                node: 'tcons'
                type: 'foreign_key'
                idxlist: idxlist
                foreign_table: foreign_table
                foreign_idxlist: foreign_idxlist
                refargs: refargs
                defer_subclause: defer_subclause


    ########################################
    # The commands
    ########################################
    cmd:
        vacuum: (nm)->
            nm ?= null
            $$ =
                node: 'cmd'
                type: 'vacuum'
                nm: nm
        begin_trans: (transtype, trans_opt)->
            $$ =
                node: 'cmd'
                type: 'begin_trans'
                transtype: transtype
                trans_opt: trans_opt
        commit_trans: (trans_opt)->
            $$ =
                node: 'cmd'
                type: 'commit_trans'
                trans_opt: trans_opt
        end_trans: (trans_opt)->
            $$ =
                node: 'cmd'
                type: 'end_trans'
                trans_opt: trans_opt
        rollback_trans: (trans_opt)->
            $$ =
                node: 'cmd'
                type: 'rollback_trans'
                trans_opt: trans_opt
        savepoint: (nm)->
            $$ =
                node: 'cmd'
                type: 'savepoint'
                nm: nm
        release_savepoint: (nm)->
            $$ =
                node: 'cmd'
                type: 'release_savepoint'
                nm: nm
        rollback_savepoint: (trans_opt, nm)->
            $$ =
                node: 'cmd'
                type: 'rollback_savepoint'
                trans_opt: trans_opt
                nm: nm
        drop_table: (ifexists, fullname)->
            $$ =
                node: 'cmd'
                type: 'drop_table'
                ifexists: ifexists
                fullname: fullname
        drop_view: (ifexists, fullname)->
            $$ =
                node: 'cmd'
                type: 'drop_view'
                ifexists: ifexists
                fullname: fullname
        drop_index: (ifexists, fullname)->
            $$ =
                node: 'cmd'
                type: 'drop_index'
                ifexists: ifexists
                fullname: fullname
        drop_trigger: (ifexists, fullname)->
            $$ =
                node: 'cmd'
                type: 'drop_trigger'
                ifexists: ifexists
                fullname: fullname
        create_table: (create, args)->
            $$ =
                node: 'cmd'
                type: 'create_table'
                create: create
                args: args

        pragma: (key, operator, value)->
            operator ?= null
            value ?= null
            $$ =
                node: 'cmd'
                type: 'pragma'
                key: key
                operator: operator
                value: value

        reindex: (fullname)->
            $$ =
                node: 'cmd'
                type: 'reindex'
                fullname: fullname
        analyze: (fullname)->
            $$ =
                node: 'cmd'
                type: 'analyze'
                fullname: fullname

        alter_add_column: (tablename, column)->
            $$ =
                node: 'cmd'
                type: 'alter_add_column'
                tablename: tablename
                column: column
        alter_rename: (tablename, newname)->
            $$ =
                node: 'cmd'
                type: 'alter_rename'
                tablename: tablename
                newname: newname
        create_vtab: (ifnotexists, fullname, module_name)->
            $$ =
                node: 'cmd'
                type: 'create_vtab'
                ifnotexists: ifnotexists
                fullname: fullname
                module_name: module_name
                arglist: []


    ########################################
    # The terminals with values
    ########################################
    terminal:
        id: (value)->
            if value.match /^['`\[]/
                value = ssubstring value, 1, -1
            $$ =
                node: 'ID'
                raw: value
                value: value
        string: (value)->
            $$ =
                node: 'STRING'
                value: ssubstring value, 1, -1
        integer: (value)->
            $$ =
                node: 'INTEGER'
                raw: value
                value: parseInt value
                toNegative: ()->
                    @raw = "-" + @raw
                    @value = - @value
                    this
        float: (value)->
            $$ =
                node: 'FLOAT'
                raw: value
                value: parseFloat value
                toNegative: ()->
                    @raw = "-" + @raw
                    @value = - @value
                    this
        variable: (value)->
            position = null
            name = null
            if value != undefined
                if '?' == value[0]
                    position = parseInt ssubstring value, 1, 0
                else
                    name = ssubstring value, 1, 0
            $$ =
                node: 'VARIABLE'
                raw: value
                position: position
                name: name

        blob: (value)->
            $$ =
                node: 'BLOB'
                raw: value
                value: ssubstring value, 2, -1
        join_kw: (value)->
            $$ =
                node: 'JOIN_KW'
                type: value
        like_kw: (value)->
            $$ =
                node: 'LIKE_KW'
                type: value
        ctime_kw: (value)->
            $$ =
                node: 'CTIME_KW'
                type: value



