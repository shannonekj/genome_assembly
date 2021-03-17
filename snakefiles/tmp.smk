rule all:
    input: 'tmp.fofn'

#rule words:
#    output:
#        a = 'hello',
#        b = 'world',
#        c = 'nice to see you'

rule ipa_make_fofn:
    params:
        a = 'hello\n',
        b = 'world\n',
        c = 'nice to see you\n'
    output:
        'tmp.fofn'
    shell:'''
        echo "{params}" > {output}
        #echo "{params.b}" >> {output}
        #echo "{params.c}" >> {output}
        '''
