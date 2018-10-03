FROM centos:7

MAINTAINER aupadh4@emory.edu

RUN yum -y update && yum clean all
RUN yum -y install wget unzip zlib-devel bzip2-devel xz-devel ncurses-devel perl java gcc gcc-c++ make openssl-devel bzip2 libcurl-devel perl\(Data::Dumper\) which tar && yum clean all
	

RUN mkdir /home/tools
ENV TOOLS /home/tools/

# Trimmomatic
WORKDIR $TOOLS
RUN wget "http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip" && \
	unzip Trimmomatic-0.38.zip && \
	rm Trimmomatic-0.38.zip

# seqtk
WORKDIR $TOOLS
RUN wget "https://github.com/lh3/seqtk/archive/v1.2.zip" && \
	unzip v1.2.zip && \
	rm v1.2.zip && \
	cd seqtk-1.2 && \
	make && \
	ln -s /home/tools/seqtk-1.2/seqtk /usr/local/bin/

# samtools
WORKDIR $TOOLS
RUN wget "https://github.com/samtools/samtools/releases/download/1.8/samtools-1.8.tar.bz2" && \
	tar xvjf samtools-1.8.tar.bz2 && \
	cd samtools-1.8 && \
	mkdir build && \
	./configure --prefix=$PWD/build && \
	make && \
	ln -s /home/tools/samtools-1.8/samtools /usr/local/bin/ && \
	rm ../samtools-1.8.tar.bz2
	
# STAR
WORKDIR $TOOLS
RUN wget "https://github.com/alexdobin/STAR/archive/2.6.0c.zip" && \
	unzip 2.6.0c.zip && \
	rm 2.6.0c.zip && \
	ln -s /home/tools/STAR-2.6.0c/bin/Linux_x86_64/STAR /usr/local/bin/

# bowtie2
WORKDIR $TOOLS
RUN wget "https://github.com/BenLangmead/bowtie2/releases/download/v2.3.4.1/bowtie2-2.3.4.1-linux-x86_64.zip" && \
	unzip bowtie2-2.3.4.1-linux-x86_64.zip && \
	rm bowtie2-2.3.4.1-linux-x86_64.zip && \
	ln -s /home/tools/bowtie2-2.3.4.1-linux-x86_64/bowtie2 /usr/local/bin/ &&\
	ln -s /home/tools/bowtie2-2.3.4.1-linux-x86_64/bowtie2-build /usr/local/bin/

# Trinity
WORKDIR $TOOLS
RUN wget "https://github.com/trinityrnaseq/trinityrnaseq/archive/Trinity-v2.3.2.zip" && \
	unzip Trinity-v2.3.2.zip && \
	rm Trinity-v2.3.2.zip && \
	cd trinityrnaseq-Trinity-v2.3.2 && \
	make && \
	make plugins && \
	ln -s /home/tools/trinityrnaseq-Trinity-v2.3.2/Trinity /usr/local/bin/
	
# Jellyfish
WORKDIR $TOOLS
RUN wget "https://github.com/gmarcais/Jellyfish/releases/download/v1.1.12/jellyfish-linux" -O jellyfish && \
	chmod +x jellyfish && \
	ln -s /home/tools/jellyfish /usr/local/bin/

# Salmon 
WORKDIR $TOOLS
RUN wget "https://github.com/COMBINE-lab/salmon/releases/download/v0.11.3/salmon-0.11.3-linux_x86_64.tar.gz" && \
    tar xvzf salmon-0.11.3-linux_x86_64.tar.gz && \
    ln -s /home/tools/salmon-0.11.3-linux_x86_64/bin/salmon /usr/local/bin/ && \
    rm salmon-0.11.3-linux_x86_64.tar.gz

# IgBLAST
WORKDIR $TOOLS
RUN wget "ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/1.6.1/ncbi-igblast-1.6.1-x64-linux.tar.gz" && \
	tar zxvf ncbi-igblast-1.6.1-x64-linux.tar.gz && \
	rm ncbi-igblast-1.6.1-x64-linux.tar.gz && \
	cd ncbi-igblast-1.6.1 && \
	mkdir database internal_data optional_file && \
	wget --directory-prefix=database "ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/database/*" && \
	wget -r --directory-prefix=internal_data "ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/internal_data/*" && \
	wget --directory-prefix=optional_file "ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/optional_file/*" && \
	ln -s /home/tools/ncbi-igblast-1.6.1/bin/* /usr/local/bin/

# BALDR
WORKDIR $TOOLS
RUN wget "https://github.com/BosingerLab/BALDR/archive/master.zip" && \
	unzip master.zip
