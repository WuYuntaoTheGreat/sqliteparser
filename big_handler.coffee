# vim: set nu ai et ts=4 sw=4:
#
full_nm_name = (nm, dbnm)->
    if !nm || !nm.value
        result = null
    else if dbnm && dbnm.nm && dbnm.nm.value
        result = nm.value + "." + dbnm.nm.value
    else
        result = nm.value
    result

ssubstring = (str, start, end)->
    if end > 0
        str.substring start, end
    else
        str.substring start, str.length + end

module.exports =
    ecmd: (explain, cmd)->
        explain ?= null
        cmd ?= null
        $ =
            node: 'ecmd'
            explain: explain
            cmd: cmd
    explain: (explain, queryPlan)->
        $ =
            node: 'explain'
            explain: explain
            queryPlan: queryPlan

    nm: (raw, type, terminal)->
        terminal ?= null
        value = if terminal then terminal.value else null
        $ =
            node: 'nm'
            raw: raw
            type: type
            value: value
            terminal: terminal

    dbnm: (nm)->
        $ =
            node: 'dbnm'
            nm: nm

    trans_opt: (nm)->
        nm ?= null
        $ =
            node: 'trans_opt'
            value: nm

    transtype: (type)->
        type ?= null
        $ =
            node: 'transtype'
            type: type

    ########################################
    # The commands
    ########################################
    cmd:
        vacuum: (nm)->
            nm ?= null
            $ =
                node: 'cmd'
                type: 'vacuum'
                nm: nm
        begin_trans: (transtype, trans_opt)->
            $ =
                node: 'begin_trans'
                transtype: transtype
                trans_opt: trans_opt
        commit_trans: (trans_opt)->
            $ =
                node: 'commit_trans'
                trans_opt: trans_opt
        end_trans: (trans_opt)->
            $ =
                node: 'end_trans'
                trans_opt: trans_opt
        reindex: (nm, dbnm)->
            nm ?= null
            dbnm ?= null
            $ =
                node: 'reindex'
                nm: nm
                dbnm: dbnm
                nm_full: full_nm_name nm, dbnm

    ########################################
    # The terminals with values
    ########################################
    terminal:
        id: (value)->
            $ =
                node: 'ID'
                raw: value
                value: ssubstring value, 1, -1
        string: (value)->
            $ =
                node: 'STRING'
                value: ssubstring value, 1, -1
        integer: (value)->
            $ =
                node: 'INTEGER'
                raw: value
                value: parseInt value
        float: (value)->
            $ =
                node: 'FLOAT'
                raw: value
                value: parseFloat value
        variable: (value)->
            $ =
                node: 'VARIABLE'
                raw: value
                position: parseInt ssubstring value, 1, 0
        blob: (value)->
            $ =
                node: 'BLOB'
                raw: value
                value: ssubstring value, 2, -1
        join_kw: (value)->
            $ =
                node: 'JOIN_KW'
                type: value

                    


