
ssubstring = (str, start, end)->
    if end > 0
        str.substring start, end
    else
        str.substring start, str.length + end

module.exports =
    ecmd: (thiz, explain, cmd)->
        thiz.$ =
            nt_name: 'ecmd'
            explain: explain
            cmd: cmd
    explain: (thiz, explain, queryPlan)->
        thiz.$ =
            nt_name: 'explain'
            explain: explain
            queryPlan: queryPlan
    cmd:
        vacuum: (thiz, nm)->
            thiz.$ =
                nt_name: 'cmd.vaccum'
                nm: nm

    terminal:
        dot: (thiz)->
            thiz.$ =
                nt_name: 'DOT'
        id: (thiz, value)->
            thiz.$ =
                nt_name: 'ID'
                raw: value
                value: ssubstring value, 1, -1
        string: (thiz, value)->
            thiz.$ =
                nt_name: 'STRING'
                value: ssubstring value, 1, -1
        integer: (thiz, value)->
            thiz.$ =
                nt_name: 'INTEGER'
                raw: value
                value: parseInt value
        float: (thiz, value)->
            thiz.$ =
                nt_name: 'FLOAT'
                raw: value
                value: parseFloat value
        variable: (thiz, value)->
            thiz.$ =
                nt_name: 'VARIABLE'
                raw: value
                position: parseInt ssubstring value, 1, 0
        blob: (thiz, value)->
            thiz.$ =
                nt_name: 'BLOB'
                raw: value
                value: ssubstring value, 2, -1


