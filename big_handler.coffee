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

    nm: (raw, type, terminal)->
        terminal ?= null
        value = if terminal then terminal.value else null
        $$ =
            node: 'nm'
            raw: raw
            type: type
            value: value
            terminal: terminal

    dbnm: (nm)->
        $$ =
            node: 'dbnm'
            nm: nm

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
        float: (value)->
            $$ =
                node: 'FLOAT'
                raw: value
                value: parseFloat value
        variable: (value)->
            $$ =
                node: 'VARIABLE'
                raw: value
                position: parseInt ssubstring value, 1, 0
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



