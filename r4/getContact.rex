/* GetContact.rex
 this program obtains contact information via TopHat

 this program communicates with TopHat.EXE via the registry

 a tab delimited input value is acquired from registry value:
  HKLM\Software\Kilowatt Software\R4\Contact[Request]
*/

tab = d2c( 9 )

/* invoke TopHat with input file: Contact.TopHat */

revise = 1 /* 1 => revise provided input values */

request = '' /* => reset existing input values */

if revise then do /* provide input values */

	name = 'John Doe'

	address1 = '11 Oak Street'

	address2 = '-'

	city = 'Pleasantville'

	state = 'ZW'

	country = 'USA'

	mailCode = '55555' 

	phone = '999-555-1212'

	email = 'jdoe@bitbucket.com'

	emailAlt = 'johndoe@elsewhere.com'

	dateOfContact = '23 May 2001'

	/* prepare tab delimited TopHat input values request */

	request = ,
		   name     || tab ,
		|| address1 || tab ,
		|| address2 || tab ,
		|| city     || tab ,
		|| state    || tab ,
		|| country  || tab ,
		|| mailCode || tab ,
		|| phone    || tab ,
		|| email    || tab ,
		|| emailAlt || tab ,
		|| dateOfContact
	
	end

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value "HKLM\Software\Kilowatt Software\R4\Contact[Request]", request, "Registry"


trace off /* ignore error code when cancel is pressed */

'TopHat Contact.TopHat'

if rc <> 0 then /* cancel button was pressed */
  exit 1

/* get TopHat input field values */

input = value( "HKLM\Software\Kilowatt Software\R4\Contact[Request]", , "Registry" )

/* parse tab delimited input field values */

parse var input ,
  name (tab) ,
  address1 (tab) ,
  address2 (tab) ,
  city (tab) ,
  state (tab) ,
  country (tab) ,
  mailCode (tab) ,
  phone (tab) ,
  email (tab) ,
  emailAlt (tab) ,
  dateOfContact (tab)

say 'Contact information:'
say
say left( 'Name', 20 ) name
say left( 'Address1', 20 ) address1
say left( 'Address2', 20 ) copies( address2, address2 <> '-' )
say left( 'City', 20 ) city
say left( 'State', 20 ) state
say left( 'Country', 20 ) country
say left( 'Zip/Mail code', 20 ) mailCode
say left( 'Phone', 20 ) phone
say left( 'E-mail', 20 ) email
say left( 'Alternate e-mail', 20 ) emailAlt
say left( 'Date of contact', 20 ) dateOfContact

exit 0