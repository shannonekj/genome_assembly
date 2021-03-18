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

cpu = config['cpu']

# other
prefix = species_id + '_' + sex


# lists
## long reads
long_samples = config['sample_long_links']
LONG_SAMPLES = long_samples.keys()
## short reads
short_samples = config['sample_short_links']
SHORT_SAMPLES = short_samples.keys()


###############
###  r00lz  ###
###############

rule all:
    input:
        expand("input/data/raw/{sample}.fastq", sample=LONG_SAMPLES),
        expand("input/data/raw/{sample}.fastq.gz", sample=SHORT_SAMPLES),
        expand("output/fastqc/{sample}.html", sample=SHORT_SAMPLES),
        expand("output/fastqc/{sample}.zip", sample=SHORT_SAMPLES),

rule rename_files:
    input:
        hfa = hifi_a,
        hfb = hifi_b,
        hfc = hifi_c,
        tr1 = tenx_r1,
        tr2 = tenx_r2,
        hc1 = hic_r1,
        hc2 = hic_r2
    output:
        hfa = 'input/data/raw/hifi_a.fastq',
        hfb = 'input/data/raw/hifi_b.fastq',
        hfc = 'input/data/raw/hifi_c.fastq',
        tr1 = 'input/data/raw/tnx_R1.fastq.gz',
        tr2 = 'input/data/raw/tnx_R2.fastq.gz',
        hc1 = 'input/data/raw/hic_R1.fastq.gz',
        hc2 = 'input/data/raw/hic_R2.fastq.gz'
    shell:'''
        ln -s {input.hfa} {output.hfa}
        ln -s {input.hfb} {output.hfb}
        ln -s {input.hfc} {output.hfc}
        ln -s {input.tr1} {output.tr1}
        ln -s {input.tr2} {output.tr2}
        ln -s {input.hc1} {output.hc1}
        ln -s {input.hc2} {output.hc2}
        '''

rule get_fastqc:
    input:
        "input/data/raw/{sample}.fastq.gz"
    output:
        "output/fastqc/{sample}.html",
        "output/fastqc/{sample}.zip"
    params:
        outdir = directory("output/fastqc")
    conda: 'envs/short_qc.yml'
    shell:'''
        fastqc -o {params.outdir} {input}
        '''






