/* ascii.rex
 show ascii chart, with extended ascii characters as well

 usage
   r4 ascii [>outfile]
*/

	/* prepare table for special characters */

special.    = ''	        /* default: indicates character is not special */

	/* values requiring special presentation: */

special.0   = 'NUL'
special.1   = 'SOH'
special.2   = 'STX'
special.3   = 'ETX'
special.4   = 'EOT'
special.5   = 'ENQ'
special.6   = 'ACK'
special.7   = 'BEL'
special.8   = 'BS'
special.9   = 'HT'
special.10  = 'LF'
special.11  = 'VT'
special.12  = 'FF'
special.13  = 'CR'
special.14  = 'SO'
special.15  = 'SI'
special.16  = 'DLE'
special.17  = 'DC1'
special.18  = 'DC2'
special.19  = 'DC3'
special.20  = 'DC4'
special.21  = 'NAK'
special.22  = 'SYN'
special.23  = 'ETB'
special.24  = 'CAN'
special.25  = 'EM'
special.26  = 'SUB'
special.27  = 'ESC'
special.28  = 'FS'
special.29  = 'GS'
special.30  = 'RS'
special.31  = 'US'
special.32  = 'spc'  /* blank, space */

special.127 = 'DEL'  /* rubout, DEL */
special.255 = 'FF'



	/* prepare title lines */

say center( 'Ascii character code table', 68 )

call charout , '    '					           /* column header prefix */

do j=0 to 15
  call charout , d2x( j )'   '                               /* hex column */
  end

say                                              /* end column header line */

/* outer loop, 16 hexadecimal digits in first nibble */

do i=0 to 15

  call charout , d2x( i )'0  '                      /* prefix current line */

  /* inner loop, 16 hexadecimal digits in second nibble */

  do j=0 to 15

    v = ( i * 16 ) + j                /* compute current value, in decimal */

    if special.v <> '' then         /* => value requires special treatment */
      call charout , left( special.v, 4 )       /* show special identifier */

    else
      call charout , d2c( v )'   '                       /* show character */

   end /* end inner loop */

  say                                                          /* end line */

  end /* end outer loop */
