# vim: set nu ai et ts=4 sw=4:
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
    ifexists: (ifexists)->
        $$ =
            node: 'ifexists'
            ifexists: ifexists
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



