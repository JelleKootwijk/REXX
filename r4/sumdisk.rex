/* sumdisk.rex
 summarize disk directory tree from current directory downward

 For each directory level the following are identified:
  1. total size of all files in directory [true size, rounded by cluster size]
  2. number of files in the directory
  3. date and time of most recently modified file in directory
  4. biggest file size in directory
  5. full directory path name [with leading hierarchic indentation indicators]

 The report includes leading "disk" summary information. Then, directory
 summary output is produced recursively, in hierarchic order, from the
 starting directory downward. The report concludes with the total space used
 by ALL of the directories that were analyzed.

 The resulting directory summary information can be sorted in various ways:
   by descending size,      when disk space must be reduced
   by descending date&time, to identify directories that need to be backed up
   by descending biggest size, to identify directories with biggest files

 This procedure could be modified in various ways. For example, if you are
 looking for the most recent copy of a file that is contained in multiple
 directories, you could compare the "fname" value versus a target file name
 as each file is processed in the "do_files" procedure. When matching files
 are located, associated file information and directory information could be
 displayed.

 Keywords
   Disk management, Directory analysis, Recursive directory file search example

 Usage
   r4 sumdisk [>summary_output_file]

 Arguments
  N/A

 Files used

  Standard output: disk summary report [usually redirected]

  Console immediate output: shows progress through directory levels

 Exit codes
   0   => summary report complete
 non-0 => an error occurred

 Input record format
  N/A

 Sample input file
  N/A

 Sample output file
  +-----------------------------------------------------------------------------+
  |    Summary of G disk. Prepared at 05:35:50 on 15 May 2001                   |
  |  Total space: 15093387264, free: 12326969344, 81.6% is free                 |
  |  Cluster size for G disk files is: 4096                                     |
  |                                                                             |
  |    Directory Summary                                                        |
  |          Size #Files  Newest date & time        Biggest Directory Path      |
  |       3870720    373 2001/05/15-05:35:50         651264 +G:\r4              |
  |      19980288     33 2001/05/15-05:29:46        6287360 ++-G:\r4\Debug      |
  |         49152      3 2001/05/11-16:40:32          32768 ++-G:\r4\examples   |
  |      20164608     27 2001/05/14-14:38:55        6332416 ++-G:\r4\RDebug     |
  |       7716864     24 2001/05/15-05:31:33        4841472 ++-G:\r4\Release    |
  |       1003520    194 2001/04/24-11:51:23         110592 ++-G:\r4\tc         |
  |      18063360     26 2001/04/17-12:57:30        5382144 ++-G:\r4\TDebug     |
  | Total size of files in analyzed directories is: 70848512                    |
  +-----------------------------------------------------------------------------+

 Example of use
   r4 sumdisk >d:harddisk.sum

 Explanation
  In the example above, a summary report is produced for the current disk,
  and the current directory downward. The report is saved in file
  "d:harddisk.sum". The request is performed in the "G:\r4" directory
  of the "G" disk. The total size in all directories is 70848512.
*/

numeric digits 16

 /* analyze default disk drive space utilization
  * and get file cluster size, which is used in subsequent directory analysis
  */

cluster_size = disk_free()

	/* prepare directory analysis title lines */

say
say '    Directory Summary'
say right( 'Size', 14 ) '#Files  Newest date & time' right( 'Biggest', 14 ) 'Directory Path'

	/* analyze directories and show total of files within directory tree */

say ' Total size of files in analyzed directories is:' do_dirs( stream( '', 'C', 'DIRS' ) ' +' )

exit 0

 /* DO_DIRS procedure
  * analyze files in this directory
  * and recursively analyze all subdirectories
  */

do_dirs : procedure expose cluster_size

  arg ndirs indent     /* get #queued directories and indentation prefix */

  dir_total = 0        /* total file size in this directory
                        * and ALL subdirectories downward
				        */
  
  call lineout !, indent || stream( '', 'C', 'CHDIR' )   /* show progress */

  dir_total = dir_total + do_files( stream( '', 'C', 'FILES' ) )

  say indent || stream( '', 'C', 'CHDIR' ) /* show current directory name */
  
  do ndirs

    parse pull dirname    /* get next queued directory to process */
    
    'cd' dirname                             /* dive down 1 level */

	dir_total = dir_total + do_dirs( stream( '', 'C', 'DIRS' ) indent'+-' )

    'cd ..'                /* rise back up 1 level */

    end

  return dir_total

 /* DO_FILES procedure
  * analyze all files in this directory
  * total size of all files [with each file size rounded to cluster size]
  * also,
  *  identify date and time of most recently modified file in directory
  *  identify biggest file size in directory
  */

do_files : procedure expose cluster_size

  arg nfiles                                           /* get # queued files */

  dir_file_total = 0                 /* total file size in current directory */

  newest = ''                                   /* newest file date and time */

  biggest = 0                                           /* biggest file size */

  do arg(1)                                             /* process all files */

    parse pull fname                 /* get next queued file name to process */

	parse value stream( fname, 'C', 'FILEINFO' ) with dateTime fsize .

    /* round file size to cluster size [true amount of disk space used] */

    fsize = cluster_size * trunc( ( fsize + cluster_size - 1 ) / cluster_size )

    dir_file_total = dir_file_total + fsize    /* accumulate directory total */

    if dateTime > newest then                           /* check date & time */
      newest = dateTime                  /* this file is newest in directory */

    biggest = max( biggest, fsize )      /* obtain biggest size in directory */

    end

  /* prepare summary information describing files in directory */

  call charout , ,
    right( dir_file_total, 14 ) ,
    right( nfiles, 6 ) ,
    left( newest, 19 ) ,
    right( biggest, 14 )

  return dir_file_total                       /* return directory file total */

 /* DISK_FREE procedure
  * obtains dis information
  *
  * usage
  *   call disk_free C                [drive C]
  *   call disk_free                  [current drive]
  *
  * returns
  *   disk cluster size
  */

disk_free : procedure

  arg drive

  if drive = '' then
     drive = stream( '', 'C', 'CHDISK' )        /* => current drive letter */

  call lineout !, 'Analyzing' drive 'drive...'

  parse value stream( drive, 'C', 'DRIVE' ) with . . total_space free_space	cluster_size .

  if total_space <> '_' then do

      numeric digits 20

	  percent_free = trunc( ( free_space * 100 ) / total_space, 1 )

	  say '    Summary of' drive 'disk. Prepared at' time() 'on' date()

	  say '  Total space:' total_space', free:' free_space',' percent_free'% is free'

	  say '  Cluster size for' drive 'disk files is:' cluster_size
	  
	  end

  else
    cluster_size = 0

  return cluster_size
