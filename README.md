# IATI Data Dump 2

To run:
* Create virtual environment
* Install requirements in `requirements.txt`
* Run shell script - if dev/local you almost certainly also want this flag: `DEBUG=true ./run.sh`

A working directory can be set by another environment flag. See script. A default is used if not.

When run, files from the last run will be deleted from the working directory before more work is done. 
So be careful about which working directory you use. 

After the run, files will be left in the working directory that can be served to users.

Thanks to: 
  *  https://github.com/codeforIATI/iati-data-dump


