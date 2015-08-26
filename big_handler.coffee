
ssubstring = (str, start, end)->
    if end > 0
        str.substring start, end
    else
        str.substring start, str.length + end

module.exports =
    ecmd: (explain, cmd)->
        $ =
            node: 'ecmd'
            isTerminal: false
            explain: explain
            cmd: cmd
    explain: (explain, queryPlan)->
        $ =
            node: 'explain'
            isTerminal: false
            explain: explain
            queryPlan: queryPlan

    nm: (raw, type, value)->
        $ =
            node: 'nm'
            isTerminal: false
            raw: raw
            type: type
            value: value

    ########################################
    # The commands
    ########################################
    cmd:
        vacuum: (nm)->
            $ =
                node: 'cmd'
                isTerminal: false
                type: 'vacuum'
                nm: nm


    ########################################
    # The terminals with values
    ########################################
    terminal:
        id: (value)->
            $ =
                node: 'ID'
                isTerminal: true
                raw: value
                value: ssubstring value, 1, -1
        string: (value)->
            $ =
                node: 'STRING'
                isTerminal: true
                value: ssubstring value, 1, -1
        integer: (value)->
            $ =
                node: 'INTEGER'
                isTerminal: true
                raw: value
                value: parseInt value
        float: (value)->
            $ =
                node: 'FLOAT'
                isTerminal: true
                raw: value
                value: parseFloat value
        variable: (value)->
            $ =
                node: 'VARIABLE'
                isTerminal: true
                raw: value
                position: parseInt ssubstring value, 1, 0
        blob: (value)->
            $ =
                node: 'BLOB'
                isTerminal: true
                raw: value
                value: ssubstring value, 2, -1
        join_kw: (value)->
            $ =
                node: 'JOIN_KW'
                isTerminal: true
                type: value

                    


