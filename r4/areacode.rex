/* areacode.rex
 show areacodes within state, or specific state of areacode

 Keywords
  Telephone areacode lookup, Simple record parsing

 Usage
  Three forms:
   [1] ex areacode state_name
   [2] ex areacode state_abbreviation
   [3] ex areacode nnn

 Arguments
  Variation 1: show all areacodes within a specific state
   state_name [ie. kansas]

  Variation 2: show all areacodes within a specific state
   state_abbreviation [ie. KS]

  Variation 3: show state which has a specific areacode
   nnn, areacode# [ie. 913]

 Files used
  Standard output
  Distribution file "areacode.dat": Table of STATES and CODES

 Exit codes
   0   => state or code located
 non-0 => usage error, or request not found

 Input record format
  SS nnn State-name
   ³  ³    À-> ie. Alaska
   ³  À-> Area code, ie. 907
   À-> State code, ie. AK

 Sample input file
  Distribution file "areacode.dat" contains records in the
  following format:

   AK 907 Alaska  
   AL 205 Alabama 
   AR 501 Arkansas
   AZ 602 Arizona 
    .             
    .             
    .             

 Sample output file
  State/areacodes are displayed to standard output as Ascii lines

 Example of use
  [1] ex areacode ks
  [2] ex areacode kansas
  [3] ex areacode 913

 Explanation
  This procedure is used to show telephone areacodes within a specific
  state identified by its name or abbreviation code. Alternatively,
  the specific state containing an areacode is displayed.

  In the examples above,
   [1] show areacodes in ks
   [2] show areacodes in kansas
   [3] show state with areacode 913
*/

ARG value

codefile = "g:\rex\areacode.dat" /* <-- areacode file path (edit) ! */

 /* validate arguments */

if value = "" then signal usagemsg

/* infer whether to process by numeric code,
 * state name, or state abbreviation
 */

if verify( value, '0123456789', 'N' ) = 0 then
  which = code
else
  which = state

if lines( codefile ) = 0 then do
  call lineout "!", 'AREACODE: can NOT find file' codefile'.'
  call lineout "!", ''
  call lineout "!", 'Please edit the AREACODE.REX program'
  call lineout "!", "and revise the line that defines 'codefile'."
  exit 1
  end

any = 0                                /* presume no entries found */

do lines( codefile )                 /* process all areacode lines */

   /* parse fields of areacode information */

  parse UPPER value linein( codefile ) with ,
    acstate accode statename

  if which = state then do  

     /* match by state name or abbreviation */

    if acstate = value | statename = value then do  /* state match */
      say accode                              /* show located code */
      any = 1                            /* at least 1 entry found */
      end
    end

   /* match by areacode */

  else if accode = value then do               /* areacode matches */
    say statename                       /* show located state name */
    any = 1                                  /* areacode was found */
    leave     /* entry found. input file contains 1 entry per code */
    end

  end

call lineout codefile                       /* close areacode file */

exit any = 0 /* any entries found => 0(success), otherwise 1(fail) */

usagemsg:
  call lineout "!", "Usage:"
  call lineout "!", " ex areacode ca     ==> areacodes in ca"
  call lineout "!", " ex areacode hawaii ==> areacodes in hawaii"
  call lineout "!", " ex areacode 913    ==> state with areacode 913"
  exit 1
