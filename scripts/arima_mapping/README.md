# Arima Mapping Pipeline
Scripts taken from https://github.com/shannonekj/mapping_pipeline and modified in the following ways:
* `01_mapping_arima.sh`
    * `head -16 01_mapping_arima.sh > run_arima_mapping.sh`
    * ```cat << EOT >> run_arima_mapping.sh
set -e

SRA="Smelt-Joslin"
LABEL="${prefix}_${grp}"
BWA="$(which bwa)"
SAMTOOLS="$(which samtools)"
IN_DIR="${out_dir}"
REF="${out_dir}/${ref}"
FAIDX='\$REF.fai'
PREFIX="${ref}"
RAW_DIR="${out_dir}/01_raw_bams"
FILT_DIR="${out_dir}/02_filt_bams"
FILTER="${out_dir}/filter_five_end.pl"
COMBINER="${out_dir}/two_read_bam_combiner.pl"
STATS="${out_dir}/get_stats.pl"
PICARD="$(which picard)"
TMP_DIR="${sct_dir}"
PAIR_DIR="${out_dir}/03_pair_bams"
REP_DIR="${out_dir}/04_deduped"
REP_LABEL=\$LABEL\\_rep1
MERGE_DIR="${out_dir}/05_merged"
MAPQ_FILTER=10
CPU=${threads}

EOT
```

    * `tail -68 01_mapping_arima.sh >> run_arima_mapping.sh`
    * `sed -i 's/java -Xmx4G -Djava.io.tmpdir=temp\/ -jar //'` run_arima_mapping.sh 
    * `sed -i 's/java -Xmx30G -XX:-UseGCOverheadLimit -Djava.io.tmpdir=temp\/ -jar //'` run_arima_mapping.sh
    * `chmod a+x run_arima_mapping.sh`
    * `chmod a+x \*.pl`
* `filter_five_end.pl`
* `get_stats.pl`
* `two_read_bam_combiner.pl`
