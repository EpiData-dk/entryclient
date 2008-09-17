Notes on EpiData v2.2 beta 

Please note this is a testversion and some changes will happen before final release.
This testversion should NOT be used after release of final version 2.2.

Please report any problems to info@epidata.dk
Include a specification of the problem. E.g.
- is it a new problem for something which worked in v2.1b
- is it occurring systematically, that is can you reproduce it
- a copy of the version and build of epidata, see screen (e.g. v2.2beta (build 2904))
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

Known problems in this beta release:

Missingvalue is not final (fields cannot be specified yet)
Export to Stata8 not final
The new find function is working.

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

Kind regards Jens Lauritsen
EpiData Association Denmark

See list of changes below
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
Bugs corrected since v2.1b:

Key unique index error which could result in dublicate records (Major bug)
Type Statusbar updating corrected in relate
Incorrect blocking (access violation) when showing legal values during entry.
-------------------------------------------------------------------------------
Modified or enhanced functionality

Specify Find directly on dataform (Enter data)
Enhanced find, e.g. v1 > 1.70 (see how to use find below)
New fieldtypes: Encrypted fields <e   > <yyyy/mm/dd> <today-ymd>
Encryption at field level using Rijndael/AES strong encryption: <e   >
Show currently defined variables (define) and files open: F2 F2 (press twice)
Folder name handling with RELATE and BACKUP corrected to relative position
Index for recfiles used in comment legal created automatically
Export and import to/from STATA 8 added.
Enhanced filter expression control on export
-------------------------------------------------------------------------------
New check commands and functions:

INCLUDE other CHK files
Numeric codes can be defined as missing. Press - and the first is added.
MISSINGVALUE x [x [x]]      in fieldblock
MISSINGVALUE ALL x [x [x]] in before file block (all numeric fields get values)
MISSINGVALUE field1-fieldx x [x [x]]
Defined values are handled correctly on export to SAS, STATA, SPSS
TYPE COMMENT ALLFIELDS COLOR  Shows all comment legal texts.
    implicit "TYPE COMMENT" for all fields with label
-------------------------------------------------------------------------------
Expected in v2.2 before final release not in this release:

VIEW: Grid view of data as part of documentation menu.
AUTOSEARCH list all duplicates automatically
Validate by entering twice in same file and compare directly
Dataentry only module with start parameter
-------------------------------------------------------------------------------


HOW TO USE FIND RECORD FUNCTION IN EPIDATA 2.2 BETA

Press CTRL+F during dataentry to find a record. The dataform goes blank and 1-10 
fields can be filled with search criteria.

Search criteria can be:
text		field content must be equal to text
=text		do.
<>text		field content must be different from text
>text		field content must be greater than text
<text		field content must be less than text
*text		field content must end with text
text*		field content must begin with text
*text*		field content must contain text

When desired critiria has been entered the search begins when ctrl+F is pressed
(search forward) or when ctrl+shift+F is pressed (search backwards). Buttons in
toolbar can be used instead.

From data entry form, press F3 to define a new search or press ctrl+F3 to edit
existing search criteria.

-------------------------------------------------------------------------------

