auto_process-extras
===================

Scripts that are useful for automating standard post-analysis logging,
reporting and data transfer tasks.

Scripts:

 - ``transfer_data.sh``: transfer data from a project in an analysis
   directory to either a webserver or a cluster shared data area
 - ``find_random_bin.sh``: find a random empty 'bin' (i.e. subdirectory)

The scripts require that the ``auto_process_ngs`` software is installed.

Also the ``site.sh.sample`` file should be copied to ``site.sh`` and
edited to set the locations of the top-level webserver and cluster
directories.

When copying to a webserver, it is also possible to specify a ``README``
template file via the ``WEBREADME`` variable in ``site.sh``. The
following 'template variables' can be included in the template and will
be substituted with the appropriate values:

 - ``%PLATFORM%``: the run platform
 - ``%RUN_NUMBER%``: the run number
 - ``%DATESTAMP%``: the datestamp for the run
 - ``%PROJECT%``: the project being copied
 - ``%WEBURL%``: the URL for the webserver
 - ``%BIN%``: the name of the random bin
 - ``%TODAY%``: today's date
