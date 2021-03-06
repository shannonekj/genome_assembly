# this is a snakefile for carrying out the assembly of:
# Species: Hypomesus transpacificus (delta smelt)
# Sex: female
# Data: -PacBio hifi
#       -10X Genomics linked reads (illumina)
#       -Phase hic (illumina)
#       -linkage map (Lew et al. 2015)

###############
###  SETUP  ###
###############
# override this with --configfile on command line
configfile: 'docs/conf_data_F.yml'

## load in configuration things
### general info
sex = config['sex']
species_id = config['speciesID']
genome_size = config['genomesize']

### raw data
hifi_a = config['hifi_a']
hifi_b = config['hifi_b']
hifi_c = config['hifi_c']
tenx_r1 = config['tenx_r1']
tenx_r2 = config['tenx_r2']
hic_r1 = config['hic_r1']
hic_r2 = config['hic_r2']

### other file inputs
lg_loci = config['lg_loci']
lg_tsv = config['lg_tsv']

### software
salsa_path = config['salsa_path']
chrmnmr_path = config['chromonomer_path']

### parameters
#### salsa2
i = config['i']

#### arima
scratch_dir = config['scratch_dir']
map_quality = config['mapq']
cpu = config['cpu']

# other
prefix = species_id + '_' + sex



###############
###  r00lz  ###
###############
rule all_F:
    input:
        prefix + '.fa'


## ipa
rule ipa_make_fofn:
    input:
        a = hifi_a,
        b = hifi_b,
        c = hifi_c
    output:
        's1_ipa/ipa_input.fofn'
    shell:'''
        echo {input.a} > {output}        
        echo {input.b} >> {output}
        echo {input.c} >> {output}
        '''

rule ipa_run:
    input:
        's1_ipa/ipa_input.fofn'
    output:
        's1_ipa/RUN/assembly-results/final.a_ctg.fasta',
        's1_ipa/RUN/assembly-results/final.p_ctg.fasta' 
    conda: 'ipa.yml'
    threads: workflow.cores * 0.9
    shell:'''
        ipa local --input-fn {input} --nthreads {threads} --verbose --njobs {threads} --tmp-dir s1_ipa --resume
        '''

rule ipa_symlink_asm:
    input:
        's1_ipa/ipa_input.fofn'
    output:
        's1_ipa/' + prefix + '.ipa.fasta'
    shell:'''
        if [ -h {output} ]; then rm {output}; ln -s {input} {output}; else ln -s {input} {output}; fi
        '''


## scaff10x
rule scaff10x_symlink_ipa_asm:
    input:
        's1_ipa/' + prefix + '.ipa.fasta'
    output:
        's2_scaff10x/' + prefix + '.ipa.fasta'
    shell:'''
        if [ -h {output} ]; then rm {output}; ln -s {input} {output}; else ln -s {input} {output}; fi
        '''

rule scaff10x_make_inputdat:
    input:
        tnx_r1 = tenx_r1,
        tnx_r2 = tenx_r2
    output:
        's2_scaff10x/input.dat'
    shell:'''
        echo q1={input.tnx_r1} > {output}
        echo q2={input.tnx_r2} >> {output}
        '''

rule scaff10x_run:
    input:
        fofn = 's2_scaff10x/input.dat',
        ipa_asm = 's2_scaff10x/' + prefix + '.ipa.fasta'
    output:
        's2_scaff10x/' + prefix + '.scf.fasta',
    params:
    threads: workflow.cores * 0.9
    conda: 'scaffold_10x.yml'
    shell:'''
        scaff10x -nodes {threads} -longread 1 -gap 100 -matrix 2000 -reads 10 -link 8 -score 20 -edge 50000 -block 50000 -data {input.fofn} {input.ipa_asm} {output}
        '''


## SALSA2
### arima mapping
rule salsa_am_1_idx:
    input:
        's2_scaff10x/' + prefix + '.scf.fasta'
    output:
        's2_scaff10x/' + prefix + '.scf.fasta.sa'
    params:
        prefix = prefix
    conda: 'arima.yml'
    shell:'''
        bwa index -a bwtsw -p {params.prefix} {input}
        '''

rule salsa_am_2_fastq_to_bam:
    input:
        fq1 = hic_r1,
        fq2 = hic_r2,
        ref = 's2_scaff10x/' + prefix + '.scf.fasta.sa'
    output:
        bam1 = 's3_salsa2/arima/01_raw_bams/' + prefix + '_1.bam',
        bam2 = 's3_salsa2/arima/01_raw_bams/' + prefix + '_2.bam'
    params:
        cpu = cpu
    conda: 'arima.yml'
    shell:'''
        bwa mem -t {params.cpu} {input.ref} {input.fq1} | samtools view -@ {params.cpu} -Sb - > {output.bam1}
        bwa mem -t {params.cpu} {input.ref} {input.fq2} | samtools view -@ {params.cpu} -Sb - > {output.bam2}
        '''

rule salsa_am_3_filter_five_prime:
    input:
        bam1 = 's3_salsa2/arima/01_raw_bams/' + prefix + '_1.bam',
        bam2 = 's3_salsa2/arima/01_raw_bams/' + prefix + '_2.bam'
    output:
        bam1 = 's3_salsa2/arima/02_filt_bams/' + prefix + '_1.filtered.bam',
        bam2 = 's3_salsa2/arima/02_filt_bams/' + prefix + '_2.filtered.bam'
    params:
        script = 'scripts/arima_mapping/filter_five_end.pl'
    conda: 'arima.yml'
    shell:'''
        samtools view -h {input.bam1} | perl {params.script} | samtools view -Sb - > {output.bam1}
        samtools view -h {input.bam2} | perl {params.script} | samtools view -Sb - > {output.bam2}
        '''

rule salsa_am_4_pair_and_map_filt:
    input: 
        bam1 = 's3_salsa2/arima/02_filt_bams/' + prefix + '_1.filtered.bam',
        bam2 = 's3_salsa2/arima/02_filt_bams/' + prefix + '_2.filtered.bam',
        ref = 's2_scaff10x/' + prefix + '.scf.fasta'
    output:
        scratch_dir + '/' + prefix + '.paired.bam'
    params:
        script = 'scripts/arima_mapping/two_read_bam_combiner.pl',
        cpu = cpu,
        map_q_filter = map_quality
    conda: 'arima.yml'
    shell:'''
        SAMTOOLS=$(which samtools)
        perl {params.script} {input.bam1} {input.bam2} $SAMTOOLS {params.map_q_filter} | samtools view -bS -t {input.ref}.fai - | samtools sort -@ {params.cpu} -o {output} -
        '''

rule salsa_am_5_add_read_group:
    input: 
        scratch_dir + '/' + prefix + '.paired.bam'
    output:
        's3_salsa2/arima/03_pair_bams/' + prefix + '_rep1.grouped.bam'
    params:
        id = prefix,
        lb = prefix,
        sm = prefix + '_label'
    conda: 'arima.yml'
    shell:'''
        picard AddOrReplaceReadGroups INPUT={input} OUTPUT={output} ID={params.id} LB={params.lb} SM={params.sm} PL=ILLUMINA PU=none
        '''

rule salsa_am_6_mark_dup:
    input:
        's3_salsa2/arima/03_pair_bams/' + prefix + '_rep1.grouped.bam'
    output:
        bam = 's3_salsa2/arima/04_deduped/' + prefix + '_rep1.deduped.bam',
        metrics = 's3_salsa2/arima/04_deduped/metrics.' + prefix + '.txt'
    params:
        tmp_dir = scratch_dir
    conda: 'arima.yml'
    shell:'''
        picard MarkDuplicates INPUT={input} OUTPUT={output.bam} METRICS_FILE={output.metrics} TMP_DIR={params.tmp_dir} ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=TRUE 
        '''

rule salsa_am_7_idx_bams:
    input:
        's3_salsa2/arima/04_deduped/' + prefix + '_rep1.deduped.bam'
    output:
        's3_salsa2/arima/04_deduped/' + prefix + '_rep1.deduped.bam.bai'
    conda: 'arima.yml'
    shell:'''
        samtools index {input}
        '''

rule salsa_am_8_get_stats:
    input:
        bam = 's3_salsa2/arima/04_deduped/' + prefix + '_rep1.deduped.bam',
        bai = 's3_salsa2/arima/04_deduped/' + prefix + '_rep1.deduped.bam.bai'
    output:
        's3_salsa2/arima/04_deduped/' + prefix + '_rep1.deduped.bam.stats'
    params:
        script = 'scripts/arima_mapping/get_stats.pl'
    conda: 'arima.yml'
    shell:'''
        perl {params.script} {input.bam} > {output}
        '''


### salsa2 stuff
rule salsa_fmt_index_asm:
    input:
        's2_scaff10x/' + prefix + '.scf.fasta'
    output:
        's2_scaff10x/' + prefix + '.scf.fasta.fai'
    conda: 'envs/bedsam.yml'
    shell:'''
        samtools faidx {input}
        '''

rule salsa_fmt_sort_bam:
    input:
        bam ='s3_salsa2/arima/04_deduped/' + prefix + '_rep1.deduped.bam',
        stats = 's3_salsa2/arima/04_deduped/' + prefix + '_rep1.deduped.bam.stats'
    output:
        's3_salsa2/' + prefix + '_rep1.sort.bam'
    conda: 'envs/bedsam.yml'
    shell:'''
        samtools sort -O bam -o {output} {input.bam}
        '''

rule salsa_fmt_bam_to_bed:
    input:
        's3_salsa2/' + prefix + '_rep1.sort.bam'
    output:
        's3_salsa2/' + prefix + '_rep1.bed'
    conda: 'envs/bedsam.yml'
    shell:'''
        bedtools bamtobed -i {input} > {output}
        '''

rule salsa_fmt_sort_bed:
    input:
        's3_salsa2/' + prefix + '_rep1.bed'
    output:
        's3_salsa2/' + prefix + '_rep1.sort.bed'
    shell:'''
        sort -k 4 {input} > {output}
        '''

rule salsa_run:
    input:
        asm = 's2_scaff10x/' + prefix + '.scf.fasta',
        dup = 's1_ipa/RUN/assembly-results/final.a_ctg.fasta', 
        hic = 's3_salsa2/' + prefix + '_rep1.sort.bed'
    output:
        's3_salsa2/out/scaffolds_FINAL.agp',
        's3_salsa2/out/scaffolds_FINAL.fasta'
    params:
        salsa_bin = salsa_path,
        genome_size = genome_size,
        i = i
    conda: 'envs/py2.yml'
    shell:'''
        python {params.salsa_bin}/run_pipeline.py -a {input.asm} -l {input.asm}.fai -b {input.hic} -s {params.genome_size} -i {params.i} -m yes -p yes -e GATC -x {input.dup} -o s3_salsa2/out
        '''

rule salsa_symlink:
    input:
        agp = 's3_salsa2/out/scaffolds_FINAL.agp',
        fasta = 's3_salsa2/out/scaffolds_FINAL.fasta'
    output:
        agp = 's3_salsa2/scaffolds_FINAL.agp',
        fasta = 's3_salsa2/scaffolds_FINAL.fasta'
    shell:'''
        [ -h {output.agp} ] | ln -s {input.agp} {output.agp}
        [ -h {output.fasta} ] | ln -s {input.fasta} {output.fasta}
        '''


## CHROMONOMER
rule chromonomer_fmt_salsa_agp:
    input:
        's3_salsa2/scaffolds_FINAL.agp'
    output:
        'd3_output/scaffolds_FINAL_no_white_ends.agp'
    shell:'''
        sed 's/[[:blank:]]*$//g' {input} > {output}
        '''

rule chromonomer_aln_lg_loci:
    input:
        fa = lg_loci,
        ref = 's3_salsa2/scaffolds_FINAL.fasta'
    output:
        'd3_output/' + prefix + '_loci.sort.bam'
    conda: 'envs/samtools.yml'
    shell:'''
        bwa mem {input.ref} {input.fa} | samtools view -Sb - | samtools sort -o {output}
        ''' 

rule chromonomer_index_alnmts:
    input:
        'd3_output/' + prefix + '_loci.sort.bam'
    output:
        'd3_output/' + prefix + '_loci.sort.bam.bai'
    conda: 'envs/samtools.yml'
    shell:'''
        samtools index {input}
        '''

rule chromonomer_run:
    input:
        tsv = lg_tsv,                                           # created from Lew et al. 2015 Supplemental B and loci mike found
        bam = 'd3_output/' + prefix + '_loci.sort.bam',         # linkage group loci aligned to SALSA2 output assembly
        bai = 'd3_output/' + prefix + '_loci.sort.bam.bai', 
        agp = 'd3_output/scaffolds_FINAL_no_white_ends.agp',    # output from SALSA2 with end of line whitespace taken out (sed 's/[[:blank:]]*$//g' <file>)
        fasta = 's3_salsa2/scaffolds_FINAL.fasta'               # output fasta from SALSA2 assembly (sym linked to salsa dir, rather than salsa/out/ dir)
    output:
        's4_chomonomer/CHRR_integrated.fa'                      # output fasta
    conda: 'conda/chrmnmr.yml'
    params:
        out_dir = 's4_chomonomer/'
    shell:'''
        chromonomer --verbose --map {input.tsv} --alns {input.bam} --agp {input.agp} --fasta {input.fasta} --out_path {params.out_dir}
        '''

## FINAL FORMAT
rule get_final_asm:
    input:
        's4_chomonomer/CHRR_integrated.fa'
    output:
        prefix + '.fa'
    shell:'''
        if [ -h {output} ]; then rm {output}; ln -s {input} {output}; else ln -s {input} {output}; fi
        '''
