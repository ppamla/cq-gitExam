nextflow.enable.dsl = 2

params.accession = "M21012"
params.store = "$launchDir/datastore"
params.out = "$launchDir/output"
//params.fastaSequences = "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/hepatitis_combined.fasta?inline=false"


process downloadFasta {
    storeDir params.store 
input:
    val accession
output:
    path "${accession}.fasta"

    script:
    """
    wget -O ${accession}.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012&rettype=fasta&retmode=text"
	"""
}

process getSequences {
  storeDir params.store
output: 
	path "hepatitis_combined.fasta"

  script: 
    """
    wget https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/hepatitis_combined.fasta -O hepatitis_combined.fasta
    """
}


process combineFasta {
    publishDir params.out, mode: "copy", overwrite: true
input:
    path fasta1
	path fasta2
output:
    path "combined.fasta"

    script:
    """
    cat ${fasta1} ${fasta2} > combined.fasta
    """
}

process runMafft {
    publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/mafft%3A7.525--h031d066_1"
    input:
    path "combined.fasta"
    output:
    path "aligned.fasta"
    script:
    """
    mafft --auto combined.fasta > aligned.fasta
    """
}

workflow {
  accession_channel = Channel.from(params.accession)
  referenceFasta = downloadFasta(accession_channel)
  genomeList = getSequences()
  combinedFasta = combineFasta(referenceFasta, genomeList) 
	alignedFasta = runMafft(combinedFasta)
    
}
