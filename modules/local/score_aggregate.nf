process SCORE_AGGREGATE {
    // labels are defined in conf/modules.config
    label 'process_high_memory'
    label 'pgscatalog_utils' // controls conda, docker, + singularity options

    conda (params.enable_conda ? "${task.ext.conda}" : null)

    container "${ workflow.containerEngine == 'singularity' &&
        !task.ext.singularity_pull_docker_container ?
        "${task.ext.singularity}${task.ext.version}" :
        "${task.ext.docker}${task.ext.version}" }"

    input:
    path scorefiles

    output:
    path "aggregated_scores.txt.gz", emit: scores
    path "versions.yml"            , emit: versions

    script:
    """
    aggregate_scores -s $scorefiles -o . -v

    cat <<-END_VERSIONS > versions.yml
    ${task.process.tokenize(':').last()}:
        pgscatalog_utils: \$(echo \$(python -c 'import pgscatalog_utils; print(pgscatalog_utils.__version__)'))
    END_VERSIONS
    """
}
