nextflow.enable.dsl = 2

params.accession = "M21012" 
params.store = "$launchDir/datastore"



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



workflow {

  accession_channel = Channel.from(params.accession)
  referenceFastaFile= downloadFasta(accession_channel)

}
