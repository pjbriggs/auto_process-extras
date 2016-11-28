auto_process-extras
===================

Scripts that are useful for automating standard post-analysis logging,
reporting and data transfer tasks.

Scripts:

 - ``transfer_data.sh``: transfer data from a project in an analysis
   directory to either a webserver or a cluster shared data area
 - ``find_random_bin.sh``: find a random empty 'bin' (i.e. subdirectory)
 - ``run_qc.sh``: run the ``auto_process.py run_qc`` command on arbitrary
   FASTQ files

The scripts require that the ``auto_process_ngs`` software is installed.

Also the ``site.sh.sample`` file should be copied to ``site.sh`` and
edited to set the locations of the top-level webserver and cluster
directories.
