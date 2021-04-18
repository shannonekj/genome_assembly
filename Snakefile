include: "snakefiles/prep_F.snakefile"
include: "raw_stats_F.snakefile"
#include: "snakefiles/prep_M.snakefile"
include: "snakefiles/asm_F.snakefile"
#include: "snakefiles/asm_M.snakefile"


rule all:
    input:
        'input/shrt_reads_raw.fofn',
        'input/long_reads_raw.fofn',
        'Hyp_tra_F.fa',
#        'output/final_asm/Hyp_tra_F.fa',
#        'output/final_asm/Hyp_tra_M.fa'
