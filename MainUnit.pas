unit MainUnit;

{Out of memory koder:
  121 GetDatafilePointer
  231 HandleLegal
  124 FileUnit.FieldListToQes
  342 StringsToChecks
  532 pNewCheckFile
  751 Make Datafile from QES-file - in fileUnit
  766 Validate duplicate datafiles
  825 Datafile label function - in MainUnit
  831 Stata export
  664 PeekCheckUnit.RetrieveKeys
  921 CopyDatafileStructure
  783 Codebook (ExportForm.Create)
  331 CHEKCLEGAL i consistencycheck - MainUnit
}



{Logbook
 13-02-00
 Main form's coordinates is saved and read to/from Registry
 DataForm's coordinates is saved and read to/from Registry
 Tile vertically/horizontally added

 16-02-00
 Tool-bar added to MainForm

 17-02-00
 Field pick list form added + controls to open it

 18-02-00
 IndtastningsForm.OpenIndtastningsform flyttet til EdUnit
 Grid fjernet fra IndtastningsForm.
 ProgressForm overflødiggjort - bar flyttet til MainForm

 19-02-00
 Work process toolbar added.
 Menuitems to turn toolbars on/off added.

 27-02-00
 Menustructure changed
 RecentFiles functions added

 29-02-00
 Create datafile btn on work process bar added
 Beginning of procedure TMainForm.CreateDatafileBtnClick written
 SelectFilesUnit added
 Overset.inc from EpiEnter added

 01-03-00
 FileUnit added
 Create datafile functionality added
 Enterdata btn changed - popup removed

 05-03-00
 Export to textfile and export to dBase-file added

 06-03-00
 Create qes-file from recfile added

 08-03-00
 Editor font and color options added

 09-03-00
 Dataform font and color options added
 FieldNameCase options added

 16-03-00
 IDNUM fieldtype added
 Soundex fieldtype added

 17-03-00
 Export to Excel added

 21-03-00
 Feltliste type ændret til TList

 22-03-00
 OpenDatafile changed to reading field info with Text-file

 23-03-00
 No focus on first field after Enter Data error corrected

 24-03-00
 Goto line number added to Ed

 27-03-00
 Export to Stata added

 28-03-00
 Error in stata export of dates corrected
 Count records error corrected
 Bug fixed in export to dBase (floating numbers)
 Xls_SetBoolean added to Unit XLS
 Bug fixed in NameIsUnique in GetFieldNames (overset.inc) that
 made dublicate fieldnames
 CTRL-VK_LEFT in indtastningsform sets horzScrollBar to 0
 Close PickListForm with ESC added

 29-03-00
 Find record and Find Again added
 First IDNumber option added

 30-03-00
 Begun added simpel check functions

 31-03-00
 Create new checkfile added

 01-04-00
 Spaces-after-field-in-qes may be solved

 06-04-00
 Checkmodul rettet så der findes Range/legal, jumps, mustenter og repeat
 RecLineToQes rettet så @-tegn mv. stilles rigtigt
 Overset rettet så @-tegn håndteres rigtigt
 TAB EVERY tag droppet og erstattet af option
 Automatisk indsætning af komma i ftFloat felter tilføjet

 08-04-00
 Rettet fejl som tillod at ulovlige datoer mv. kunne gemmes ved PgUp/PgDn etc.

 09-04-00
 CheckForm lavet om til sizeTool window - BoundsRect gemmes i Registry
 Fejlhåndtering tilrettet (rapForm ved createindtastningsFormError m.v.)
 
 10-04-00
 Handlejumps added in onExitEvent

 11-04-00
 Welcome window added
 Commandline parameters added (*.qes, *.rec, /NoToolBars /ShowWelcomeWindow)
 Aboutbox added

 16-04-00
 Fixed bug in GetFieldName that created List-bounds out of range
 Length check: Integer>Len(4) ==> ftFloat
 Length check: text+uppercase max of 80 chars
 Length check: IDNUM max 14 chars
 Legal datetypes when creating datafile/testing dataform:
   <dd/mm/yyyy>  <mm/dd/yyyy>  <today-dmy>  <today-mdy>

 17-04-00
 Animeret logo tilføjet i About-box
 Info om antal exporterede fields og records tilføjet i Exportfunktion
 Indtastningsform.Caption tilkendegiver CheckFileMode
 Jump > END og Jump > WRITE tilføjet

 25-04-00
 PeekDatafile lavet i FileUnit
 eField, eFieldList, PeField tilføjet i EpiTypes
 Variable-info påbegyndt

 26-04-00
 PeekApplyCheckFile lavet
 Datafile-info og variable-info viderebearbejdet (mangler check-oplysninger)

 27-04-00
 BackUp funktion påbegyndt (mangler check af drive-ready)
 Disable workprocess btns tilføjet

 28-04-00
 Backup funktion færdig

 01-05-00
 Datafile-info og variable-info færdig
 
 02-05-00
 Documentation Font og -Color added in options
 ReadMe.RTF created and changed
 Help|Information to testers added

 03-05-00
 EpiData homepage added to Help
 Open BugReport added to Help

 04-05-00
 Fejl vedr. Longint i Opendatafile rettet
 OptionsForm rettet
 DataFormFont og DocuFont gemmes i Registry
 Fejl i RecentQesList rettet

 05-05-00
 RangeChecks tilføjet i CanExitField

 08-05-00
 *>jump tilføjet
 Extra advarsel ved sletning af checks tilføjet
 Genvejstaster i CheckfileMode tilføjet
 CopyChecks og InsertChecks tilføjet

 10-05-00
 Version 0.2 sendt til Jens og Mark

 18-05-00
 Editor|Dataform|Options fjernet
 Ny field pick list designet
 Ny Code Writer funktion tilføjet

 19-05-00
 Tab-control tilføjet - kan styre editor
 Editor windows starter maximeret
 Progress-bar meddelelser flyttet til StatusPanel
 Editor statusbar flyttet til StatusPanel

 20-05-00
 Fejl i baggrundfarve ved documentation rettet
 Farvedialog i Options tilføjet option-SolidColor
 Indtastningsform statusbar flyttet til StatusPanel
 Document valgmuligheder fjernet - Nu kun Document datafile
 FieldNameCase gemmes i registry
 EvenTabValue gemmes i registry
 NumberOfTabChars (i editor) gemmes i registry
 NumberOfTabChars tilføjet i Optionsform|Editor
 Label's feltnavne ændret til 'Label1'
 Check for om QES-fil indeholde felter tilføjet i CreateDatafile
 Fejl rettet i CanExitField så datafiler uden entry-fields can lukkes

 27-05-00
 Fjerner alle referencer til IndtastningsFormUnit og lign.
 Revision af PeekApplyCheckFile påbegyndt - mangler flere rutiner

 28-05-00
 Revision af PeekApplyCheckFile færdig
 Study description function tilføjet

 29-05-00
 Fejlretning før Jens' præsentation:
 - <dd/mm> laves nu til <dd/mm/yyyy> test dataform og create datafile
 - TProgressBar property out of range fejl er rettet i test dataform
 - Fejl med NumberOfOpenDatafiles er rettet i Test Dataform og Enter Data
 - CTRL-F12 funktion tilføjet som viser aktuel NumberOfOpenDatafiles
 - Fejl med CTRL-V i Add/Revise Checks rettet

 - Der er stadig et problem med de stringslists, der Free'es i CloseCheckForm

31-05-00
Mere fejlretning jvf. Jens' mails af 30/5
Edit find and replace:
- ReplaceAll gjort til global replace
- Ny meddelelse hvis der ikke findes ny text efter Replace-click
Fejl med at meddelse "Exporting rec. no." ikke vises er rettet
Fejl med export til excel rettet så DEL-records ikke giver tomme linier

01-06-00
Abort mulighed tilføjet i Find record og i Export
Progressform genimplementeret

NB! DER ER ET PROBLEM NÅR DER SKIFTES RECORD OG INDHOLDET ER ULOVLIGT!
- er rettet 2/6-00

02-06-00
Nye genvejstaster tilføjet til Add/revise checkbox (ctrl+piletaster)
AUTOJUMP tilføjet som check-kommando
Diverse stringlists, der ikke free'es bliver nu free'et...

04-06-00
Version 0.3 sendt til Jens og Mark

06-06-00
Bemærkninger af 5/6-00 fra Jens:
  Ret angivelse af pos og Lin i editor (byt om)
  Must Enter skal ikke applikeres ved tast af PIL-OP
  Fejlmeldinger ifm. NOT PeekDatafile synkroniseret

08-06-00
Så er der omsider styr på Optionsform og fonts
Fejl med IDNUM indstillinger i PeekDataForm rettet
Editor-save as viser nu korrekt filtype
Test dataform ændret til Preview dataform
Data in/out menupunkt ændret i henhold til Marks forslag af 7. juni 2000
Genvejstaster i Dataform ændret
  Prev Rec     Ctrl-PgUp
  Next Rec     Ctrl-PgDn
  First Rec    Ctrl+Alt+PgUp
  Last Rec     Ctrl+Alt+PgDn
  First Field  Ctrl+Home
  Last Field   Ctrl+End
  Scroll up    PgUp
  Scroll Down  PgDn

09-06-00
Fejl med ProgressBar property out of range rettet
Nu WarningDlg tilføjet

10-06-00
EpiData Version 1.0 Beta udsendt!!!

12-06-00
Datafile label tilføjet som funktion og som del af documentation og create datafile

13-06-00
Ny type af feltnavnsgenerering tilføjet i options og TranslateQes
Mangler at blive tilføjet i Første linie i REC-fil og i PeekDatafile

14-06-00
Feltnavnsgenereringstype gemmes og hentes i registry
VLAB tilføjet i første linie af REC-fil
PeekDatafile danner FVariableLabels
UpdateFieldnameInQuestion tilføjet

29-06-00
Value labels færdig (comment legal, --USE...)
Export til Stata af value labels mv. tilføjet

30-06-00
Export til Stata version 4/5 tilføjet
Der er stadig problemer med export af valuelabels til stata. CHECK!!
Har tilføjet indlæsning af AfterCmds i PeekCheckUnit (kun LET, IF og *)
Tilføjet ExecCommands i TDataForm. Mangler håndtering af IF

03-07-00
Har ændret CanExitField til ValidateField
Har tilføjet IF, Help, Hide, Unhide, Clear, Goto og Let som Check-kommandoer
Mangler ordentlig fejlmelding hvis indlæsning af check ikke virker
NoEnter tilføjet

23-07-00
Tilbage fra ferie!
Before Entry og After Entry kommandoer tilføjet som check-kommandoer
Tilføjet skrivning af Before og After Entry i SaveCheckFile i PeekCheckUnit

24-07-00
Rettet fejl i skrivning af check-fil i SaveCheckFile

27-07-00
PeekApplyCheckFile lavet om til StringsToChecks
LabelEditForm tester checks efter Edit Checks click i Add/Revise

29-07-00
AutoIndent tilføjet i Ed og LabelEditForm
Blokering af første linie i Edit Checks tilføjet
Temporært felt tilføjet i behandling af Edit Checks

30-07-00
Fejlmeldinger fra GetCommand rettet til
MakeDatafile gjort enabled når edforms er åbne
Fejl ved indsætning af rigtigt feltnavn i dataform er rettet
AUTOJUMP END og WRITE tilføjet
Find Record gjort tilladt fra NewRecord
Check box (ved add/revise) har fået ændret rækkefølge af inputboxe
Study description ikke længere del af document datafile
Udgave sendt til JEL (dateret 30/7)

03-08-00
Tekst i inputbox ifm. datafile label rettet
Funding organizations hyperlink tilføjet i aboutbox (Context no. 110)
Help menupunkter Info to testers og Open Bugreport skjult
Rettelse: Pil-op fra LastField udløser ikke længere "Write record?"
Taster Alt+1 og Alt+2 virker nu fra editor
Ved negativ validatefield markeres aktuelle felts indhold
Fejl med tolkning af checkkommandoer skrevet med små bogstaver rettet

08-08-00
Fejlmeldinger fra PeekDatafile forbedret
Export til Stata rettet så der kun skrives valuelabels for Integerfelter
Tilføjelse af NoEnter, After Entry, Before Entry og 'More' samt valuelabels i Document datafile

09-08-00
Jumps edit i checkbox rettet, så mellemrum omkring '>' fjernes før behandling
'Abandon changes' dialog tilføjet i edit all checks in field

10-08-00
Fejl med at status for toolbars ikke gemmes korrekt i registry er rettet
Navn på value labels tilføjet i documentation

11-08-00
NextWord rettet så også et enkelt ord i citationstegn læses korrekt
Welcome Window rettet til, så der ikke nævnes testning
HELP command rettet så TYPE= kan skrives med kun første bogstav af hjælpetype
CheckErrorForm tilføjet så checkfil kan åbnes sammen med liste over checkfil fejl
CloseAll tilføjet til EdForm

PRØV: Gem nummerering af labels til deres navn til variable (= færre NameIsUnique)

12-08-00
Version 1.0 Beta2 sendt ud til 10 testere

15-08-00
Export rutiner ændret til hurtigere læsning af filer
List Data tilføjet

16-08-00
Codebook påbegyndt: Har lavet rutiner til indlæsning af datafil mv.
MANGLER: scHourGlass når list data og codebook dannes

18-08-00
Access violation fejl i focus first field når der kun er eet felt er rettet
Diverse rettelser (fra JEL) i list data

19-08-00
Fejl i eReadOnlyNext rettet så korrekt antal linier i REC-filen læses (gav fejl i bl.a. stataexport)
Fejl i skrivning af lbllist ifm. export til Stata rettet

24-08-00
Sidste åndsvage lille fejl i export til Stata 4/5 rettet (længde af val.label navne)

03-09-00
Peg-og-klik feltnavn ifm. AUTOJUMP tilføjet
Defaultext ifm. save fra editor tilrettet
Append til LOG-filer tilføjet
Bedre håndtering af END found but ENDIF expected tilføjet i GetCommand (cmdIF)
Fejl i GetCommandList rettet (manglede check for EndOfChkFile)
DocumentDataBtn gjort åben når editor bruges
Document menu tilføjet til editor

04-09-00
Manglende keyboard short-cuts i CheckBox tilføjet (save, edit, exit)
SaveBtn i checkBox skifter enabled status sammen med CheckFileModified

08-09-00
ProgressForm tilføjet til List Data
ALT+5 (document) virker nu fra Editor
CheckFileModified settes nu selvom range/legal og jumps slettes
Revise RECfile from revised QES-file tilføjet
Overskrifter i selectfiles dialog ved revise rettet

11-09-00
Understregning i Menu tilrettet
I Revise datafile dannes værdien i nye IDNUM som CurRec+FirstIDNumber-1
Fejlmelding i Revise Datafile tilføjet når felter i OldFile ikke overføres
Fejl i Close All rettet
Tilretninger af hvornår Save Btn er Enabled i CheckBox er rettet

13-09-00
Fejlmelding gives hvis Revise Datafile køres med Epi Info datafiler hvor der findes lange feltnavne
TYPE= parameter i HELP commands får fjernet mellemrum
BUILD 1.0 (1309) LAGT UD PÅ WWW.EPIDATA.DK

18-09-00
Fejl rettet i GetCommand - LET formler (med implicit LET) virkede ikke
med feltnavne med længden 8.
BUILD 1.0 (1809) LAGT UD PÅ WWW.EPIDATA.DK

RETTELSER TIL KOMMENDE VERSIONER:
- Numeriske felter>14 chars skal accepteres

03-10-00
Export til Excel rettet så falsk bools bliver skrevet som falsk
Numeriske felter > 14 chars accepteres nu

09-10-00
Rettet DataFormUnit.ExexCommandUnit så datofelter (EU-type) bliver assigned som dato og ikke integer

11-10-00
Registration tilføjet i hjælpemenu
FIXEDSYS gjort til default font i dataform
Hjælpefil tilrettet

VERSION 1.01 frigivet

14-10-00
Comment Legal som kommando i IF-sætninger tilføjet
Numerisk plus-tast kan nu fremkalde picklist til comment legal
TYPE STATUSBAR command tilføjet

15-10-00
Index implementering påbegyndt
Mangler FileUnit.ApplyIndex

16-10-00
TYPE COMMENT tilføjet
Index begyndt. MakeIndex, ApplyIndex, Check for unique i Validate og tilføj til index lavet

17-10-00
Index håndtering færdig - har tilføjet skrivning til indexfil plus pakning af index key-numre

18-10-00
Tools-menu tilføjet
Validate duplicate datafiles påbegyndt

22-10-00
Copy datafile structure tilføjet
Mangler at rette problem med revise datafile hvor datafile.numrecords=0
Edit datafile label flyttet til Tools-menu

29-10-00
PeekDatafile: Læsning af header ændret til een ReadLn-linie
Begynder ændring af df^.Datfile fra Bytefile til utypet file - Sikkerhedskopi lavet
ListData flyttet til ListDataUnit
Ny eReadOnlyRecord tilføjet i FileUnit (til random access af textfiler)
Validate flyttet til ValDupUnit;

03-11-00
Validate dup. næsten færdig - mangler håndtering af eksisterende index-filer
Codebook tilføjet til menuen
Edit datafile label flyttet til Tools-menuen

04-11-00
Codebook færdig
Mangler stadig håndtering af eksisterende index-file i validate dup.

05-11-00
Codebook tilføjet Cancel-mulighed
Mangler at stoppe codebook og listdata hvis NumRecords=0
Tilføjet df^.ComIndex som samlet index
Rettet håndtering af datoer i index
Tilføjet brug af index i Listdata

07-11-00
Questions og labels i dataform gjort transparente, så Type Comments mv. kan ses
Indtastning OK hvis enten Range eller Legal eller Comment legal er OK
LegalPickList viser nu både Legals og Commentlegals
LegalPickListForm gjort sizeble

08-11-00
Rettet fejl som tillod felternavne der starter med tal hvis First Word is Fieldname
Tilladt range, legal, jumps for alle felttyper
Tilføjet kontrol af om værdier i legal, range, jumps er kompatible med felttype

13-11-00
Bug rettet ved dannelse af index i ValDupUnit (forskellige length i felter bliver ens)
Rapport summation påbegyndt i validate dup. (check tællere!)
Codebook tilføjet til Document menu i EdUnit
Håndtering af store lister ændret så de gemmes automatisk i temp. fil og derefter hentes ind
Aftalt med JEL: Put filnavne i ValDup i Registry. Læg rapportresume i ValDup i toppen.

14-11-00
MaxIndicis sat op til 10
Fejl i export til Stata af labels med negative tal rettet
Diverse rettelser i codebook's udseende
ValDup resume lagt i toppen og tilrettet. Tællere gjort i orden

15-11-00
ValidateField i DataFormUnit rettet så ENTEN legal ELLER Comment Legal godkendes
DecimalSeparator sat til punktum i MainForm.Create

17-11-00
Find Record gjort hurtigere (med eReadOnlyRecord)
ReviseDatafile har fået en progressForm med Cancel-mulighed
ApplyIndex ændret til hurtigere læsning (check af duplicates)

18-11-00
Find Record gjort endnu hurtige (ProcessMessages kun hver 20. gang)
Håndtering af indexerede felter tilføjet i Find Record

20-11-00
Rebuild Index tilføjet
Fejl i ValidateField (Legal / Comment legal checks) rettet
Cancelbuttom tilføjet i  dialog i Revise Datafile om forskel i Fieldnaming
LegalPickListForm.Width sættes til bredeste text

21-11-00
Rettet i Ed.Modified for ValDup, ListData, CodeBook
Default extension i forbindelse med Ed.Gem rettet så documentation får .Log

22-11-00
VERSION 1.2 SENDT UD

13-12-00
Legal Use tilføjet
Accept af \N i help-commands tilføjet
Brug af MISSING i expression tilrettet  (IF feltnavn=MISSING nu tilladt)

23-12-00
Udvidelse af Find Record påbegyndt

28-12-00
Tilføjet fejlvisningsparameter i options
Automatisk ændring af " til ' i expressions samt ændring til " i visning
Copy/paste i entryfelter i dataform tilladt
Ulovlige datoer fanges i Excel-export og StataExport og dBase III export
Dato konstanter tilladt i expressions ("14/09/1967") - NB! 10 chars i length, kun EuroFormat

01-01-2001
Punktum som MISSING værdi tilføjet
Dataform scrolling med PgDn og PgUp rettet
Farve tilføjet i TYPE STATUSBAR "tekst" [farve] og TYPE COMMENT [farve]
ENTER commando tilføjet (gør intet)

02-01-2001
Exit command tilføjet (springer ud af before-block eller after-block)
Goto write tilføjet
MANGLER: Tilføj preview dataform + gør noget ved TABs i editor
Fejl i nested IFs rettet
Brug af dot som missing value indarbejdet i prExpr (simple factor)

03-01-2001
Entryfield farve, 3Dlook, highlightfarve tilføjet
Sidst benyttede options-page huskes
Tilføjet DEFINE.
MANGLER reset af variable på passende tidspunkter

04-01-2001
Tilføjet Before/After File/Record
Har lave TDataForm.SaveRecord (NB! FormCloseQuery bruger ikke SaveRecord!)

05-01-2001
Har lavet LeaveField procedure og ændret strukturen for handlinger når et felt forlades
After Record udføres hvis RecModified og der svares Yes to Save Record
 - Der skiftes kun til ny/første/sidste/goto rec/find rec hvis NOT DidJump
Tilføjet reset af locale DEF-variable i UpdateCurRecEdit
MANGLER: Håndtering af globale variable i global TString-List

06-01-2001
Søgefunktion rettet så den omfatter 3 søgemuligheder

07-01-2001
Særlig fejlmelding ved CODEFIELD/CODES tilføjet
Der er mystisk problem med kolonneplacering i Document datafile
Dataentry notes funktioner tilføjet (F8 i dataform)
HandleInteger tilføjet
Flere options for fieldstyle tilføjet
DONE: Sæt flag for df^.CurrecModified ifm. LET-kommandoer
DONE: Reset af SelectFileForm

09-01-2001
Rettet i FirstWord så TAB-chars fjernes
Rettet i ReviseDatafile så (options=EpiInfoNaming) AND (REC_file=EpiInfoNaming) håndterets rigtigt
Automatisk fjernelse af TAB-chars tilføjet i EdForm
Håndtering af documentdatafile.text>65500 chars tilføjet
Rettet brug af SelectFilesForm så den Creates ved hver brug
/AUTO, /AUTOSAVE, /CONFIRM programparametre tilføjet
Autosave og confirm tilføjet som checkkommandoer
CONFIRMFIELD checkkommando tilføjet
FindRecord rettet mht. til Indexfelter
MANGLER at rette FindAgain (husk at gemme FoundRecs)
MANGLER at slette AField2 i Findrecord hvis søgefeltet er skjult

10-01-2001
FindRecord: nyt hurtigere søgeprincip ifm. index-felter
Genvejsbogstaver tilføjet til liniehøjde/feltstyle options
"Typepanel" tekst i dataform fjernes ved Dataform.Create
Preview datafile tilføjet til workprocessbutton "Make Datafile"
Restore default options knap tilføjet til options
Nævn i hjælpefil, at TYPE COMMENT ikke må stå i after entry ell.lign.
Tilføjet brug af @ i HELP kommando (husk at nævne brug af @@ i hjælpefil)
UNHIDE rettet så fieldcolor anvendes i stedet for clWhite
Tilladt tildeling af værdi med LET til boolean med b1="Y" / b1="N"
FindAgain tilrettet til brug af CanUseIndex

12-01-2001
Fejl med citationstegn, der forsvandt i IF-expressions, er rettet
Timeglas ændres til pil og statusbar ryddes ved afbrydelse af ApplyIndex pga. dublicates fejl
doFindRecord rettet så der tildeles rigtige, gamle søgefelter til FindRecOptions
Håndtering af IF boolean="Y" og "N" tilladt

13-01-2001
Fjernet at After file blev fyret af efter Add/Revise Checks
Filføjet IFCmd.IfShowExpr som er brugerens indtastning af IF-condition

15-01-2001
VERSION 1.3 Sendt ud

08-02-01
Håndtering af sprog tilføjet
WorkProcessToolBar's knapper tilpasses tekstbredden

09-02-01
GOTO WRITEREC tilføjet (ud over GOTO WRITE)
Print Selection fra Edform tilføjet
Fejl med citationstegn omkring LEGALS med mellemrum rettet
Fejl med at LEGALS blev til UpperCase rettet
Help tilføjet til LabelEditForm
Checkfunktioner WeekNum(date) og DayOfWeek(date) tilføjet (NB! Mandag=1, Søndag=7)

11-02-01
Align entryfields tilføjet
Fejl med skrivning i checkfil af type-colors rettet
Oversætters navn tilføjet i Aboutbox

13-02-01
Lavet ShowLegalPickList procedure med håndtering af SHOW og NOSELECT
MANGLER: Håndtering af SHOW og NOSELECT i peekApplyChecks (syntax??)  DROPPET!
Håndtering af Type Statusbar ifm. LET assignments tilføjet
Tilføjet Type Comment fieldname
FEJL i advarselsbox om at alle checks er ved at blive slettet!

19-02-01
Diverse tilretninger af tags m.v. af hensyn til sprog
Fejl med at Fieldblok med index giver "Index number already used" rettet
TYPE "lkjlkj" tilføjet
MANGLER: comments i Comment legal / legal / jumps
Håndtering af Range i forbindelse med LEGAL USE tilføjet
Håndtering af internationale hjælpefiler og EpiTour tilføjet
Engelsk sprog tilføjet som ressourcefil

21-02-01
RELATE påbegyndt (alle funktioner er commented ud)
Indbygget English vælges som standardsprog hvis language-fil ikke findes
/LANG= programparameter tilføjet
Brug af @feltnavn i TYPE tilføjet

24-02-01
Rettet Align Entryfields så der tages højde for krøllede parenteser
Rettet RemoveCurly så der tages højde for EpiInfoFieldNaming

VERSION 1.5 UDSENDT

26-02-01
Arbejdet videre med RELATE: håndterer åbning og CloseEvents
df^.Lastcommands tilføjet for at håndtere commands efter RELATE

11-03-01
Ved at lave index om til memorystream i stedet for TIndexFil:
 - Har rettet EpiTypes
 - Har checkes MakeIndexFile
 - Er ved at rettet applyIndex (Mangler checks for dublicates)
 Se også filen "Index - hvem bruger.txt"

12-03-01
Alt vedr. index rettet bortset fra ListDataUnit og ValDupUnit

13-03-01
Filter funktion tilføjet
ChangeRec function tilføjet

14-03-01
Relate og filter funktioner flettet sammen

15-03-01
File association option tilføjet

16-03-01
tilføjet ny option i ValDup: Ignore missing records in datafile 2
Soundex tilføjet som function i check-sproget

18-03-01
Return from relatefile med F10 eller Ctrl+R

19-03-01
Fjernet fejlmelding hvis der kommer tal efter type comment
KEYS=".." tilføjet til HELP command - resultat gemmes i RESULTVALUE og RESULTLETTER

20-03-01
Fejl med MustEnter rettet
Fejl i Revise Datafile hvor missing Float med NumDec>OldNumDec ikke forbliver missing rettet

22-03-01
Fejl med manglende mellemrum før FILELABEL i REC-filer rettet (Datafile label function)
Pack datafile tilføjet

23-03-01
Fjernet brug af Str( ) funktion og erstattet med Format af hensyn til decimaltegn
Rettet i Revise Datafile - håndtering af felter med færre/flere decimaler
WRITENOTE "..." [SHOW] tilføjet

24-03-01
Ryddet op i ReviseDatafile (bl.a. så tomme filer håndteres rigtigt)
Tilføjet eDlg (=MessageDlg)
Tilføjet GetField
Tilføjet *.not og *.log til filetype associate
MANGLER: Ordentlige iconer!!
rettet i Copy Datafile Structure så der automatisk indsættes *.REC
Tilføjet F7 (prev.rec) og F8 (next.rec) + F9 i CheckFilemode (Edit all checks)
Ændret i Field seperator selector i Exportform (export til text-file)

26-03-01
List data rettet så ny indexhåndtering håndteres
Tilføjet Tabpages når relate vises

30-03-01
Import af text-filer tilføjet
Tilføjet AnalysisTest

31-03-01
Import af dBase III/IV tilføjet

01-04-01
Change fieldnames tilføjet

05-04-01
MergeAppend påbegyndt

06-04-01
HandleVars flyttet til MainForm
Assert funktion tilføjet

07-04-01
Ændret i Recentfiles håndtering
ValDup index håndtering ændret (langsom?)

08-04-01
Listdata flyttet til ExportFormUnit
Ny opbygning af ExportForm
Filterfunktion m.v. tilføjet til ListData og Export to Text-file

09-04-01
Filterfunktion m.v. tilføjet til Export til dBase, Excel og Stata
MANGLER one2one i relate
MANGLER save-håndtering i relate
MANGLER iconer

10-04-01
Append datafiles færdig

11-04-01
SelectFileForm's opførsel generaliseret

13-04-01
Import to stata påbegyndt

14-04-01
Håndtering af value-labels i stata 4 import tilføjet

15-04-01
Import til Stata færdig
Rec2Qes opdateret til ny SelectFilesForm
Export til SPSS tilføjet

17-04-01
Recode function tilføjet

18-04-01
Revise datafile: ændret i test af felt-kompatibilitet (hurtigere)

19-04-01
tilføjet WriteNextRecord-funktion i FileUnit
Tilføjet brug af WriteNextRecord i Revise Datafile
Tilføjet RecordNumber variabel i check-sproget

21-04-01
Import, Recode, append ændret så WriteNextRecord anvendes istedet for peWriteRecord
Slutmeddelelser ved import ændret så antal importerede records nævnes
REPORT feltnavn commando tilføjet til ASSERTBLOCK (Ingen report=report recordnum)

22-04-01
COMMENT LEGAL datafilename tilføjet.

23-04-01
Count Values tilføjet. MANGLER: Angiv filtal i header + korrekt sortering af numeric

24-04-01
Merge færdig - Mangler lidt mere testing

Givet til JEL

25-04-01
MANGLER: Indsæt mellemrum i Lang(20446) før ordet already

26-04-01
Rename fejl i revise, pack, recode rettet
Document menu i EdForm tilrettet så den er magen til MainForm.Document
List data: heading ændret i udskriften
Tools menu ændret
Comment legal *.rec ændret så opslag står i rækkefølge
'external exception C000001D' fejl ifm. append rettet

27-04-01
Ændret default dir i count records + ændret i output text
Diverse rettelser jvf. EpiData 2.0 BETA rettelsesliste af 27. april 2001
Bitmaps i Merge ændret

28-04-01
Import fra Stata 7 tilføjet
Export til Stata 7 tilføjet

29-04-01
Export til EpiData påbegyndt

01-05-01
Import af Stata ændret så mere optimale feltbredder opnås

03-05-01
SelectFilesForm: Sidst brugte filer huskes

04-05-01
Export til SPSS rettet så der anvendes extern datafil
Merge tilrettet, så bruger bestemmer hvor common fields' data tages fra
AddToNotesFiles function tilføjet (bruges af merge og recode)

05-05-01
JUMPS RESET char tilføjet. Regler: Virker ikke med Autojump og med JUMPS WRITE.
  IDNUM, Today, EuroToday resettes ikke.

08-05-01
Comment legal SHOW tilføjet
Print dataform tilføjet

09-05-01
Registry entries vedr. MainForm ændret så wsMaximized gemmes
Options font-valg rettet så dialogboksen viser den aktuelle font

13-05-01
Iconer til REC,QES,CHK,NOT og LOG tilrettet. AVI lagt i EpiRes.Res
Epidata.lbl læses fra RECfilens bibliotek, hvis den findes der, eller fra programbiblioteket
MANGLER: Test af Add/revise checks med fejlbehæftet REC-fil
Untitled titel ændret for listdata, valdup, etc. så der tilføjes et windowNum
Decimaltegn i ValDup og Codebook sat til punktum
AUTOJUMP SKIPNEXTFIELD og JUMPS  X>SKIPNEXTFIELD tilføjet
COMMENT LEGAL SHOW ændret så kun popup hvis feltet er tomt
LegalPickList tilføjet det kaldende felts navn i caption
ASSERT ændret til LOGICAL CONSISTENCY CHECK

14-05-01
TIME2NUM og NUM2TIME functions tilføjet
Ændret ExecCommandList så alle numeriske værdier kan tilskrives både ftInteger og ftFloat
Rettet i translateQes så tomme linier også skrives

15-05-01
Toolsmenu tilføjet til EdForm
Align entryfields rettet ind efter bredeste fieldname

16-05-01
ProgressBar tilføjet til ValDup
InsertFieldContents (@fieldname) function tilføjet (bruges af WriteNote,cmdHelp og TypeString)

19-05-01
Codebook fået tilføjet ExportForm interface (=valg af record range og valg af felter)
Codebook tilføjet mulighed for udskrift af alle checks

30-05-01
Export til EpiData optimeret mht. hastighed
Append optimeret mht. hastighed (GetField kald reduceret)

03-06-01
peReadRecord og peWriteRecord optimeret mht. hastighed (df^.datFile er ændret til FILE i stedet for ByteFile)

04-06-01
Saveregler for relate på plads
One2One på plads
Drag and drop fra explorer tilføjet
Brug af registry ændret til brug af INI-fil
/INI programparameter tilføjet

05-06-01
Consistency checks tilføjet håndtering af report-felt missing
Export til REC-fil tilføjet export af valuelabels til ny chk-fil

09-06-01
Check for duplicates i key unique felter tilføjet til rebuild index (HasDuplicates function)

10-06-01
Compress datafile tilføjet. MANGLER except-håndtering ift. at lukke datafiler

12-06-01
Function ProgressStep (EpiType) tilføjet

13-06-01
Rec2Qes rettet så der sættes krøllere parentereser mv.
TIL HJÆLPEFIL: *.lbl filer fejlcheckes ikke
Labels qes-filer > 80 tegn knækkes over i et antal labels af max 80 tegn
CHECKLEGAL, CHECKRANGE, CHECKMUSTENTER tilføjet til consistency checks
Hastighed i ReviseDatafile optimeret (antal GetField kald reduceret)
Navngivning af ny label i Add/revise ændret til label_feltnavn

16-06-01
SaveDlg position huskes
eDlgPos tilføjet
PickListForm position huskes (inden for sessionen)
Fejl i rename fieldnames (vedr. ftQuestion) rettet
Check af KEY UNIQUE tilføjet til MakeIndex

18-06-01
Håndtering af relate rettet
MANGLER tilretning af exec-cmdRelate når flere relatecmds efter hinanden

19-06-01
Fejl i Stata import (vedr. string vars og exception håndtering) rettet
Fejl i Stata export hvor '.' i strenge laves til decimalsep rettet

21-06-01
Rettet i Stata import så buffer kan håndterer filer med op til 800 vars.

24-06-01
Rettet fejl i peekDatafile vedr. COMMENT LEGAL datafilename
Export til SAS tilføjet
Today og EuroToday opdates automatisk ifm. peWriteRecord
Access violation ift to SHOWLEGALLIST lige efter hinanden fjernet
TBooleanLiteral.AsString rettet til at returnere Y eller N
Lange integers sendes som integer til prExpr hvis FNumDecimals=0
RELATE gennemføres ikke fra felt med missing value
Sikret ordentlig nedlukning ifm. fejl i en relatefil (når hovedfil åbnes)

27-06-01
SaveDlgPos rettes ind efter Screen ikke efter MainForm
SHIFT+DEL giver advarsel om orphans i filer med df^.HasRelate=True

28-06-01
Dataentrynotes box position huskes (inden for sessionen)
HELP cmd's box position huskes (inden for sessionen)
Logical consistency check ændret til Consistency Check
F10 lukker dataform
+ tast i Add/Revise åbner Edit labels
Filter + readonly texter ændret fra rød til blå
Hints i Checkbox ændret til at indeholde eksempler
Fejl med nulstilling af RelateFiles:TStringList hvis fejl i een af relatefilerne rettet
Append/Merge rettet så alle checks overføres til dfC^.CHKFilename

30-06-01
Fejl i Find Record rettet så der kan søges i forudstående records med index

Sommerferie

03-08-01
LegalPickList ændret til combobox stil
Rettet i PeekDatafile, så headere uden baggrundsfarvekode i første linie kan læses
Advarsel tilføjet som vises første gang der skiftes fra et rettet felt med TAB eller mus.
Codebook: Med decimal eller uden decimal og uden label vises mean/spredning ellers vises freq.
Type comment fieldname udviddet så der kan skrives til et numerisk felt
Bedre håndtering af missing i prExpr
Find record udvidet så xx equals . (missing) er tilladt

05-08-01
checkfunktioner CountMissing(v1,"v5-V10",v29) og Sum(v1,"V5-V10",V30) tilføjet
PgDn og PgUp i Dataform ændret så der bladres 15% mindre end den fulde skærmhøjde

06-08-01
MissingAction parameter tilføjet (RejectMissing sat til default)
Checkkommando IGNOREMISSING tilføjet
Lang-fil ændring: 1704=&Keyboard Short-cuts
Lang-fil tilføjelser:
  50218=It is recommended that you use the ENTER key to go to the next field during dataentry.
  50220=If the TAB key or the mouse is used then only the most basic validation is done
RANGE kommando tilføjet
Sum kommando tilføjet

07-08-01
LegalPickListBox ændret lidt i opførsel
Splashscreen ændret Fyns Amt til EpiData Association
F10 tilføjet som lukke mekanisme ved epitorvinduer
Fejl i Jumps SkipNextField rettet

08-08-01
SUM funktion ændret så den har samme opførsel som V1+V2+V3 etc.

10-08-01
LegalPickList box fået sidste tilretning

VERSION 2.0 SENDT UD!!!!

15-10-01
Datafiler lavet til TFileStream
Musebox fjernet
Oversættelse af "Begins with" (3841), "Contains" (3842), "Equals" (3840) tilføjet
Fjern 50218,50220 i oversættelsesfil
Import dBase rettet så missing værdier håndteres korrekt
Rettet import af Stata så negative værdier håndteres korrekt
Indexfejl ifm. numeriske felter rettet (opfattede 06 og 6 som forskellige værdier)
Codebook håndtering af freq-lister + mean ændret
Access violation ifm. PIL-ned på Preview Dataforms uden felter fjernet
Fejl ifm. søgninger rettet
DEFINE <A    > ændret så <Aaaaa> kræves
Fejl med TYPE= i HELP commands rettet
MaxIndecis ændret fra 10 til 20
Backup kommando tilføjet
Oversættelse:
  21512=Can't create backup directory %s
  21514=Ready to begin backup of %s to %s
  21516=Error in backup of %s
Export af textfil: option "Write fieldnames in first line" tilføjet  (3715=Write fieldnames in first line)
Oversættelse: "Write fieldnames in first line" i 3715
Fejl ved import af textfiler (ved komma mv.) rettet
Oversættelse: ret 101=2.0 til 101=2.1
Type Statusbar felt+text anvendes ifm. dataentrynotes (F5)

22-10-01
Ifm. fejl i indtastning bliver feltet markeret
Fejl med export af negative tal til Excel rettet

3-11-01
Fejl med LabelPickList (vist) omsider fundet (PickListForm.Left aflæst efter PickListform.Free)
Hvis alle elementer i PickList har længden 1 så returneres uden brug af enter

9-11-01
Warning Sounds option tilføjet
Lyde ved boxe tilføjet
BEEP [WARNING|CONFIRMATION] command tilføjet
Oversættelse:  4436=Sounds   4438=&Warnings during data entry
/FYSMENU program parameter tilføjet

25-11-01
Kontrol af ftUpperAlfa felter og små bogstaver i LEGAL/Comment Legal tilføjet
Fejl med < > fjernes i DEFINE af checkmodulet rettet

10-12-01
Implicit MustEnter tilføjet ifm. Key Unique
TLabelRec ændret så value kan være 30 char og label kan være 45 char
Recode afbrydes ved fejl i IF-sætninger i recodeblokken

14-12-01
Kald til dataentrynotes rettes så EM_SCROLLCARET kaldes

16-12-01
Fejl i SPSS export ved alfa felter = MaxAlfa længde rettet

17-12-01
Version 2.1 UDSENDT

15-01-02
EpiTypes, FilesUnit, PeekCheckUnit forberedt til brug med epidat.DLL (med DEFINE epidat)
Fejl i SAS-export rettet som gav probs. ifm. med lange filnavne.
Fejl med datoer med måned=0 og dato=0 rettet

16-01-02
Princip for export til SPSS ændret = bedre håndtering af records

22-01-02
ExecRecodeCommandList ændret så fejl i udførelse stopper recode
Test for dato ændret så dato=0 giver korrekt fejlmelding (gælder f.eks. export)
IF tests rettet så 0 i integers og floats ikke længere opfattes som missing

23-01-02
Rettet i Stata import så missing values i b-felter importeres som tomme

VERSION 2.1a UDSENDT

25-3-02
LOAD commando tilføjet i peekCheckUnit (getCommand og AddCommandList)
MainForm.Handlesvars ændret så brug af UDF er forberedt
UDF indarbejdet. MANGLER fejlhåndtering

27-3-02
Relate-træ tilføjet. MANGLER lidt

27-4-02
TAB key rettet så den ligner ENTER. Rettet i onKeyPressEvent og TDataForm.FormKeyDown +
tilføjet TDataForm.CMDialogKey
Advarsel tilføjet ved tomt relatefield - SKAL OVERSÆTTES

28-4-02
Menu struktur i Main ændret så Clear all checks er sat under Tools
TopOfScreen [n] tilføjet
PgDn, PgUp, Home, End tilføjet til LegalPickListForm
Find field tilføjet til Dataform (også i checkfilemode) med df^.FieldNamesList incl. var-labels
RECORDNUMBER identifier tilføjet
Datafelter ændret så der kan indtastes datotal og ikke andet => aktuel md og år

29-4-02
Stata letter case option tilføjet til export
Dataentrynotes tilføjet rec-nr for new records

9-5-02
Hint window tilføjet til relatetree (højreklik på datafil)

20-5-02
Hint window i relatetree forbedret med mouse capture
MainForm.LeftSplitter og RightSplitter sat til visible/invisible på rette steder

7-6-02
Tilføjet første skridt til at kunne skifte relateniveau direkte udenom relatefield (se dataform.onActivate)

18-6-02
Ændrer feltnavnelængde til 10 chars
 - test revise
 - test export to SPSS
 - test export to SAS
 - test import fra dBase
 - test import fra Stata 7
 - test omdøbning af feltnavne

Når datafil gendannes så genbruges fillabel
Ny checkcommand BACKGROUNDCOLOUR tilføjet

24-6-02
Fejl i PeekCheckUnit.ReadAssertBlock rettet så "end" læses som "END"
Fejl i håndtering af LET sætninger som gav access violation ved ukendte felter
Rettet DEFINE så dobbelt def af ENS globale variable med samme navn, type, længde er tilladt

25-7-02
Arbejdet videre med TDataForm.OnActivate mht. changerelatelevel - Har visse probs.
Tabpages i main vindue ændret til een linie (og dermed pile)

02-8-02
Color table menupunkt tilføjet under tools i main og i ed
COLOR BACKGROUND tilføjet
COLOR QUESTION/DATA tilføjet (bruger enten epidata feltbetegnelser eller epi info coder)
TDataForm.OnActivate fjernet igen
Fixed font anvendes til LegalPickForm + formattering af data
Relate field pick list tilføjet (shift F4 eller F4+F4)
Nye symboler i relatetree (også angivelse af active relatefile)

6-8-02
RetriveCommentlegal ændret så der checkes for om com-leg værdi er bredere end felt
Lang-kode SKAL tilføjes for 'Deleting this record might result in orphaned records in the files related to this file' (DataFormUnit)
Lang-kode 1710 (registration on-line) ændret til "&EpiData e-mail news" i dansk og engelsk
Lang-kode 1712 (About registration) ændret til "A&bout e-mail news" i dansk og engelsk
HELPCONTEXT 130 i hjælpefilen skal rettes fra About registration til About e-mail news
JEL: mail 1/8 siger acc. viol. ved lukning af qes-fil når preview åben - kan ikke rekonstrueres
HJÆLPEFIL SKAL IKKE HAVE TOP-OF-SCREEN ATTRIB.
PROGRAM INSTALL. BIB SKAL IKKE INDEHOLDE VERSIONSNUMMER
JEL: mail 2/8 siger ny rec tilføjes pga. glob variable - kan ikke rekonstrueres (john - jpediad@med.uoc.gr)
Relate field pick list ændret i rækkefølge af oplysninger
RELATE system ændret så RELATE qid member.rec kan stå i qid-feltets feltblok
RENAME FIELDS ændret så der godt kan ændres feltnavne trods fejl i checkfil (gives advarsel)
JEL: "Tekstfelter som relate virker ikke" - ikke forstået eksemplet virker fint - uddyb
Fejl med accessviolation i hc-gener fra Alberto rettet (skyldtes com.leg. SHOW i første felt i relate fil)

11-08-02
Rettet i ShowPickList så den værdi der indsættes bliver trimmet
RelateTreeForm dockstatus og koordinater gemmes i INI-fil

12-08-02
Eksperimenteret med esc-filer....

14-08-02
Find by example påbegyndt
FindRecordForm ændret så værdifelt 1 står øverst i tab-order
F7,F8 sat til at virke i readonly
PickListWidth, /-pos tilføjet til INI fil

17-08-02
HUSK JUMPS RESET MED I HELP-FILE STIKORDSLISTE
Søg og erstat dialog i Ed ændret, så klik på Erstat før første fund giver en "find next"
Import af Stata ændret så ulovlige tegn i feltnavne fjernes

19-08-02
Kontrol af key unique værdier tilføjet i håndtering af cmdLet
Export til Stata ændret så valuelabels navne bevares ved export til Stata 7
Color table ændret så det lukker med ESC
COLOR DATA ændret så der kan gives tre parametre: entryfelt_textfarve, entryfelt_baggrund, entryfelt_highlight

21-08-02
Next Record, Del record og save record deaktiveres hvis df^.IsReadOnly
Label editor vindue (=dataentrynotes vindue) lavet om til richEdit => 64kb
KEY UNIQUE duplicates fejl i LET-cmds => at der ikke flyttes til næste felt
CurRecModified flag sættes til FALSE efter execcmdlist(beforefile/beforerecord) af hensyn til LET i IFs 

24-08-02
Rettet Dataentrynotes vindue (LabelEditForm) så richedit gemmes som plain text
Rettet meddelelse ifm. tomt relatefelt
RET I HJÆLPEFIL: BACKUP cmd SKAL placeres i AFTER FILE for at virke korrekt
Udførelse af After File cmds flyttet fra TDataForm.CloseFormQuery til CloseForm
cmdBackup tilføjet til TDataform.ExecCommandList fra DisposeDatafilePointer
HUSK EXECUTE CMD I HJÆLPEFIL
ER BEEP NÆVNT I HJÆLPEFIL?
EXECUTE tilrettet. Syntax: EXECUTE cmd [params] WAIT|NOWAIT [HIDE]  - husk citationstegn
  execute tekstfil.txt WAIT
  execute nodepad.exe "en anden tekstfil.txt" NOWAIT
  execute dozip.exe "parameter1 parameter2" NOWAIT HIDE
Fejl i Stata import rettet (forkert navngivning)

25-08-02
Når duplicate records findes ifm. KEY UNIQUE gives tilbud om spring til relevant record
(gælder både ifm. onExitEvent og ifm. LET-cmds)
Til Jens: skriv kun Backup kommandoen i øverste niveau
Besked ved backup udført udenfor AFTER FILE rettet
BACKUP command afvises i add/revise checkfile
BACKUP udføres kun hvis der har været skrevet til datafilen
@feltnavn kan nu bruges i execute's kommando og i parametre, exempel:
  ID
    tmpFilnavn = "d:\mib\billed"+string(ID)+".bmp"
    execute mspaint.exe @tmpFilNavn NoWait
  end

  Åbner Paint med billed1.bmp, billed2.bmp etc. alt efter ID's værdi

Execute parametre: execute pkzip "t.zip dns\*.*" wait er rigtige syntax - måske forkert bibliotek?
Ret 21514 til "Starting Backup to %s"

26-08-02
F11 lukker relatetree hvis det er docked - ellers bringer den relatetree til top
Sprogfil tilrettet

27-08-02
Spring til fundet KEY UNIQUE record tilrettet så resten af after entry ikke udføres

30-08-02
Rettet i onExitEvent, så ikke-rettede records med sender=lastfield ikke udfører en ChangeRec(+1) hvis DidJump
CHECK OM RESULTNUMBER GIVER EXITCODE IFM. EXECUTE-CMDS

31-08-02
Tilføjet ordentlig error-handling ifm. writeRecord og Readrecord (3 forsøg...)

05-08-02
Rettet i DestroyValueLabels så tom valuelabel ikke giver acc.viol.

10-09-02
Knaptekst ifm. revise (ved loss of data) ændret til OK/Cancel

11-09-02
LegalPickForm: højde gemmes i INI-fil

12-09-02
Fejl i stata export (case valg virkede ikke) rettet
ftPhoneNum og ftLocalNum rettes til ftAlfa (HVAD MED HJÆLPEFILEN?)
Rettet i OpenRelateFile så der gives mulighed for at se fejl i checkfiler
Rettet i DataFormUnit.UpdateCurRecEdit så ExitExecutionBlock sættes til false før kørsel af BeforeRecordCmds

16-09-02
Rettet så relative filnavne virker korrekt i relate og commentlegal
SIG TIL JEL: anvendt \ og ikke / i relative filenavn (data\vll.rec)
Rettet export til Stata så mellemrum og $-tegn i labelnavne erstattes med underscore

EPIDATA 2.1b SENDT UD!!!!

21-09-02
Rettet consistency checks så CHECKRANGELEGAL er tilføjet

08-10-02
Rettet export til EpiData så der læses korrekt record ved afgrænsning med frarec-tiltil

09-10-02
CLEAR COMMENT LEGAL tilføjet (bruges til at slette FCOMMENTLEGALREC ifm. IF-THEN)

15-01-2003
Begyndt tilføjelse af <C   >, Felt oprettes og læses men mangler kodning/dekodning + tilføjelse overalt!
<YYYY/MM/DD>, <TODAY-YMD> tilføjet

16-01-2003
HUSK: Revise datafile skal danne kodeord hvis der dannes nyt cryptfelt
Alle units checket for tilføjelse af nye felter

17-01-2003
HUSK: Lang kode 5858 skal være "Reverse style (&yyyy/mm/dd)"
      Lang kode 4643 skal være "<&yyyy/mm/dd>"
      Lang kode 4647 skal være "<Tod&ay-ymd>"
      Lang kode 4635 skal være "&Crypt textfield"
Tilføjet crypt funktioner + properties i df
Næste: dialog som danner key ved CreateDatafile

18-01-2003
HUSK: Sørg for kodning af cryptfelter der bruges til index
HUSK: Hvis Key='' så skal cryptfelter være readonly - ER GJORT I PUTFIELDSONFORM
peWriterecord, peReadRecord gjort klar til crypt
Fjernet FocusFirstField i MainForm.OpenRelateFile så Before Entry i første felt ikke fyres af
Blowfish erstattet med Twofish
Dataform gøres readonly hvis df^.Key=''
Crypt tilføjet i peWriteNextRecord, peReadOnlyRecord mv. samt i index-håndtering

22-01-2003
Tilføjet ShowVarInfo (F2)
HUSK: oversættelse af passwordform
Rettet <C    > til <E   > plus rettet crypt til ENcrypt

25-01-2003
Rettet index key unique fejl i peWriteRecord som gjorde det muligt at lave dublicate records trods key unique

31-01-2003
Caption ændret så build er tilføjet
Variabel info fremkommer ved kun 2 tryk på F2
Tilføjet oplysninger om åbne filer (incl. relates og key-fields) til variabel info (showVarInfo)

01-02-2003
Crypteringsystem ændret til Rijndael
Relatehåndtering ændret så eventuel Type Comment Statusbar opdateres korrekt
Tilføjet SaveIndexFile som ctrl+Shift+F2
Håndtering af krypteringsfelters længde ordnet (bruger Fieldcolor i rec-fil header)

03-02-2003
Fejl i læsning af crypt-felter rettet, så anden og efterfølgende forekomst får rigtig længde i PeekDatafile
Håndtering af filnavne i relate xx filnavn og comment legal filnavn tilrettet, så der anvendes
  korrekte relative filnavne (ses altid ud fra aktuelle rec-fil)

05-02-03
ShowLegalPickForm ifm. F4 og F4+F4 rettet så LegalPickForm sættes lig med NIL efter Free

09-02-03
Forsøgt rettet så manglende indexfiler til comment legal ..rec dannes - Mislykkedes...

11-02-03
Rettet exportform så der gives advarsel hvis der ikke er parentereser i filterudtryk med AND eller OR

24-02-03
Backup kommando (checkfil) ændret så biblioteksstruktur bevares

22-03-03
Aktuel udgave sendt til Jens

20-04-03
CheckObjUnit dannet - StringsToChecks kan håndteres som object!
LabelEdit ændret så TParser anvendes

21-04-03
INCLUDE command tilføjet (kan bruges overalt - dog ikke i includefiler)
Automatisk rebuild index tilføjet i forbindelse med comment legal *.rec
Accept i checkmodul af MISSINGVALUE x [x [x]] i feltblokke og MISSINGVALUE ALL x [x [x]] tilføjet
Indtastning af MISSINGVALUEs tilføjet ved check af range/legal
Def. af MISSINGVALUE i feltblok har forrang for global MISSINGVALUE
Global missingvalue tillader kun tal som værdier
TYPE COMMENT ALLFIELDS COLOR tilføjet som feltblokcommand og cmd-command
TIL SPROGFILER: 372x = EXPORT TO STATA version 8
Export til Stata 8 næsten færdig - mangler håndtering af missing

23-04-03
Ny søgefunktion næsten færdig - mangler FindAgain + håndtering af fremhævede felter

29-04-03
Oversættelse: af findtoolbar-knappers hints

3-05-03
Ny søgefunktion ændret: toolbar tilføjet, FindAgain princip ændret

14-05-03
Har forsøgsvis fjernet mainform.repaint i PutFieldsOnForm og i TranslateQes

21-05-03
Rettet fejl i HandleVars som gjorde at encryptionfelter ikke kunne håndteres i beregninger
Tilpasses consistency check så værdien af det felt der fejler checkrange etc. vises

30-05-03
AUTOSEARCH påbegyndt - mangler håndtering af "Record exists - edit this?" + gå videre til næste + LIST

4-06-03
Stata 8 import færdig - missing ., .a, .b og .c håndteres korrekt (som "", 9999, 88888, 77777)
NB: Label med missing eller > .c som værdi ignoreres

05-06-03
List data ændret så .a, .b og .c vises som missing (som punktum)

06-06-03
Export stata8 tilrettet til at håndtere missing values

07-06-03
*-kommentarer er nu tilladt i label-blokke og i comment legal
Ændret i add/revise: comment legal recfilename.rec checkes ikke for fileexists, index etc. (sker først under indtastning)
TLabelRec ændret så value kan være 30 char og label kan være 80 char

08-06-03
MISSINGVALUE v1, v5-v10, v14, v20-v30 7 8 9   tilføjet
Oversæt: Export to EpiData options i ExportForm
Export to EpiData: Tilføjet ny option: Sorter efter index
Louk's tryout filer mangler en forklaring!
Fejl i SPSS export rettet (opstod med textfelter med længden 80)

09-06-03
Louks key-unique fejl fundet og rettet (tilføjet validate keys i LeaveField())

18-06-03
Autosearch (list) tilføjet
Viewer tilføjet (HUSK OVERSÆTTELSE AF EDIT-menupunkt)
Tilføjet UseIndex as sortorder til alle exportfunktioner
Ny, ny søgefunktion gjort færdig
ENTER gjort lovlig, men ignoreres
Nyt check af sprogfil - kun advarsel hvis gammel version

19-03-03
Quit command tilføjet til checksprog
MANGLER: Codebook håndtering af .a, .b, .c

20-03-03
Grid copy tilføjet i viewer + Open checkfile funktion
Rettet fejl i Edit Datafile Label, som gav forkerte filer hvis der tilføjes label til datafil uden label i forvejen

21-03-03
Sidste rettelser på SearchForm lavet (Reset btn + criteria samples)
Engelsk sprogfil opdateret

3-07-03
Fejl i forb. med TYPE COMMENT ALLFIELDS (i AddCommand) rettet så der ikke gives Acc.Viol
Fejl i NameIsUnique rettet (gav mellemrum i navn, V115 -> V 116 etc)

13-08-03
Zip/unzip/encrypt/decrypt files påbegyndt
HUSK: oversættelse i tools menu af zip files og unzip files

16-08-03
zip/unzip/encrypt/decrypt færdig
Søgeform rettet, så ENTER ikke skifter linie men i stedet udløser ModalResult:=mrOK
Er cmdQuit tilføjet i EpiC?
cmdCopyToClipboard tilføjet
Rettet i Revise datafile, så der ikke promptes for password i nye qes-filer med encrypt-felter,
  hvis den oprindelige datafile allerede indeholder encryptfelter og dermed et password. Gammel fils
  password overføres til ny datafil.
Fejl rettet i læsning af autosearch list, så er ikke opstår acc.viol. ved manglende feltnavn
Genvejstaster i View data file rettet til (tilføjet ctrl+U og ctrl+L)

22-08-03
RECORDNUMBER sat lig med RECNUMBER i HandleVars
Autosearch ændret så manglende feltnavn(e) betyder autosearch på aktuelle felt
HUSK oversættelse af zip/unzip tekster
Søgeforms position huskes
Oversættelsestag 3003 skal sættes til: Credits and version information
3004 til Funding of development
Fejl i test af range/legal i forbindelse med MISSINGVALUE rettet (både global og local missing gav probs)

23-08-03
Optælling af MissingValues tilføjet til codebook

31-08-03
Sidste tilretninger af zip/unzip form og funktionalitet
Tilføjet info om EpiData version+build i ShowVarInfo

04-09-03
Endnu en fejl i NameIsUnique rettet

Sendt til Jens

08-09-03
Flag for igangværende zip/unzip operation tilføjet så MainForm ikke kan lukkes før zip/unzip er afsluttet
Åben file (ctrl+O) bruger *.rec som default

13-09-03
MainForm.InitTranslations tilføjet (oversætter felttype ord mv.). Kaldes fra InitLang
Korrekt opførsel ved Cancel af indtast password ifm. CreateDatafile
Tilføjet at der tages højde for citationstegn omkring include filnavne
Password i krypt-filer kræves ikke ifm. Rec2Qes, File Structure

16-09-03
Rettet i revise datafile så indexfil slettes 

03-11-03
Tilføjet skjult funktion under dataform|Filer: Export to textfile
Rettet fejl (fra Gerald) vedr. autosearch, som gav forkert record efter autosearchsøgning der ikke gav fund

13-11-03
Tilføjet kommentarlinier til SPSS vedr decimalseparator

VERSION 3.0 sendt ud

13-01-2004
Tilføjet revise datafile som option under toolbar knappen Make Qes-file
Ændret toolbar knap "Open qes file", så qes-filer er standard filformat
Feltnavnet "Date" ændres automatisk til "Date1"
Fejl ifm. Legal + ShowLegalPickList som gav fejl pga. at +-tegn er ulovligt, rettet
ShowLegalPickList viser nu også definerede missing values
Håndtering af Missing Values i dato fields tilføjet

Build 3.01 sendt til Paris

13-02-2004
View Datafile ændret så der anvendes DrawCell + MemFile = HURTIGT!

14-02-2004
Kontrol af qes-fildato sammenlignet med rec-fildato tilføjet i DoOpenDatafile
Rettet fejl så det er muligt at lave beregninger med ymddate og ymdToday

15-02-2004
Fejl vedrørende farvestyring (COLOR QUESTION xx <> TYPE COMMENT ALLFIELDS xx) rettet, så 2 ikke tager precendens over 1
Fejl som gjorde at autojump i sidste entryfield ikke blev respekteret er rettet
Ved dannelse af ny rec-fil med krypterede felter, så skrives der ikke "rec-fil dannet" hvis bruger taster Cancel i stedet for at give et password
Fejl rettet vedr. TYPE COMMENT ALLFIELDS xxx, som ikke blev håndteret korrekt i feltblokke i forb med add/revise checks
Add/Revise checks: autojump + mellemrum giver mulighed for at vælge feltnavn med museklik

18-02-2004
Copy structure rettet, så password overføres korrekt til den nye fil
Find Again rettet, så en rettelse i aktuelle record medfører test af input + saverecord
Rettet meddelelser i tidsstempel kontrolsystem (if qes-date > rec-date)

19-02-2004
Progressbar tilføjet til zip og unzip archieve

20-02-2004
Acc. Viol. ved AFTER FILE - BACKUP - QUIT - END i relatesystemer fjernet

01-03-2004
Grid1 i GridForm ændret så goEditing er slået fra som standard
Dum fejl i automatisk revise-system rettet (testede for mrOK i stedet for mrYes)
Function der husker passwords i 5 minutter er tilføjet

7-03-2004
Beta version af 3.02 sendt til Jens

12-03-2004
Rettet så preview dataform ikke giver fejl hvis aktuelle MDIChild is TGrid (view datafile)
Rettet copy i View datafile, så det virker
Søgeform: F4 virker uden for grid

VERSION 3.02 lagt på www.epidata.dk

8-4-2004
Functionen "Feltnavnet "Date" ændres automatisk til "Date1"" fjernet!

9-4-2004
zip/unzip funktion: select directory ændret til windows standard
unzip: advarsel gives hvis filer ikke er udpakket fordi de allerede eksisterede
Import af Stata 8: Fil afvises hvis der er tekstfelter med længde>80
Export til SPSS: SET DECIMAL=DOT  tilføjet før DATA LIST

Version 3.02 af 10/4 sendt til JL

30-4-2004
unzip: advarsel hvis filer ikke er udpakket ændret til at hele stinavnet kommer med, ikke kun filnavnet
Punktum tilføjet efter "SET DECIMAL=DOT" i export til SPSS
Fejl i søgeform rettet, så F4 virker korret

Version 3.03 beta påbegyndt

2-6-2004
Double entry påbegyndt

9-6-2004
Tilføjet mulighed for at udpege keyfield 

12-6-2004
Double entry med keyfield virker nu - keyfield SKAL være key unique i original datafil - MANGLER test af det

14-6-2004
Tilføjet håndtering af "Ignore textfields"

17-6-2004
Rettet diverse i double entry (tekster m.v.) jf. JEL's mail

18-6-2004
Tilføjet håndtering af double entry test ifm. save record
Tilføjet valideringsflag ved alle records

06-8-2004
Rettet kvittering i prepare for double entry (delt over flere linier)
Diverse knaprækkefølger og tekster ifm. double entry rettet
Advarsel i CopyStrucUnit hvis fil allerede eksisterer rettet til NoYesDlg i stedet for eDlg
.zip.key filextension ændret til .zky

15-08-2004
Ny checkkommando: showlastrecord tilføjet
Nye parametre til checkkommando BACKUP, syntax: BACKUP "destination-library" [ZIP filename [date]]
                                        or      BACKUP "destination-library" [ENCRYPT filname password [date]] 

30-10-2004
Rettet i ExportFormUnit så stataversion 8 huskes som sidst anvendte
Buffer i Export to Stata forhøjet til 120000 bytes så store filer kan håndteres

07-11-2004
Rettet fejl i export til SAS (slutkolonne for felter=80 char i length blev nul) (markeret MIB221)
Tilføjet fejlraporttering, hvis qes-fil > 999 linier.
Fejl vedr. goto write efterfulgt af goto v10 rettet (gav forkert position i den nye record)
Rettet i count records, så filer, hvor .rec er skrevet med stort, accepteres

20-11-2004
Rettet i SelectFileUnit så file2edit opdateres hele tiden under skrivning i file1edit
Log10 tilføjet som funktion i prExpr

EpiData 3.1 (release candidate) sendt til JEL

26-11-2004
Tilføjet ny eInputBox som oversætter OK/Cancel
Rettet i WarningDlg, så OK/Cancel oversættes
Rettet showlegalpick list, så missing values i værdifelt accepteres
Rettet DoUnzip så fileext bliver korrekt (dvs. .zky => .zip)

1-12-2004
Count by records ændret fra 10 til 25

ca. 20-12-2004
VERSION 3.1 lagt ud på www.epidata.dk

29-12-2004
CheckObjUnit's oversættelsesrutiner ændret til OnTranslate event

18-01-2005
Rettet double entry så der gives fejlmeddelelse hvis felter ikke findes i filerne
Rettet i ExportToEpiData for at løse problem med makeIndex i forhold til åbne/lukkede filer

27-01-2005
Rettet fejl i Pack Datafile, som gav ukrypterede data i krypterede felter

3-6-2005
Tilføjet programparamtre /NOSPLASH og /FINDvarname=text

12-6-2005
Rettet fejl i Search-rutine, som gjorde at filtre ikke blev respekteret under søgning

02-07-2005
Menupunkt med EpiDataStat tilføjet
Fejl vedr. autosearch rettet (hvis nye indtastning var lig med værdien i sidste record hang Epidata)
Rettet i SaveRecord så der ikke kan gemmes tomme records
Type statusbar fejl rettet - opstod når type statusbar og autosearch var i samme felt

26-09-2005
Rettet i double entry, så records, der ikke redigeres, kan markeres som slettet og blive gemt

14-11-2005
Tilføjet håndtering af ^-markering for verified i forbindelse med double entry

13-12-2005
Rettet i DoRevisedatafile, så boolske felter kan konverteres til integer og float
Rettet DoubleEntry: når jump, så checkes værdier mellem FraJumpFelt og TilJumpFelt og db-fejl vises med det samme
Rettet DoubleEntry: Når original værdi blev valg, blev næste felt sprunget over - rettet

17-12-2005
Double entry: dbc-fil ændret så original filnavn gemmes uden stinavn
Prepare datafile for double entry: db-rec-fil kan ikke gemmes i anden sti end original rec-fil

18-12-2005
Double entry: hvis orginalfil som specificeret i dbc-fil ikke kan findes, afbrydes indtastning 

06-01-2006
Tilføjet DEFAULTVALUE x til fieldblok, DEFAULTVALUE ALL X og field-field,field X til before-blokke

08-01-2006
Rettet DEFAULTVALUE: tilføjet ALLSTRINGS|ALLSTRING|ALLNUMERIC og undtaget datofelter, boolean, etc.
MISSINGVALUE taget med i documentation.FileStructure
DEFAULTVALUE regnes som lovlig når range/legal checkes og medtages i F9-boks

10-01-2006
Rettet dum fejl i CheckObjUnit (getcommand cmdRelate), som gav fejl, hvis der referedes til samme relatefil to gange i en chk-fil

12-01-2006
Rettet endnu en dum fejl: TDataForm.CheckDoubleEntry gemte ikke "original value" i felt^.FFieldText, men kun i inputfeltet

21/1-2007
Tilføjet programparameter /KEY=

27/1-2008
Tilføjet i DataFormUnit.HandleJumps: check om CanFocus før SetFocus anvendes
Ændret i håndtering af integers: integers med længde>9 (tidl. 4) bliver til floats
Rettet i backup - relative stier
Rettet export til SPSS, så der tages højde for datofelter med missing value (skriver nødvendigt antal blanke)
Rettet export til EpiData, så alle relevante checks tages med fra old til new

SENDT TIL JEL SOM NY VERSION TIL WWW.EPIDATA.DK

MANGLER I HJÆLPEFIL:
backup zip/encrypt mangler i hjælpefilen
/KEY program parameter mangler i hjælpefilen

        syntax: BACKUP "destination-library" [ZIP filename [date]]
         or      BACKUP "destination-library" [ENCRYPT filname password [date]]  

Noter slut*****}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, Registry, ToolWin, Buttons, ExtCtrls, StdCtrls,FmxUtils,
  ShellAPI,prExpr,EPITypes, AxCtrls, OleCtrls, VCF1, ImgList;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    Filer1: TMenuItem;
    Afslut1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Window1: TMenuItem;
    ArrangeAll1: TMenuItem;
    Cascade1: TMenuItem;
    Tile1: TMenuItem;
    OpenDialog1: TOpenDialog;
    N2: TMenuItem;
    Help1: TMenuItem;
    Tilevertically1: TMenuItem;
    EditorToolBar: TPanel;
    OpenBtn: TSpeedButton;
    SaveBtn: TSpeedButton;
    CutBtn: TSpeedButton;
    CopyBtn: TSpeedButton;
    PasteBtn: TSpeedButton;
    NewBtn: TSpeedButton;
    UndoBtn: TSpeedButton;
    TestBtn: TSpeedButton;
    PrintBtn: TSpeedButton;
    PickListBtn: TSpeedButton;
    StatusPanel: TPanel;
    StatPanel1: TPanel;
    WorkProcessToolbar: TPanel;
    DefineDataBtn: TSpeedButton;
    Arrow1: TImage;
    AddValidationBtn: TSpeedButton;
    DefineDataPopUp: TPopupMenu;
    NewQesPop: TMenuItem;
    OpenQesPop: TMenuItem;
    Arrow3: TImage;
    EnterDataBtn: TSpeedButton;
    Arrow4: TImage;
    DocumentBtn: TSpeedButton;
    Arrow5: TImage;
    ExportDataBtn: TSpeedButton;
    AddValidationPopUp: TPopupMenu;
    NewcheckfilePop: TMenuItem;
    DocumentPopUp: TPopupMenu;
    Datafileinfo1: TMenuItem;
    ExportDataPopUp: TPopupMenu;
    ExportToTxt1: TMenuItem;
    Toolbars1: TMenuItem;
    WorkProcessToolbar1: TMenuItem;
    EditorToolbar1: TMenuItem;
    HideShowToolbarsPopup: TPopupMenu;
    Workprocesstoolbar2: TMenuItem;
    Editortoolbar2: TMenuItem;
    Both1: TMenuItem;
    Both2: TMenuItem;
    Contents1: TMenuItem;
    AboutEpiData1: TMenuItem;
    Checkdata1: TMenuItem;
    Datainout1: TMenuItem;
    Document1: TMenuItem;
    ClearChecks1: TMenuItem;
    Newdatafilefromqesfile1: TMenuItem;
    N3: TMenuItem;
    Exportdata1: TMenuItem;
    Backup1: TMenuItem;
    Totextfile1: TMenuItem;
    To1: TMenuItem;
    Makeqesfilefromdatafile1: TMenuItem;
    Datafileinfo2: TMenuItem;
    RecentDivider: TMenuItem;
    Recent1: TMenuItem;
    Recent2: TMenuItem;
    Recent3: TMenuItem;
    Recent4: TMenuItem;
    MakeDatafileBtn: TSpeedButton;
    Arrow2: TImage;
    ExportDBase1: TMenuItem;
    Options1: TMenuItem;
    N1: TMenuItem;
    ExporttoExcelfile1: TMenuItem;
    ExporttoExcelfile2: TMenuItem;
    ExporttoStata1: TMenuItem;
    ExporttoStata2: TMenuItem;
    Backup2: TMenuItem;
    N4: TMenuItem;
    EpiDatahomepage1: TMenuItem;
    N6: TMenuItem;
    Fieldtypes1: TMenuItem;
    CodeHelpBtn: TSpeedButton;
    TabCtrl: TTabControl;
    StatPanel2: TPanel;
    ProgressBar: TProgressBar;
    StatPanel3: TPanel;
    StatPanel4: TPanel;
    PeekOpenDataForm1: TMenuItem;
    pNew2: TMenuItem;
    Studydescription1: TMenuItem;
    Studydescription2: TMenuItem;
    Shownoopendatafile1: TMenuItem;
    Abort1: TMenuItem;
    Hidetoolbarsduringdataentry1: TMenuItem;
    Hidetoolbarsduringdataentry2: TMenuItem;
    Datafilelabel1: TMenuItem;
    N9: TMenuItem;
    Listdata1: TMenuItem;
    Listdata2: TMenuItem;
    Codebook1: TMenuItem;
    SaveDialog1: TSaveDialog;
    RevisedatafilefromrevisedQESfile1: TMenuItem;
    Aboutregistration1: TMenuItem;
    Registeronline1: TMenuItem;
    N10: TMenuItem;
    Tools1: TMenuItem;
    Validate1: TMenuItem;
    Copydatafilestructure1: TMenuItem;
    N7: TMenuItem;
    Codebook2: TMenuItem;
    Rebuildindex1: TMenuItem;
    N11: TMenuItem;
    Recent5: TMenuItem;
    Recent6: TMenuItem;
    Recent7: TMenuItem;
    Recent8: TMenuItem;
    MakeDatafilePopUp: TPopupMenu;
    Makedatafil1: TMenuItem;
    Previewdatafile1: TMenuItem;
    Statpanel5: TPanel;
    StatPanel6: TPanel;
    Packdatafile1: TMenuItem;
    Import1: TMenuItem;
    Importfromtextfile1: TMenuItem;
    Analysistest1: TMenuItem;
    ImportfromdBasefile1: TMenuItem;
    Changefieldnames1: TMenuItem;
    AppendMergedatafiles1: TMenuItem;
    Assertdatafile1: TMenuItem;
    ImportfromStatafile1: TMenuItem;
    ExporttoSPSS1: TMenuItem;
    ExporttoSPSS2: TMenuItem;
    Recodedatafile1: TMenuItem;
    Countvalues1: TMenuItem;
    Countvalues2: TMenuItem;
    N8: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    Validateduplicatedatafiles1: TMenuItem;
    Assertdatafile2: TMenuItem;
    ExportEpiData1: TMenuItem;
    ExporttonewRECfile1: TMenuItem;
    Compressdatafile1: TMenuItem;
    ExporttoSAS1: TMenuItem;
    ExporttoSAS2: TMenuItem;
    fys1: TMenuItem;
    fys2: TMenuItem;
    LeftDockPanel: TPanel;
    LeftSplitter: TSplitter;
    RightDockPanel: TPanel;
    RightSplitter: TSplitter;
    ShowRelateTreeMenuItem: TMenuItem;
    Colortable1: TMenuItem;
    TestWarningPanel: TPanel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    LocalHomepageLabel: TLabel;
    Viewer1: TMenuItem;
    Viewdata1: TMenuItem;
    N5: TMenuItem;
    Zipfiles1: TMenuItem;
    Unzipfiles1: TMenuItem;
    IntroduktiontoEpiData1: TMenuItem;
    Doubleentry1: TMenuItem;
    EpiDataAnalysis1: TMenuItem;
    procedure Afslut1Click(Sender: TObject);
    procedure Tile1Click(Sender: TObject);
    procedure Cascade1Click(Sender: TObject);
    procedure ArrangeAll1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure DoOpenQesfile(f:String);
    Procedure ArrangeToolBarButtons;
    Procedure InitTranslations;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure Tilevertically1Click(Sender: TObject);
    procedure UpdateButtonStatus(Sender: TObject);
    procedure UndoBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure CutBtnClick(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure PasteBtnClick(Sender: TObject);
    procedure TestBtnClick(Sender: TObject);
    procedure PickListBtnClick(Sender: TObject);
    Procedure ProcessBtnClick(Sender: TObject);
    procedure Toolbars1Click(Sender: TObject);
    procedure WorkProcessToolbar1Click(Sender: TObject);
    procedure EditorToolbar1Click(Sender: TObject);
    procedure Both1Click(Sender: TObject);
    procedure Contents1Click(Sender: TObject);
    procedure InfoTester1Click(Sender: TObject);
    procedure AboutEpiData1Click(Sender: TObject);
    procedure Filer1Click(Sender: TObject);
    procedure Recent1Click(Sender: TObject);
    procedure MakeDatafileBtnClick(Sender: TObject);
    Function  OpenRelateFile(Filename:String; MotherDf,RelDf: Pointer; VAR RelAct: TOpenRelAction):Boolean;
    procedure DoOpenDatafile(filename:String);
    procedure ExportToTxt1Click(Sender: TObject);
    procedure ExportToDBase1Click(Sender: TObject);
    procedure Makeqesfilefromdatafile1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure ExporttoExcelfile1Click(Sender: TObject);
    procedure ExporttoStata1Click(Sender: TObject);
    procedure pNew2Click(Sender: TObject);
    procedure ClearChecks1Click(Sender: TObject);
    procedure Variableinfo1Click(Sender: TObject);
    procedure Backup1Click(Sender: TObject);
    procedure EpiDatahomepage1Click(Sender: TObject);
    //procedure TourofEpiData1Click(Sender: TObject);
    procedure Fieldtypes1Click(Sender: TObject);
    procedure CodeHelpBtnClick(Sender: TObject);
    procedure TabCtrlChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PeekOpenDataForm1Click(Sender: TObject);
    procedure Studydescription1Click(Sender: TObject);
    procedure Shownoopendatafile1Click(Sender: TObject);
    procedure Abort1Click(Sender: TObject);
    procedure Hidetoolbarsduringdataentry1Click(Sender: TObject);
    procedure Datafilelabel2Click(Sender: TObject);
    Procedure CloseAll;
    procedure Listdata1Click(Sender: TObject);
    procedure Codebook1Click(Sender: TObject);
    procedure RevisedatafilefromrevisedQESfile1Click(Sender: TObject);
    procedure Aboutregistration1Click(Sender: TObject);
    procedure Registeronline1Click(Sender: TObject);
    procedure Validate1Click(Sender: TObject);
    procedure Copydatafilestructure1Click(Sender: TObject);
    procedure Rebuildindex1Click(Sender: TObject);
    procedure Packdatafile1Click(Sender: TObject);
    procedure Importfromtextfile1Click(Sender: TObject);
    procedure Analysistest1Click(Sender: TObject);
    procedure ImportfromdBasefile1Click(Sender: TObject);
    procedure Changefieldnames1Click(Sender: TObject);
    procedure AppendMergedatafiles1Click(Sender: TObject);
    Function  HandleVars( const Identifier: String; ParameterList: TParameterList): IValue;
    procedure Assertdatafile1Click(Sender: TObject);
    procedure ImportfromStatafile1Click(Sender: TObject);
    procedure ExporttoSPSS1Click(Sender: TObject);
    Function  ExecRecodeCommandList(VAR df:PDatafileInfo; VAR CmdList:TList):Boolean;    
    procedure Recodedatafile1Click(Sender: TObject);
    procedure Countvalues1Click(Sender: TObject);
    procedure ExportEpiData1Click(Sender: TObject);
    procedure Compressdatafile1Click(Sender: TObject);
    procedure ExporttoSAS1Click(Sender: TObject);
    procedure fys1Click(Sender: TObject);
    procedure ShowRelateTreeMenuItemClick(Sender: TObject);
    procedure LeftDockPanelDockDrop(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer);
    procedure LeftDockPanelUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure TabCtrlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure Colortable1Click(Sender: TObject);
    procedure Window1Click(Sender: TObject);
    procedure btnFindPanelCloseClick(Sender: TObject);
    procedure btnFindForwardClick(Sender: TObject);
    procedure btnFindEditClick(Sender: TObject);
    procedure btnFindNewClick(Sender: TObject);
    procedure LocalHomepageLabelClick(Sender: TObject);
    procedure Viewer1Click(Sender: TObject);
    procedure Zipfiles1Click(Sender: TObject);
    procedure IntroduktiontoEpiData1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Doubleentry1Click(Sender: TObject);
    procedure EpiDataAnalysis1Click(Sender: TObject);
  protected
    procedure WMDropFiles(var Msg: TWMDropFiles);  message WM_DROPFILES;
  private
    { Private declarations }
    Function DoRevisedatafile(NameOfNewQesFile, NameOfOldRecFile:string):Boolean;
  public
    { Public declarations }
    procedure TranslateEvent(stringnumber:Integer; origstring:string; VAR transstring:string);
  end;

  procedure AddToRecentFiles(s:String);

var
  MainForm: TMainForm;
  FindDialog1:TFindDialog;
  FindNextPointer:TNotifyEvent;
  ReplaceDialog1:TReplaceDialog;
  ReplacePointer:TNotifyEvent;
  IntroDone:Boolean;
  Reg:TRegistry;
  TimeLog:TStrings;
  OldTime:TDateTime;
  StartTime:TDateTime;
  Findfieldname: string;
  Findfieldtext: string;

implementation

USES
  EdUnit, PickListUnit,
  SelectFilesUnit, FileUnit, ExportFormUnit,
  OptionsUnit, WelcomeUnit, AboutUnit, BackUpUnit, DataFormUnit,
  PeekCheckUnit, InputFormUnit, CheckErrorUnit,
  ProgressUnit,ValDupUnit, CopyStrucUnit, ImportUnit, GridUnit,
  MergeUnit, CountValuesUnit, epiUDFTypes, RelateTreeUnit, ColorTabelUnit, CheckObjUnit, searchunit,
  ZipFormUnit, SearchformUnit;

{$R *.DFM}

TYPE
  TesiRecord=Record
    QuestTop:   Integer;
    QuestLeft:  Integer;
    FieldTop:   Integer;
    FieldLeft:  Integer;
    FieldWidth: Integer;
    end;



procedure AddToRecentFiles(s:String);
VAR
  aN,an2:Integer;
BEGIN
  aN2:=1;
  FOR aN:=1 TO 8 DO
    IF ANSIUpperCase(RecentFiles[aN])=AnsiUpperCase(s) THEN aN2:=aN;
  IF ANSIUpperCase(RecentFiles[aN2])=ANSIUpperCase(s)  //is s allready in list?
  THEN FOR aN:=aN2 DownTo 2 DO RecentFiles[aN]:=RecentFiles[aN-1]
  ELSE FOR aN:=8 DOWNTO 2 DO RecentFiles[aN]:=RecentFiles[aN-1];
  RecentFiles[1]:=s;
END;



procedure TMainForm.Afslut1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Tile1Click(Sender: TObject);
begin
  TileMode:=tbHorizontal;
  Tile;
end;

procedure TMainForm.Tilevertically1Click(Sender: TObject);
begin
  TileMode:=tbVertical;
  Tile;
end;

procedure TMainForm.Cascade1Click(Sender: TObject);
begin
  Cascade;
end;

procedure TMainForm.ArrangeAll1Click(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TMainForm.New1Click(Sender: TObject);
begin
  LockWindowUpdate(MainForm.Handle);
  TEdForm.Create(self);
  LockWindowUpdate(0);
end;

procedure TMainForm.Open1Click(Sender: TObject);
VAR
  tmpS: String;
begin
  IF AnsiUpperCase(ExtractFileExt(RecentFiles[1]))<>'.REC' THEN
    BEGIN
      OpenDialog1.InitialDir:=ExtractFileDir(RecentFiles[1]);
      OpenDialog1.FileName:=ExtractFileName(RecentFiles[1]);
      tmpS:=AnsiUpperCase(ExtractFileExt(RecentFiles[1]));
      IF tmpS='.QES' THEN OpenDialog1.FilterIndex:=1
      ELSE IF tmpS='.CHK' THEN OpenDialog1.FilterIndex:=3
      ELSE IF tmpS='.NOT' THEN OpenDialog1.FilterIndex:=4
      ELSE IF tmpS='.LOG' THEN OpenDialog1.FilterIndex:=5
      ELSE OpenDialog1.FilterIndex:=6;
    END
  ELSE
    BEGIN
      OpenDialog1.InitialDir:=ExtractFileDir(RecentFiles[1]);
      OpenDialog1.FileName:='';
      IF Sender=OpenQesPop THEN OpenDialog1.FilterIndex:=1
      ELSE OpenDialog1.FilterIndex:=2;   //set filter to *.qes
    END;
  IF OpenDialog1.Execute THEN
    BEGIN
      IF NOT CanOpenFile(OpenDialog1.Filename) THEN Exit;
      AddToRecentFiles(OpenDialog1.FileName);
      IF ANSIUpperCase(ExtractFileExt(OpenDialog1.Filename))='.REC' THEN
        BEGIN
          IF MDIChildCount>0 THEN eDlg(Lang(20100),mtInformation,[mbOK],0)   //Please close all open files before opening a datafile.
          ELSE DoOpenDatafile(OpenDialog1.Filename);
        END
      ELSE
        BEGIN
          LockWindowUpdate(MainForm.Handle);
          WITH TEdForm.Create(Self) DO Open(OpenDialog1.FileName);
          LockWindowUpdate(0);
        END;
    END;  //if
end;

procedure TMainForm.DoOpenQesfile(f:String);
BEGIN
  IF NOT CanOpenFile(f) THEN Exit;
  AddToRecentFiles(f);
  LockWindowUpdate(MainForm.Handle);
  WITH TEdForm.Create(Self) DO Open(f);
  LockWindowUpdate(0);
END;

Procedure TMainForm.ArrangeToolBarButtons;
BEGIN
  {Defines width of buttons on workprocesstoolbar - called after translate}
  DefineDataBtn.Width:=Canvas.TextWidth(DefineDataBtn.Caption)+17;
  MakeDatafileBtn.Width:=Canvas.TextWidth(MakeDatafileBtn.Caption)+17;
  AddValidationBtn.Width:=Canvas.TextWidth(AddValidationBtn.Caption)+17;
  EnterDataBtn.Width:=Canvas.TextWidth(EnterDataBtn.Caption)+6;
  DocumentBtn.Width:=Canvas.TextWidth(DocumentBtn.Caption)+17;
  ExportDataBtn.Width:=Canvas.TextWidth(ExportDataBtn.Caption)+17;

  Arrow1.Left:=DefineDataBtn.Left+DefineDataBtn.Width+1;
  MakeDatafileBtn.Left:=Arrow1.Left+Arrow1.Width+1;
  Arrow2.Left:=MakeDatafileBtn.Left+MakeDatafileBtn.Width+1;
  AddValidationBtn.Left:=Arrow2.Left+Arrow2.Width+1;
  Arrow3.Left:=AddValidationBtn.Left+AddValidationBtn.Width+1;
  EnterDataBtn.Left:=Arrow3.Left+Arrow3.Width+1;
  Arrow4.Left:=EnterDataBtn.Left+EnterDataBtn.Width+1;
  DocumentBtn.Left:=Arrow4.Left+Arrow4.Width+1;
  Arrow5.Left:=DocumentBtn.Left+DocumentBtn.Width+1;
  ExportDataBtn.Left:=Arrow5.Left+Arrow5.Width+1;
END;


Procedure TMainForm.InitTranslations;
BEGIN
  {Initialize OpenDialog1.Filters}
  OpenDialog1.Filter:=Lang(2102)+'|*.qes|'+
                      Lang(2104)+'|*.rec|'+
                      Lang(2106)+'|*.chk|'+
                      Lang(2108)+'|*.not|'+
                      Lang(2110)+'|*.log|'+
                      Lang(2112)+'|*.*';

  {2102=EpiData Questionnaire (*.qes)
  2104=EpiData Datafile (*.rec)
  2106=EpiData Checkfile  (*.chk)
  2108=Dataentry notes  (*.not)
  2110=Datafile documentation (*.log)
  2112=All (*.*)}

  {Initialize fieldTypeNames}
  FieldTypeNames[0]:=Lang(50100);  //Numeric
  FieldTypeNames[1]:=Lang(50101);  //Text
  FieldTypeNames[2]:=Lang(50102);  //Date (mdy)
  FieldTypeNames[3]:=Lang(50103);  //Uppercase text
  FieldTypeNames[4]:='Checkbox';
  FieldTypeNames[5]:=Lang(50105);  //Boolean
  FieldTypeNames[6]:=Lang(50100);  //Numeric
  FieldTypeNames[7]:='Phonenumber';
  FieldTypeNames[8]:='Time';
  FieldTypeNames[9]:='Local phonenumber';
  FieldTypeNames[10]:=Lang(50110);  //Today (mdy)
  FieldTypeNames[11]:=Lang(50111);  //Date (dmy)
  FieldTypeNames[12]:=Lang(50112);  //ID-number
  FieldTypeNames[13]:='Unknown type';
  FieldTypeNames[14]:='Unknown type';
  FieldTypeNames[15]:=Lang(50115);  //Question
  FieldTypeNames[16]:=Lang(50116);  //Today (dmy)
  FieldTypeNames[17]:=Lang(50117);  //Soundex
  FieldTypeNames[18]:=Lang(50118);  //Encryptfield
  FieldTypeNames[19]:=Lang(50119);  //Date (ymd)'
  FieldtypeNames[20]:=Lang(50120);  //Today (ymd)
END;

procedure TMainForm.FormCreate(Sender: TObject);
VAR
  fcN:Integer;
  tmpRect: TRect;
  MainMax: Boolean;
  IniLin: TStringList;
begin
// Next line gets you to the current directory defined by "default dir":
//caption :=getcurrentdir;
  IsZipping:=False;
  cipher:=NIL;
  LatestViewedDataForm:=NIL;
  PaintProperWorkbar:=False;
  IF TESTVERSION THEN   Caption:='EpiData '+EpiDataVersion + '  (build '+BuildNo+')'
  ELSE Caption:='EpiData '+EpiDataVersion; 
  Application.HelpFile:=ExtractFileDir(ParamStr(0))+'\EpiData.hlp';
  RelateFiles:=NIL;
  IniFilename:=ChangeFileExt(ParamStr(0),'.ini');
  IF ParamCount>0 THEN
    BEGIN
      FOR fcN:=1 TO ParamCount DO
        BEGIN
          IF AnsiUppercase(Copy(ParamStr(fcN),1,5))='/INI=' THEN
            BEGIN
              IniFilename:=Copy(ParamStr(fcN),6,Length(ParamStr(fcN)));
              IF AnsiUpperCase(ExtractFileExt(IniFilename))<>'.INI'
              THEN IniFilename:=ChangeFileExt(IniFilename,'.ini');
            END;  //if ini found
        END;  //for
    END;  //if paramCount>0
  LanStr:=TStringList.Create;
  DecimalSeparator:=',';
  WindowNum:=0;
  LastSelectFilesType:=sfNone;
  LegalPickFormWidth:=170;
  LegalPickFormHeight:=230;
  FieldNamesListWidth:=170;
  PickListPos.x:=-1;
  PickListPos.y:=-1;
  SearchBoxPos.x:=-1;
  SearchBoxPos.y:=-1;
  MissingAction:=maRejectMissing;
  ShowMouseWarning:=False;
  HasShownMousewarning:=False;
  DoUseSounds:=False;

  IF StatusPanel.ClientWidth>398 THEN StatPanel6.Width:=StatusPanel.ClientWidth-StatPanel6.Left-4;
  PickListCreated:=False;
  DontMakeFieldNames:=False;
  Screen.OnActiveFormChange:=UpdateButtonStatus;
  FindDialog1:=TFindDialog.Create(self);
  FindDialog1.Options:=FindDialog1.Options+[frHideUpDown];
  ReplaceDialog1:=TReplaceDialog.Create(self);
  IntroDone:=False;
  GlobalAutoSave:=False;
  GlobalConfirm:=False;
  LastActiveOptionsPage:=0;
  epiEdFont:=TFont.Create;
  WITH epiEdFont DO
    BEGIN
      Charset:=DEFAULT_CHARSET;
      Color:=clWindowText;
      Name:='Courier New';
      Size:=10;
      Style:=[];
    END;   //With
  EdColor:=clWindow;
  epiDataFormFont:=TFont.Create;
  WITH epiDataFormFont DO
    BEGIN
      Charset:=DEFAULT_CHARSET;
      Color:=clWindowText;
      Name:='Courier New';
      Size:=10;
      Style:=[];
    END;
  DataFormColor:=clBtnFace;
  FieldNameCase:=fcUpper;
  ShowCheckFileCheckMark:=True;
  epiDocuFont:=TFont.Create;
  WITH epiDocuFont DO
    BEGIN
      Charset:=DEFAULT_CHARSET;
      Color:=clWindowText;
      Name:='Courier New';
      Size:=10;
      Style:=[];
    END;  //With
  DocuColor:=clWindow;

  IF IniFilename<>'' THEN
    BEGIN
      TRY
        IniLin:=TStringList.Create;
        IF FileExists(IniFilename) THEN IniLin.LoadFromFile(IniFilename);
        WITH IniLin DO
          BEGIN
            IF Values['Language']<>'' THEN CurLanguage:=Values['Language'] ELSE CurLanguage:='English';
            IF AnsiUpperCase(CurLanguage)='ENGLISH' THEN UsesEnglish:=True ELSE UsesEnglish:=False;
            IF Values['LangCounter']<>'' THEN LangVersionCounter:=StrToInt(Values['LangCounter']) ELSE LangVersionCounter:=0;
            IF Values['NoLangError']<>'' THEN NoLangError:=(Values['NoLangError']='1') ELSE NoLangError:=False;

            InitLanguage;
            TranslateForm(self);
            ArrangeToolBarButtons;
            IF Values['MainWinMax']<>'' THEN MainMax:=(Values['MainWinMax']='1') ELSE MainMax:=True;
            IF MainMax THEN WindowState:=wsMaximized
            ELSE BEGIN
              TRY
                tmpRect.Top:=StrToInt(Values['MainWinTop']);
                tmpRect.Left:=StrToInt(Values['MainWinLeft']);
                tmpRect.Right:=StrToInt(Values['MainWinRight']);
                tmpRect.bottom:=StrToInt(Values['MainWinBot']);
                IF ((tmpRect.Right-tmpRect.Left)>=Screen.Width)
                AND ((tmpRect.Bottom-tmpRect.Top)>=Screen.Height)
                THEN WindowState:=wsMaximized ELSE BoundsRect:=tmpRect;
              EXCEPT
                WindowState:=wsMaximized;
              END;
            END;
            IF Values['PrcsToolBar']<>'' THEN WorkProcessToolBar.Visible:=(Values['PrcsToolBar']='1')
            ELSE WorkProcessToolBar.Visible:=True;
            WorkProcessToolBarOn:=WorkProcessToolBar.Visible;
            IF Values['EdToolBar']<>'' THEN EditorToolBar.Visible:=(Values['EdToolBar']='1')
            ELSE EditorToolBar.Visible:=True;
            EditorToolBarOn:=EditorToolBar.Visible;
            IF Values['HideToolBars']<>'' THEN HideToolBarsDuringDataEntry:=(Values['HideToolBars']='1')
            ELSE HideToolBarsDuringDataEntry:=True;
            OldWorkProcessToolBar:=WorkProcessToolBar.Visible;
            OldEditorToolbar:=EditorToolBar.Visible;
            FOR fcN:=1 TO 8 DO
              BEGIN
                IF Values['Recent'+IntToStr(fcN)]<>''
                THEN RecentFiles[fcN]:=Values['Recent'+IntToStr(fcN)]
                ELSE RecentFiles[fcN]:='';
              END;
            IF Values['EdFontName']<>'' THEN epiEdFont.Name:=Values['EdFontName'];
            IF Values['EdFontColor']<>'' THEN epiEdFont.Color:=StrToInt(Values['EdFontColor']);
            IF Values['EdFontSize']<>'' THEN epiEdFont.Size:=StrToInt(Values['EdFontSize']);
            IF Values['EdFontStyle']<>'' THEN epiEdFont.Style:=ByteToFontStyle(StrToInt(Values['EdFontStyle']));
            IF Values['EdColor']<>'' THEN EdColor:=StrToInt(Values['EdColor']);
            IF Values['DataFormFontName']<>'' THEN epiDataFormFont.Name:=Values['DataFormFontName'];
            IF Values['DataFormFontColor']<>'' THEN epiDataFormFont.Color:=StrToInt(Values['DataFormFontColor']);
            IF Values['DataFormFontSize']<>'' THEN epiDataFormFont.Size:=StrToInt(Values['DataFormFontSize']);
            IF Values['DataFormFontStyle']<>'' THEN epiDataFormFont.Style:=ByteToFontStyle(StrToInt(Values['DataFormFontStyle']));
            IF Values['DataFormColor']<>'' THEN DataFormColor:=StrToInt(Values['DataFormColor']);
            IF Values['DocuFontName']<>'' THEN epiDocuFont.Name:=Values['DocuFontName'];
            IF Values['DocuFontColor']<>'' THEN epiDocuFont.Color:=StrToInt(Values['DocuFontColor']);
            IF Values['DocuFontSize']<>'' THEN epiDocuFont.Size:=StrToInt(Values['DocuFontSize']);
            IF Values['DocuFontStyle']<>'' THEN epiDocuFont.Style:=ByteToFontStyle(StrToInt(Values['DocuFontStyle']));
            IF Values['DocuColor']<>'' THEN DocuColor:=StrToInt(Values['DocuColor']);
            WITH CheckFormRect DO
              BEGIN
                Left:=Screen.Width-10-215;
                Top:=(Screen.Height DIV 2) - (262 DIV 2);
                Right:=Left+215;
                Bottom:=Top+262;
              END;  //with
            IF Values['CheckWinTop']<>'' THEN CheckFormRect.Top:=StrToInt(Values['CheckWinTop']);
            IF Values['CheckWinLeft']<>'' THEN CheckFormrect.Left:=StrToInt(Values['CheckWinLeft']);
            IF Values['CheckWinBot']<>'' THEN CheckFormRect.Bottom:=StrToInt(Values['CheckWinBot']);
            IF Values['CheckWinRight']<>'' THEN CheckFormRect.Right:=StrToInt(Values['CheckWinRight']);
            IF Values['WelcomeWin']<>'' THEN ShowWelcomeWindow:=(Values['WelcomeWin']='1') ELSE ShowWelcomeWindow:=True;
            IF Values['FieldNaming']<>'' THEN EpiInfoFieldNaming:=(Values['FieldNaming']='1') ELSE EpiInfoFieldNaming:=True;
            IF Values['UpdFName']<>'' THEN UpdateFieldNameInQuestion:=(Values['UpdFName']='1') ELSE UpdateFieldNameInQuestion:=True;
            IF Values['Backupdir']<>'' THEN BackUpDir:=Values['Backupdir'] ELSE BackUpDir:='C:\';
            IF Values['NameCase']<>'' THEN
              BEGIN
                fcN:=StrToInt(Values['NameCase']);
                CASE fcN OF
                  0: FieldNameCase:=fcUpper;
                  1: FieldNameCase:=fcLower;
                  2: FieldNameCase:=fcDontChange;
                ELSE FieldNameCase:=fcUpper;
                END;  //case
              END
            ELSE FieldNameCase:=fcUpper;
            IF Values['TabValue']<>'' THEN EvenTabValue:=StrToInt(Values['TabValue']) ELSE EvenTabValue:=40;
            IF Values['EdNumTab']<>'' THEN NumberOfTabChars:=StrToInt(Values['EdNumTab']) ELSE NumberOfTabChars:=4;
            IF Values['FirstID']<>'' THEN FirstIDNumber:=StrToInt(Values['FirstID']) ELSE FirstIDNumber:=1;
            IF Values['ShowAllChecks']<>'' THEN ShowAllChecksInCodebook:=(Values['ShowAllChecks']='1') ELSE ShowAllChecksInCodebook:=False;
            IF Values['StataVer']<>'' THEN StataVersion:=StrToInt(Values['StataVer']) ELSE StataVersion:=6;
            IF Values['StataCase']<>'' THEN
              BEGIN
                fcN:=StrToInt(Values['StataCase']);
                CASE fcN OF
                  0: StataLetterCase:=fcUpper;
                  1: StataLetterCase:=fcLower;
                  2: StataLetterCase:=fcDontChange;
                ELSE StataLetterCase:=fcLower;
                END;   //case
              END
            ELSE StataLetterCase:=FieldNameCase;
            IF Values['AutoIndent']<>'' THEN AutoIndent:=(Values['AutoIndent']='1') ELSE AutoIndent:=False;
            IF Values['ldWidth']<>'' THEN ListDataWidth:=StrToInt(Values['ldWidth']) ELSE ListDataWidth:=80;
            IF Values['ldCols']<>'' tHEN ListDataCols:=StrToInt(Values['ldCols']) ELSE ListDataCols:=3;
            IF Values['ldLabels']<>'' THEN ListDataLabels:=(Values['ldLabels']='1') ELSE ListDataLabels:=True;
            IF Values['ldSkip']<>'' THEN ListDataSkipDel:=(Values['ldSkip']='1') ELSE ListDataSkipDel:=True;
            IF Values['FieldColor']<>'' THEN FieldColor:=StrToInt(Values['FieldColor']) ELSE FieldColor:=clWindow;
            IF Values['FieldHColor']<>'' THEN FieldHighlightColor:=StrToInt(Values['FieldHColor']) ELSE FieldHighlightColor:=clYellow;
            IF Values['FieldStyle']<>'' THEN FieldStyle:=StrToInt(Values['FieldStyle']) ELSE FieldStyle:=1;
            IF Values['FieldHLA']<>'' THEN FieldHighlightActive:=(Values['FieldHLA']='1') ELSE FieldHighlightActive:=False;
            IF Values['ShowExprErr']<>'' THEN ShowExprErrors:=(Values['ShowExprErr']='1') ELSE ShowExprErrors:=False;
            IF Values['LineHeight']<>'' THEN LineHeight:=StrToInt(Values['LineHeight']) ELSE LineHeight:=1;
            IF Values['SavePosX']<>'' THEN SaveDlgPos.x:=StrToInt(Values['SavePosX']) ELSE SaveDlgPos.x:=-1;
            IF Values['SavePosY']<>'' THEN SaveDlgPos.y:=StrToInt(Values['SavePosY']) ELSE SaveDlgPos.y:=-1;
            IF Values['WarningSounds']<>'' THEN WarningSounds:=(Values['WarningSounds']='1') ELSE WarningSounds:=True;
            IF Values['RTDock']<>'' THEN RelateTreeDock:=StrToInt(Values['RTDock']) ELSE RelateTreeDock:=1;
            FillChar(RelateTreeRect,SizeOf(RelateTreeRect),0);
            IF Values['RTTop']<>'' THEN RelateTreeRect.Top:=StrToInt(Values['RTTop']);
            IF Values['RTBot']<>'' THEN RelateTreeRect.Bottom:=StrToInt(Values['RTBot']);
            IF Values['RTLeft']<>'' THEN RelateTreeRect.Left:=StrToInt(Values['RTLeft']);
            IF Values['RTRight']<>'' THEN RelateTreeRect.Right:=StrToInt(Values['RTRight']);
            IF Values['PickFormWidth']<>'' THEN LegalPickFormWidth:=StrToInt(Values['PickFormWidth']);
            IF Values['PickFormHeight']<>'' THEN LegalPickFormHeight:=StrToInt(Values['PickFormHeight']);
            IF Values['PickPosX']<>'' THEN PickListPos.x:=StrToInt(Values['PickPosX']);
            IF Values['PickPosY']<>'' THEN PickListPos.y:=StrToInt(Values['PickPosY']);
            IF Values['SearchPosX']<>'' THEN SearchBoxPos.x:=StrToInt(Values['SearchPosX']);
            IF Values['SearchPosY']<>'' THEN SearchBoxPos.y:=StrToInt(Values['SearchPosY']);
            IF Values['ViewerSort']<>'' THEN ViewerSortByRec:=(Values['ViewerSort']='1') ELSE ViewerSortByRec:=False;
            HelpBoxPos.x:=-1;   HelpBoxPos.y:=-1;
            DataEntryNotesPos.Top:=-1;
          END;  //with

      FINALLY
        IniLin.Free;
      END;  //try..finally
    END;  //if IniFilename<>''

  InitTranslations;


  //Initialize dockpanels
  LeftDockPanel.Width:=0;
  RightDockPanel.Width:=0;
  OldDockPanelWidth:=150;
  RelateTreeCount:=0;
  RelateNodes:=NIL;

end;  //procedure FormCreate

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  fcN:Integer;
  IniLin: TStringList;
begin
  IF Assigned(Cipher) THEN Cipher.Free;
  FindDialog1.Free;
  ReplaceDialog1.Free;
  Screen.OnActiveFormChange:= nil;
  IF (HideToolBarsDuringDataEntry) AND (NOT TestingDataForm) THEN
    BEGIN
      MainForm.EditorToolBar.Visible:=OldEditorToolbar;
      MainForm.WorkProcessToolBar.Visible:=OldWorkProcessToolBar;
    END;

  TRY
    TRY
      IniLin:=TStringList.Create;
      WITH IniLin DO
        BEGIN
          Append('Language='+CurLanguage);
          Append('MainWinTop='+IntToStr(Boundsrect.Top));
          Append('MainWinLeft='+Inttostr(Boundsrect.Left));
          Append('MainWinBot='+IntTostr(BoundsRect.Bottom));
          Append('MainWinRight='+IntToStr(BoundsRect.Right));
          Append('MainWinMax='+IntToStr(ORD(WindowState=wsMaximized)));
          Append('PrcsToolBar='+IntToStr(ORD(WorkProcessToolBarOn)));
          Append('EdToolBar='+IntToStr(ORD(EditorToolBarOn)));
          Append('HideToolBars='+IntToStr(ORD(HideToolBarsDuringDataEntry)));

          FOR fcN:=1 TO 8 DO
            BEGIN
              IF RecentFiles[fcN]<>''
              THEN Append('Recent'+IntToStr(fcN)+'='+RecentFiles[fcN]);
            END;
          Append('EdFontName='+epiEdFont.Name);
          Append('EdFontColor='+IntToStr(epiEdFont.Color));
          Append('EdFontSize='+IntToStr(epiEdFont.Size));
          Append('EdFontStyle='+IntToStr(FontStyleToByte(epiEdFont.Style)));
          Append('EdColor='+IntToStr(EdColor));
          Append('DataFormFontName='+epiDataFormFont.Name);
          Append('DataFormFontColor='+IntToStr(epiDataFormFont.Color));
          Append('DataFormFontSize='+IntToStr(epiDataFormFont.Size));
          Append('DataFormFontStyle='+IntToStr(FontStyleToByte(epiDataFormFont.Style)));
          Append('DataFormColor='+IntToStr(DataFormColor));

          Append('DocuFontName='+epiDocuFont.Name);
          Append('DocuFontColor='+IntToStr(epiDocuFont.Color));
          Append('DocuFontSize='+IntToStr(epiDocuFont.Size));
          Append('DocuFontStyle='+IntToStr(FontStyleToByte(epiDocuFont.Style)));
          Append('DocuColor='+IntToStr(DocuColor));

          Append('CheckWinTop='+IntToStr(CheckFormRect.Top));
          Append('CheckWinLeft='+Inttostr(CheckFormRect.Left));
          Append('CheckWinBot='+IntTostr(CheckFormRect.Bottom));
          Append('CheckWinRight='+IntToStr(CheckFormRect.Right));

          Append('WelcomeWin='+IntToStr(ORD(ShowWelcomeWindow)));
          Append('FieldNaming='+IntToStr(ORD(EpiInfoFieldNaming)));
          Append('UpdFName='+InttoStr(ORD(UpdateFieldNameInQuestion)));
          Append('Backupdir='+BackUpDir);
          fcN:=0;
          CASE FieldNameCase OF
            fcUpper: fcN:=0;
            fcLower: fcN:=1;
            fcDontChange: fcN:=2;
          END;  //case
          Append('NameCase='+IntToStr(fcN));
          Append('TabValue='+IntToStr(EvenTabValue));
          Append('EdNumTab='+IntToStr(NumberOfTabChars));
          Append('FirstID='+IntToStr(FirstIDNumber));
          Append('StataVer='+IntToStr(StataVersion));
          fcN:=1;
          CASE StataLetterCase OF
            fcUpper: fcN:=0;
            fcLower: fcN:=1;
            fcDontChange: fcN:=2;
          END;
          Append('StataCase='+IntToStr(fcN));
          Append('AutoIndent='+IntToStr(ORD(AutoIndent)));
          Append('ShowAllChecks='+IntToStr(ORD(ShowAllChecksInCodebook)));
          Append('ldWidth='+IntToStr(ListDataWidth));
          Append('ldCols='+IntToStr(ListDataCols));
          Append('ldLabels='+IntToStr(ORD(ListDataLabels)));
          Append('ldSkip='+IntToStr(ORD(ListDataSkipDel)));
          Append('FieldColor='+IntToStr(FieldColor));
          Append('FieldHColor='+IntTostr(FieldHighlightColor));
          Append('FieldStyle='+IntToStr(FieldStyle));
          Append('FieldHLA='+IntToStr(ORD(FieldHighlightActive)));
          Append('ShowExprErr='+IntToStr(ORD(ShowexprErrors)));
          Append('LineHeight='+IntToStr(LineHeight));
          Append('SavePosX='+IntToStr(SaveDlgPos.x));
          Append('SavePosY='+InttoStr(SaveDlgPos.y));
          Append('WarningSounds='+IntToStr(ORD(WarningSounds)));
          Append('RTDock='+IntToStr(RelateTreeDock));
          Append('RTTop='+IntToStr(RelateTreeRect.Top));
          Append('RTLeft='+IntToStr(RelateTreeRect.Left));
          Append('RTBot='+IntToStr(RelateTreeRect.Bottom));
          Append('RTRight='+IntToStr(RelateTreeRect.Right));
          Append('PickFormWidth='+IntToStr(LegalPickFormWidth));
          Append('PickFormHeight='+IntToStr(LegalPickFormHeight));
          Append('PickPosX='+IntToStr(PickListPos.x));
          Append('PickPosY='+Inttostr(PickListPos.y));
          Append('SearchPosX='+IntToStr(SearchBoxPos.x));
          Append('SearchPosY='+Inttostr(SearchBoxPos.y));
          Append('ViewerSort='+IntToStr(ORD(ViewerSortByRec)));
          Append('LangCounter='+IntToStr(LangVersionCounter));
          Append('NoLangError='+IntToStr(ORD(NoLangError)));
          IF IniFilename='' THEN IniFilename:=ChangeFileExt(ParamStr(0),'.ini');
          SaveToFile(IniFilename);
        END;  //with
    EXCEPT
      eDlg(Format(Lang(20201),[IniFilename]),mtError,[mbOK],0);   //'Error writing to INI-file %s'
    END;  //try..except
  FINALLY
    IniLin.Free;
    epiEdFont.Free;
    epiDataformFont.Free;
    epiDocuFont.Free;
  END;  //try..finally

  LanStr.Free;
  DragAcceptFiles(Handle,False);
end;  //procedure FormClose


procedure TMainForm.FormPaint(Sender: TObject);
VAR
  fpN,n2:Integer;
  tmpS,tmpS2,tmpExt,FileToOpen:String;
begin
  IF IntroDone=FALSE THEN
    BEGIN
      IntroDone:=TRUE;
      IF TestVersion THEN
        BEGIN
          TestWarningPanel.Visible:=True;
          TestWarningPanel.Top:=(self.ClientHeight DIV 2) - (TestWarningPanel.Height DIV 2);
          TestWarningPanel.Left:=(self.ClientWidth DIV 2) - (TestWarningPanel.Width DIV 2);
        END;
      FindFieldname:='';
      FindFieldtext:='';
      IF ParamCount>0 THEN
        BEGIN
          FileToOpen:='';
          FOR fpN:=1 TO ParamCount DO
            BEGIN
              tmpS:=AnsiUpperCase(ParamStr(fpN));
              IF copy(tmpS,1,5)='/FIND' then
                begin
                  tmpS2:=Copy(tmpS,6,Length(tmpS));
                  n2:=pos('=',tmpS2);
                  if n2>0 then
                    begin
                      FindFieldname:=trim(copy(tmpS2,1,n2-1));
                      FindFieldtext:=trim(copy(tmpS2,n2+1,Length(tmpS2)));
                    end;
                end;
              IF tmpS='/NOTOOLBARS' THEN
                BEGIN
                  WorkProcessToolBar.Visible:=False;
                  EditorToolBar.Visible:=False;
                END;  //if NoToolBars
              IF tmpS='/SHOWWELCOMEWINDOW' THEN ShowWelcomeWindow:=True;
              IF tmpS='/FYSMENU' THEN
                BEGIN
                  fys1.visible:=True;
                  fys2.visible:=True;
                END;
              IF (tmpS='/AUTO') OR (tmpS='/AUTOSAVE') THEN GlobalAutoSave:=True;
              IF copy(tmpS,1,5)='/KEY=' then
                begin
                  if (FileToOpen<>'') and (ansiuppercase(ExtractFileExt(FileToOpen))='.REC') then
                    begin
                      tmpS2:=copy(ParamStr(fpN),6,length(tmpS));
                      StorePw(expandfilename(FileToOpen),tmpS2);
                    end;
                end;
              IF tmpS='/CONFIRM' THEN GlobalConfirm:=True;
              IF Copy(tmpS,1,6)='/LANG=' THEN
                BEGIN
                  CurLanguage:=Copy(tmpS,7,Length(tmpS));
                  IF AnsiUpperCase(CurLanguage)='ENGLISH' THEN UsesEnglish:=True ELSE UsesEnglish:=False;
                  InitLanguage;
                  TranslateForm(self);
                  ArrangeToolBarButtons;
                END;
              IF (pos('/',tmpS)=0) THEN
                BEGIN
                  tmpExt:=ExtractFileExt(tmpS);
                  IF (tmpExt='.CHK') OR (tmpExt='.QES') OR (tmpExt='.REC')
                  OR (tmpExt='.NOT') OR (tmpExt='.LOG') THEN FileToOpen:=tmpS;
                END;
            END;  //for
        END;  //if ParamCount>0
      //Add EpiDataStat as menu
      tmpS:=ExtractFileDir(ParamStr(0))+'\EpiDataStat.Exe';
      IF FileExists(tmpS) then EpiDataAnalysis1.Visible:=true;
      IF ShowWelcomeWindow THEN
        BEGIN
          WelcomeForm:=TWelcomeForm.Create(Application);
          WelcomeForm.ShowModal;
          WelcomeForm.Free;
        END;
      IF FileToOpen<>'' THEN
        BEGIN
          IF CanOpenFile(FileToOpen) THEN
            BEGIN
              IF (tmpExt='.CHK') OR (tmpExt='.QES')
              OR (tmpExt='.NOT') OR (tmpExt='.LOG') THEN
                BEGIN
                  LockWindowUpdate(MainForm.Handle);
                  WITH TEdForm.Create(Self) DO Open(FileToOpen);
                  LockWindowUpdate(0);
                END;
              IF tmpExt='.REC' THEN DoOpenDatafile(FileToOpen);
            END;
        END;  //if FileToOpen<>''
    END;  //if NOT IntroDone
  IF PaintProperWorkbar THEN
    BEGIN
      UpdateButtonStatus(sender);
      PaintProperWorkbar:=False;
    END;
end;  //procedure FormPaint


procedure TMainForm.Help1Click(Sender: TObject);
VAR
  EPIStr:String;
begin
  EPIStr:=ExtractFileDir(ParamStr(0))+'\EPIData.hlp';
  IF FileExists(EPIStr) THEN ExecuteFile(EPIStr,'','',SW_SHOW)
  ELSE ErrorMsg(Lang(20202));   //'Help file not found.'
end;


procedure TMainForm.UpdateButtonStatus(Sender: TObject);
VAR
  tmpBool,EnableWorkBtns:Boolean;
BEGIN
  tmpBool:=False;
  IF MDIChildCount>0 THEN
    BEGIN
      EnableWorkBtns:=False;
      TestWarningPanel.Visible:=False;
      IF (ActiveMDIChild is TEdForm) THEN tmpBool:=True;
      IF (ActiveMDIChild is TGridForm) THEN tmpBool:=True;   //EnableWorkBtns:=True;
        //IF (ActiveMDIChild as TGridform).GridContent=gcViewer THEN tmpBool:=True;
    END
  ELSE
    BEGIN
      EnableWorkBtns:=True;
      IF TestVersion THEN TestWarningPanel.Visible:=True;
      IF PickListCreated THEN PickListBtnClick(Sender);
    END;
  {en-/disable workprocess-toolbar btns.}
  DefineDataBtn.Enabled:=(EnableWorkBtns or tmpBool or TestingDataform);
  MakeDatafileBtn.Enabled:=(EnableWorkBtns or tmpBool or TestingDataform);
  PreviewDatafile1.Enabled:=tmpBool;
  IF AddValidationBtn.Enabled<>EnableWorkBtns THEN
    BEGIN
//      MakeDatafileBtn.Enabled:=EnableWorkBtns;
      AddValidationBtn.Enabled:=EnableWorkBtns;
      EnterDataBtn.Enabled:=EnableWorkBtns;
      DocumentBtn.Enabled:=(EnableWorkBtns or tmpBool or TestingDataform);
      ExportDataBtn.Enabled:=EnableWorkBtns;
    END;
  {en-/disable editortoolbar-bnts}
  NewBtn.Enabled:=(EnableWorkBtns or tmpBool or TestingDataform);
  OpenBtn.Enabled:=(EnableWorkBtns or tmpBool or TestingDataform);
  DragAcceptFiles(Handle,(EnableWorkBtns or tmpBool or TestingDataform));
  IF SaveBtn.Enabled<>tmpBool THEN
    BEGIN
      SaveBtn.Enabled:=tmpBool;
      PrintBtn.Enabled:=tmpBool;
      UndoBtn.Enabled:=tmpBool;
      PasteBtn.Enabled:=tmpBool;
      TestBtn.Enabled:=tmpBool;
      PickListBtn.Enabled:=tmpBool;
      CodeHelpBtn.Enabled:=tmpBool;
    END;
END;

{Editor toolbar Click events}

procedure TMainForm.UndoBtnClick(Sender: TObject);
begin
  (ActiveMDIChild as TEdForm).Undo1Click(Sender);
end;

procedure TMainForm.PrintBtnClick(Sender: TObject);
begin
  (ActiveMDIChild as TEdForm).Print1Click(Sender);
end;

procedure TMainForm.SaveBtnClick(Sender: TObject);
begin
  (ActiveMDIChild as TEdForm).Gem1Click(Sender);
end;

procedure TMainForm.CutBtnClick(Sender: TObject);
begin
  (ActiveMDIChild as TEdForm).Cut1Click(Sender);
end;

procedure TMainForm.CopyBtnClick(Sender: TObject);
begin
  (ActiveMDIChild as TEdForm).Copy1Click(Sender);
end;

procedure TMainForm.PasteBtnClick(Sender: TObject);
begin
  (ActiveMDIChild as TEdForm).Insert1Click(Sender);
end;

procedure TMainForm.TestBtnClick(Sender: TObject);
begin
  IF (ActiveMDIChild is TEdForm)
  THEN (ActiveMDIChild as TEdForm).Run1Click(Sender);
end;

procedure TMainForm.PickListBtnClick(Sender: TObject);
begin
  IF PickListCreated THEN
    BEGIN
      PickListForm.Hide;
      LastActiveEd:=nil;
      PickListBtn.Down:=False;
      PickListCreated:=False;
    END
  ELSE
    BEGIN
      PickListForm.show;
      PickListBtn.Down:=True;
      PickListCreated:=True;
      PickListForm.show;
    END;
  IF CodeHelpOn THEN
    BEGIN
      CodeHelpOn:=False;
      CodeHelpBtn.Down:=False;
    END;
end;

{Process toolbar click events}

Procedure TMainForm.ProcessBtnClick(Sender: TObject);
VAR
  p:TPoint;
begin
  (Sender As TSpeedButton).Down:=True;
  P.y:=(Sender as TSpeedButton).Top + (Sender as TSpeedButton).Height;
  P.x:=(Sender as TSpeedButton).Left;
  p:=WorkProcessToolBar.ClientToScreen(P);
  IF Sender=MakeDatafileBtn THEN
    BEGIN
      IF MDIChildCount=0 THEN MakeDatafileBtnClick(Sender)
      ELSE MakeDatafilePopUp.PopUp(p.x,p.y);
    END;
  IF Sender=DefineDataBtn THEN DefineDataPopUp.PopUp(p.x,p.y);
  IF Sender=AddValidationBtn THEN AddValidationPopUp.PopUp(p.x,p.y);
  IF Sender=DocumentBtn THEN DocumentPopUp.PopUp(p.x,p.y);
  IF Sender=ExportDataBtn THEN ExportDataPopUp.PopUp(p.x,p.y);
  (Sender As TSpeedButton).Down:=False;
END;

{event handlers for turning toolbars on or off}

procedure TMainForm.Toolbars1Click(Sender: TObject);
begin
  {put checkmarks on items in main menu}
  WorkProcessToolbar1.Checked:=WorkProcessToolbar.Visible;
  EditorToolbar1.Checked:=EditorToolbar.Visible;
  HideToolBarsDuringDataEntry1.Checked:=HideToolBarsDuringDataEntry;
  {put checkmars on items in popup menu on toolsbars}
  WorkProcessToolbar2.Checked:=WorkProcessToolbar.Visible;
  EditorToolbar2.Checked:=EditorToolbar.Visible;
  HideToolBarsDuringDataEntry2.Checked:=HideToolBarsDuringDataEntry;
  IF (WorkProcessToolBar.Visible) AND (EditorToolBar.Visible) THEN
    BEGIN
      Both1.Caption:=Lang(2065);   //'None'
      Both2.Caption:=Both1.Caption;
    END
  ELSE
    BEGIN
      Both1.Caption:=Lang(1616);   //'Both';
      Both2.Caption:=Both1.Caption;
    END;
end;

procedure TMainForm.WorkProcessToolbar1Click(Sender: TObject);
begin
  WorkProcessToolBar.Visible:=NOT WorkProcessToolBar.Visible;
  WorkProcessToolBarOn:=WorkProcessToolBar.Visible;
end;

procedure TMainForm.EditorToolbar1Click(Sender: TObject);
begin
  EditorToolBar.Visible:=NOT EditorToolBar.Visible;
  EditorToolBarOn:=EditorToolBar.Visible;
end;

procedure TMainForm.Both1Click(Sender: TObject);
begin
  IF both1.caption=Lang(1616) THEN   //'Both'
    BEGIN
      EditorToolBar.Visible:=True;
      WorkProcessToolBar.Visible:=True;
    END
  ELSE
    BEGIN
      EditorToolBar.Visible:=False;
      WorkProcessToolBar.Visible:=False;
    END;
  EditorToolBarOn:=EditorToolBar.Visible;
  WorkProcessToolBarOn:=WorkProcessToolBar.Visible;
end;

{Eventhandlers for Help menu}

procedure TMainForm.Contents1Click(Sender: TObject);
begin
  Application.HelpCommand(HELP_FINDER,0);
end;

procedure TMainForm.InfoTester1Click(Sender: TObject);
VAR
  InfoFilename:TFilename;
begin
//  Application.HelpContext(100);
  InfoFilename:=ExtractFileDir(ParamStr(0))+'\ReadMe.rtf';
  IF FileExists(InfoFilename) THEN
    BEGIN
      LockWindowUpdate(MainForm.Handle);
      WITH TEdForm.Create(Self) DO
        BEGIN
          Ed.ReadOnly:=True;
          Ed.PlainText:=False;
          Ed.WordWrap:=True;
          Caption:='Information to testers';
          Ed.Lines.LoadFromFile(InfoFilename);
        END;  //with
      LockWindowUpdate(0);
    END
  ELSE ErrorMsg('ReadMe.Rtf not found.');
end;

procedure TMainForm.AboutEpiData1Click(Sender: TObject);
begin
  TRY
    AboutForm:=TAboutForm.Create(Application);
    AboutForm.ShowModal;
  FINALLY
    AboutForm.Free;
  END;
end;

{Event handler for Files menuitem - show recent files}

procedure TMainForm.Filer1Click(Sender: TObject);
begin
  application.ShowHint:=True;
  self.ShowHint:=True;
  IF RecentFiles[1]<>'' THEN
    BEGIN
      RecentDivider.Visible:=True;
      Recent1.Caption:='&1. '+ExtractFileName(RecentFiles[1]);
      Recent1.Visible:=True;
      Recent1.Hint:=Recentfiles[1];
    END
  ELSE
    BEGIN
      RecentDivider.Visible:=False;
      Recent1.Visible:=False;
    END;
  IF RecentFiles[2]<>'' THEN
    BEGIN
      Recent2.Caption:='&2. '+ExtractFileName(RecentFiles[2]);
      Recent2.Visible:=True;
    END
  ELSE Recent2.Visible:=False;
  IF RecentFiles[3]<>'' THEN
    BEGIN
      Recent3.Caption:='&3. '+ExtractFileName(RecentFiles[3]);
      Recent3.Visible:=True;
    END
  ELSE Recent3.Visible:=False;
  IF RecentFiles[4]<>'' THEN
    BEGIN
      Recent4.Caption:='&4. '+ExtractFileName(RecentFiles[4]);
      Recent4.Visible:=True;
    END
  ELSE Recent4.Visible:=False;
  IF RecentFiles[5]<>'' THEN
    BEGIN
      Recent5.Caption:='&5. '+ExtractFileName(RecentFiles[5]);
      Recent5.Visible:=True;
    END
  ELSE Recent5.Visible:=False;
  IF RecentFiles[6]<>'' THEN
    BEGIN
      Recent6.Caption:='&6. '+ExtractFileName(RecentFiles[6]);
      Recent6.Visible:=True;
    END
  ELSE Recent6.Visible:=False;
  IF RecentFiles[7]<>'' THEN
    BEGIN
      Recent7.Caption:='&7. '+ExtractFileName(RecentFiles[7]);
      Recent7.Visible:=True;
    END
  ELSE Recent7.Visible:=False;
  IF RecentFiles[8]<>'' THEN
    BEGIN
      Recent8.Caption:='&8. '+ExtractFileName(RecentFiles[8]);
      Recent8.Visible:=True;
    END
  ELSE Recent8.Visible:=False;
end;

{Eventhandler for click on one of the recent files}

procedure TMainForm.Recent1Click(Sender: TObject);
VAR
  rN:Integer;
begin
  rN:=0;
  IF Sender=Recent1 THEN rN:=1;
  IF Sender=Recent2 THEN rN:=2;
  IF Sender=Recent3 THEN rN:=3;
  IF Sender=Recent4 THEN rN:=4;
  IF Sender=Recent5 THEN rN:=5;
  IF Sender=Recent6 THEN rN:=6;
  IF Sender=Recent7 THEN rN:=7;
  IF Sender=Recent8 THEN rN:=8;
  IF (rN=0) THEN Exit;
  IF NOT CanOpenFile(RecentFiles[rN]) THEN Exit;
  IF (ANSIUpperCase(ExtractFileExt(RecentFiles[rN]))<>'.REC') THEN
    BEGIN
      LockWindowUpdate(MainForm.Handle);
      WITH TEdForm.Create(Self) DO Open(RecentFiles[rN]);
      LockWindowUpdate(0);
    END
  ELSE DoOpenDatafile(RecentFiles[rN]);
end;


Function TMainForm.OpenRelateFile(Filename:String; MotherDf,RelDf: Pointer; VAR RelAct: TOpenRelAction):Boolean;
VAR
  n:Integer;
  df: PDataFileInfo;
  FieldNames:TStrings;
  tmpStr,curdir:String;
  ADataForm: TDataForm;
BEGIN
  Result:=False;
  //RelAct.Act:=raNothing;
  RelAct.Action:=raNothing;
  TRY
    df:=PDataFileInfo(RelDf);
    df^.QESFileName:='';
    df^.RECFilename:=Filename;
    df^.RelateMother:=PDataFileInfo(MotherDf);
    df^.IsRelateFile:=True;

    IF NOT PeekDatafile(df) THEN Exit;

    IF (NOT LoadScreenCoords(df)) THEN
      BEGIN
        FieldNames:=TStringList.Create;
        FieldNames.Capacity:=df^.FieldList.Count;
        FOR n:=0 TO df^.FieldList.Count-1 DO
          FieldNames.Append(PeField(df^.FieldList.Items[n])^.FName);
        tmpStr:='';
        FieldListToQes(df,tmpStr,false);
        DestroyFieldList(df^.FieldList);
        df^.FieldList:=TList.Create;
        DontMakeFieldNames:=True;
        IF NOT TranslateQes(df,tmpStr) THEN
          BEGIN
            Screen.Cursor:=crDefault;
            ErrorMsg(Format(Lang(20104),[df^.RECFilename]));  //'Error building dataform from %s.'
            DontMakeFieldNames:=False;
            Exit;
          END;  //if not translateQes
        DontMakeFieldNames:=False;

        //  Retrieve fieldnames from stringlist
        FOR n:=0 TO df^.FieldList.Count-1 DO
          PeField(df^.FieldList.Items[n])^.FName:=FieldNames[n];
        FieldNames.Free;
      END;

    tmpStr:='';
    df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
    df^.HasCheckFile:=FileExists(df^.CHKFilename);
    IF df^.HasCheckFile THEN
      IF NOT PeekApplyCheckFile(df,tmpStr) THEN
        BEGIN
          Screen.Cursor:=crDefault;
          TRY
            CheckErrorForm:=TCheckErrorForm.Create(MainForm);
            CheckErrorForm.CheckBox1.Checked:=ShowCheckFileCheckMark;
            IF CheckErrorForm.ShowModal=mrYes THEN
              BEGIN
                IF CheckErrorForm.checkBox1.Checked THEN
                  BEGIN
                    RelAct.Action:=raOpenTwoFilesInEditor;
                    RelAct.File2:=df^.CHKFilename;
                    RelAct.File1:=tmpStr;
                  END
                ELSE
                  BEGIN
                    RelAct.Action:=raOpenFileInEditor;
                    RelAct.File1:=tmpStr;
                  END;
              END;
            ShowCheckFileCheckMark:=CheckErrorForm.CheckBox1.Checked;
          FINALLY
            CheckErrorForm.Free;
          END;  //try..finally
          //ErrorMsg(Lang(20106)+' '+df^.CHKFilename);  //'Errors found in checkfile '
          Exit;
        END;
    IF df^.IndexCount>0 THEN
      IF ApplyIndex(df)=False THEN
        BEGIN
          ErrorMsg(Format(Lang(20128),[df^.IndexFilename]));  //Error reading index file %s
          Exit;
        END;

    LockWindowUpDate(MainForm.Handle);
    OpenWithRelate:=True;
    MainForm.TabCtrl.Visible:=True;
    ADataForm:=TDataForm.Create(MainForm);
    ADataForm.Caption:=ExtractFilename(df^.RECFilename);
    MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
                  IndexOfObject(TObject(ADataForm))]:=ADataForm.Caption;
    LockWindowUpDate(0);
    ADataForm.df:=df;
    df^.DatForm:=TObject(ADataForm);
    ADataForm.PutFieldsOnForm;
    pSetUpLastField(df);
    IF (df^.NumRecords>0) AND (df^.IDNUMField<>-1) THEN
      BEGIN  //The datafile contains a IDNUM field
        peReadRecord(df,df^.NumRecords);
        IF df^.NumRecords>0 THEN
          BEGIN
            TmpStr:=PeField(df^.FieldList.Items[df^.IDNUMField])^.FFieldText;
            IF IsInteger(trim(TmpStr))
            THEN df^.CurIDNumber:=StrToInt(TmpStr)+1
            ELSE df^.CurIDNumber:=1;
          END
        ELSE df^.CurIDNumber:=FirstIDNumber;
      END  //if IDNUMField<>-1
    ELSE df^.CurIDNumber:=FirstIDNumber;
    peNewRecord(df);
    //ADataForm.FocusFirstField;    //&& Fjernet 19-01-2003
    Result:=True;
  EXCEPT
    ErrorMsg(Format(Lang(20108),[Filename]));  //Datafile %s could not be opened.
    Result:=False;
    Exit;
  END;  //try..except
END;  //OpenRelatefile

procedure TMainForm.DoOpenDatafile(Filename:String);
VAR
  df,relDf:PDatafileInfo;
  tmpStr,curdir,qfilename,s,rfilename:String;
  ADataForm: TDataForm;
  FieldNames,dbcLines:TStrings;
  n,n2:Integer;
  RelAction: TOpenRelAction;
  starttid,endtid:TDateTime;
  Hour,Min,Sec,MSec:Word;


BEGIN
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),    //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      MakeDatafileBtn.Down:=False;
      Exit;
    END;

  //Check if qes-file if newer than the rec-file
  qfilename:=ChangeFileExt(Filename,'.qes');
  IF FileExists(qfilename) THEN
    BEGIN
      IF FileAge(qfilename)>FileAge(Filename) THEN
        BEGIN
          tmpStr:=Lang(20811)+'  '+extractFilename(Filename)+'    '+     //20811=Data file:
                  FormatDateTime('d. mmm yyyy t',FileDateToDateTime(FileAge(Filename)))+#13+
                  'Qes-file:  '+extractFilename(qFilename)+'    '+
                  FormatDateTime('d. mmm yyyy t',FileDateToDateTime(FileAge(qFilename)))+#13#13+
                  Lang(20900)+'?';   //20900=Revise data file from revised .QES file
          IF NoYesDlg(tmpStr)=mrYes THEN
            BEGIN
              //Begin revision of datafile
              IF (NOT DoReviseDatafile(qfilename,filename)) THEN Exit;
            END;  //if revise datafile
        END;  //if qes-file is newer than rec-file
    END;  //if qes-file exists

  IF NOT GetDatafilePointer(df) THEN Exit;
  Screen.Cursor:=crHourGlass;
  df^.QESFileName:='';
  df^.RECFilename:=expandfilename(Filename);
  //tmpStr:=expandfilename(filename);
  AddToRecentFiles(df^.RecFilename);
  Screen.Cursor:=crHourGlass;
  CheckFileMode:=False;
  try
  IF NOT PeekDatafile(df) THEN
    BEGIN
      Screen.Cursor:=crDefault;
      DisposeDatafilePointer(df);
      Exit;
    END;
  except
    screen.cursor:=crDefault;
    DisposeDatafilePointer(df);
    Exit;
  end;

  CurDir:=GetCurrentDir;
  IF (NOT LoadScreenCoords(df)) THEN
    BEGIN
      // Save fieldnames in stringlist
      FieldNames:=TStringList.Create;
      FieldNames.Capacity:=df^.FieldList.Count;
      FOR n:=0 TO df^.FieldList.Count-1 DO
        FieldNames.Append(PeField(df^.FieldList.Items[n])^.FName);

      tmpStr:='';
      FieldListToQes(df,tmpStr,false);
      DestroyFieldList(df^.FieldList);
      df^.FieldList:=TList.Create;
      DontMakeFieldNames:=True;
      IF NOT TranslateQes(df,tmpStr) THEN
        BEGIN
          Screen.Cursor:=crDefault;
          ErrorMsg(Format(Lang(20104),[df^.RECFilename]));  //'Error building dataform from %s.'
          FieldNames.Free;
          DisposeDatafilePointer(df);
          DontMakeFieldNames:=False;
          Exit;
        END;  //if not translateQes
      DontMakeFieldNames:=False;

      {Put de gemte feltnavne ind i df^.FieldList}
      //  Retrieve fieldnames fra stringlist
      FOR n:=0 TO df^.FieldList.Count-1 DO
        PeField(df^.FieldList.Items[n])^.FName:=FieldNames[n];
      FieldNames.Free;
    END;

  tmpStr:='';
  df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
  df^.HasCheckFile:=FileExists(df^.CHKFilename);
  IF df^.HasCheckFile THEN
    IF NOT PeekApplyCheckFile(df,tmpStr) THEN
      BEGIN
        Screen.Cursor:=crDefault;
        CheckErrorForm:=TCheckErrorForm.Create(MainForm);
        CheckErrorForm.CheckBox1.Checked:=ShowCheckFileCheckMark;
        IF CheckErrorForm.ShowModal=mrYes THEN
          BEGIN
            LockWindowUpdate(MainForm.handle);
            WITH TEdForm.Create(Self) DO
              BEGIN
                Caption:=Lang(20106)+' '+df^.CHKFilename;  //'Errors found in checkfile'
                Ed.Lines.Text:=tmpStr;
                Ed.SelStart:=0;
              END;  //with
            IF CheckErrorForm.CheckBox1.Checked THEN
              BEGIN
                WITH TEdForm.Create(Self) DO Open(df^.CHKFilename);
                TileMode:=tbVertical;
                Tile;
              END;
            LockWindowUpdate(0);
          END;
        ShowCheckFileCheckMark:=CheckErrorForm.CheckBox1.Checked;
        CheckErrorForm.Free;
        DisposeDatafilePointer(df);
        Exit;
      END;
  IF df^.IndexCount>0 THEN
    IF ApplyIndex(df)=False THEN
      BEGIN
        DisposeDatafilePointer(df);
        Exit;
      END;
  Screen.Cursor:=crHourGlass;

  OpenWithRelate:=False;
  IF Assigned(RelateFiles) THEN
    BEGIN
      IF RelateFiles.Count>0 THEN
        BEGIN
          OpenWithRelate:=True;
          MainForm.TabCtrl.Visible:=True;
          n:=0;
          df^.IsRelateTop:=True;
          RelAction.Action:=raNothing;
          REPEAT
            GetDataFilePointer(RelDf);
            RelateFiles.Objects[n]:=TObject(RelDf);
            IF NOT OpenRelateFile(RelateFiles[n],RelateMothers[n],Pointer(RelDf),RelAction) THEN
              BEGIN
                FOR n:=0 TO RelateFiles.Count-1 DO
                  BEGIN
                    RelDf:=PDataFileInfo(RelateFiles.Objects[n]);
                    IF RelDf<>NIL THEN
                      BEGIN
                        IF RelDf^.DatForm<>NIL THEN
                          BEGIN
                            RelDf^.CurRecModified:=False;
                            RelDf^.IsRelateFile:=False;
                            TDataform(RelDf^.DatForm).Close;
                          END
                        ELSE DisposeDataFilePointer(RelDf);
                      END;
                  END;
                DisposeDataFilePointer(df);
                RelateFiles.Free;
                RelateFiles:=NIL;
                tabCtrl.Tabs.Clear;
                tabCtrl.visible:=False;
                IF RelAction.Action<>raNothing THEN
                  BEGIN
                    LockWindowUpdate(MainForm.handle);
                    WITH TEdForm.Create(Self) DO
                      BEGIN
                        Caption:=Lang(20106);  //'Errors found in checkfile'
                        Ed.Lines.Text:=RelAction.File1;
                        Ed.SelStart:=0;
                        TileMode:=tbVertical;
                        Tile;
                      END;  //with
                    IF RelAction.Action=raOpenTwoFilesInEditor THEN
                      BEGIN
                        WITH TEdForm.Create(Self) DO Open(RelAction.File2);
                        TileMode:=tbVertical;
                        Tile;
                      END;
                    LockWindowUpdate(0);
                  END;
                Exit;
              END;
            INC(n);
          UNTIL n=RelateFiles.Count;
          FOR n:=0 TO RelateFiles.Count-1 DO
            BEGIN
              WITH PDataFileInfo(RelateFiles.Objects[n])^ DO
                BEGIN
                  IF df^.BackupList<>NIL THEN df^.BackupList.Append(RECFilename);
                  IsReadOnly:=True;
                  TDataForm(DatForm).SetToReadOnly;
                END;  //with
            END;  //for
        END;  //if relatefiles.count>0
    END;  //if assigned(relatefiles)

  //Handle double entry
  IF (NOT OpenWithRelate) AND (FileExists(ChangeFileExt(df^.RECFilename,'.dbc'))) THEN
    BEGIN
      TRY
        df^.dbOrigKeyfieldno:=-1;
        df^.dbNewKeyfieldno:=-1;
        dbcLines:=TStringList.Create;
        dbcLines.LoadFromFile(ChangefileExt(df^.RECFilename,'.dbc'));
        df^.dbFilename:=dbcLines.Values['dbfile'];
        IF (dbcLines.Values['text']='check') THEN df^.dbIgnoretext:=False ELSE df^.dbIgnoretext:=True;
        //IF (dbcLines.Values['keyfield']<>'') THEN df^.dbKeyfieldno:=StrToInt(dbcLines.Values['keyfield']) ELSE df^.dbKeyfieldno:=-1;
        IF (dbcLines.Values['keyfieldname']<>'') THEN df^.dbKeyfieldname:=dbcLines.Values['keyfieldname'] ELSE df^.dbKeyfieldname:='';
        IF trim(df^.dbFilename)<>'' THEN
          BEGIN
            IF FileExists(df^.dbFilename) THEN
              BEGIN
                IF GetDatafilePointer(df^.dbDf) THEN
                  BEGIN
                    df^.dbDf^.RECFilename:=df^.dbFilename;
                    IF PeekDatafile(df^.dbDf) THEN   //AND (df^.dbKeyfieldno<df^.FieldList.Count)
                      BEGIN
                        df^.dbOrigKeyfieldno:=GetFieldNumber(df^.dbKeyfieldname,df^.dbDf);
                        df^.dbNewKeyfieldno:=GetFieldNumber(df^.dbKeyfieldname,df);
                        IF (df^.dbKeyfieldname<>'') AND ((df^.dbNewKeyfieldno=-1) OR (df^.dbOrigKeyfieldno=-1)) THEN
                          BEGIN
                            s:=Lang(22708)+': '+df^.dbKeyfieldname; //Unknown field name
                            df^.DoubleEntry:=False;
                          END
                        ELSE
                          BEGIN
                            df^.DoubleEntry:=True;
                            df^.dbDf^.CurRecord:=-2;
                          END
                      END
                    ELSE df^.DoubleEntry:=False;
                  END;    //if getdatafilepointer
              END  //if fileexists
            ELSE s:=format(Lang(22114),[df^.dbFilename]);        //22114='%s' not found
          END;  //if dbfilename exists


      FINALLY
        dbcLines.Free;
      END;
      IF df^.DoubleEntry=False THEN
        BEGIN
          DisposeDatafilePointer(df^.dbDf);
          DisposeDatafilePointer(df);
          tmpStr:=Lang(25000)+#13#13;  //'DOUBLE ENTRY VERIFICATION MODE'#13#13;
          tmpStr:=tmpStr + Lang(3200);  //error
          IF s<>'' THEN tmpStr:=tmpStr+#13#13+s;
          ErrorMsg(tmpStr);
          exit;
        END;
    END;  //if open original datafile


  SetCurrentDir(CurDir);
  LockWindowUpDate(MainForm.Handle);
  IF HideToolbarsDuringDataEntry THEN
    BEGIN
      OldWorkProcessToolBar:=WorkProcessToolBar.Visible;
      OldEditorToolbar:=EditorToolBar.Visible;
      WorkProcessToolBar.Visible:=False;
      EditorToolBar.Visible:=False;
    END;
  ADataForm:=TDataForm.Create(MainForm);
  ADataForm.Caption:=ExtractFilename(df^.RECFilename);
  IF TabCtrl.Visible THEN
    BEGIN
      n:=MainForm.TabCtrl.Tabs.IndexOfObject(TObject(ADataForm));
      MainForm.TabCtrl.Tabs[n]:=ADataForm.Caption;
      MainForm.TabCtrl.Tabs.Move(n,0);
      ChangeGoingOn:=True;
      TabCtrl.TabIndex:=0;
    END;
  LockWindowUpDate(0);
  ADataForm.df:=df;
  //ActiveRelateFile:=df;
  ADataForm.ActivateRelateFile(df);
  df^.DatForm:=TObject(ADataForm);
//StartTid:=Now;
  ADataForm.PutFieldsOnForm;
//EndTid:=Now;
//DecodeTime(EndTid-StartTid,Hour,Min,Sec,MSec);
//ADataForm.Caption:=FloatToStr(Int(Sec)+(Int(MSec)/1000));
  pSetUpLastField(df);
  IF (df^.NumRecords>0) AND ( (df^.HasRepeatField) OR (df^.IDNUMField<>-1) )
    THEN peReadRecord(df,df^.NumRecords);
  IF (df^.IDNUMField<>-1) THEN
    BEGIN  //The datafile contains a IDNUM field
      IF df^.NumRecords>0 THEN
        BEGIN
          TmpStr:=PeField(df^.FieldList.Items[df^.IDNUMField])^.FFieldText;
          IF IsInteger(trim(TmpStr))
          THEN df^.CurIDNumber:=StrToInt(TmpStr)+1
          ELSE df^.CurIDNumber:=1;
        END
      ELSE df^.CurIDNumber:=FirstIDNumber;
    END;  //if IDNUMField<>-1
  IF df^.IsRelateTop THEN
    BEGIN
      ShowRelateTreeMenuItem.Visible:=True;
      ShowRelateTreeMenuItem.Enabled:=True;
      ShowRelateTreeMenuItemClick(NIL);
      RelateTreeForm.RelateTree.selected:=RelateTreeForm.RelateTree.Items[0];
    END;
  IF Assigned(df^.BeforeFileCmds) THEN ADataForm.ExecCommandList(df^.BeforeFileCmds);
  df^.CurRecModified:=False;
  IF (df^.HasCrypt) AND (df^.Key='') THEN TDataForm(df^.DatForm).SetToReadOnly;   //&&
  peNewRecord(df);
  IF df^.ShowLastRecord THEN TDataForm(df^.DatForm).ChangeRec(0,dirLast);
  Screen.Cursor:=crDefault;
  IF df^.DoubleEntry THEN
    BEGIN
      tmpStr:=Lang(25000)+#13#13;  //'DOUBLE ENTRY VERIFICATION MODE'#13#13;
      tmpStr:=tmpStr+Format(Lang(25002),[trim(df^.dbDF^.RECFilename)])+#13#13;    //'Data compared with~%s'
      IF df^.dbIgnoretext THEN tmpStr:=tmpStr+Lang(25004)+#13;   //'Data in text fields will be ignored.'
      IF df^.dbOrigKeyfieldno=-1
      THEN tmpStr:=tmpStr+Lang(25006)      //'Compare by: Recordnumber.'
      ELSE tmpStr:=tmpStr+Lang(25008)+' '+AnsiUpperCase(df^.dbKeyfieldname);     //AnsiUpperCase(trim(PeField(df^.dbDf^.FieldList.Items[df^.dbKeyfieldno])^.FName));  //'Compare by: Field '
      eDlg(tmpStr,mtInformation,[mbOK],0);
    END;

  ADataForm.FocusFirstField;
  ADataForm.Show;

  //Handle programparameter /FINDvarname=text
  if (FindFieldname<>'') and (FindFieldtext<>'') then
    begin
      n:=GetFieldNumber(FindFieldname,df);
      if n<>-1 then
        begin
          New(df^.FindOpt);
          df^.FindOpt^.FoundRecs:=NIL;
          ResetFindOptions(df);
          with df^.FindOpt^ do
            begin
              StartRecord:=1;
              NumCrites:=1;
              Scope:=ssForward;
              WholeWordsOnly:=true;
              Crites[1].Fieldno:=n;
              Crites[1].Opr:=opEq;
              Crites[1].SearchText:=FindFieldtext;
            end;  //with
          n2:=Search(df,true);
          if n2>0 then peReadRecord(df,n2)
          else
            begin
              peNewRecord(df);
              TEntryField(PeField(df^.FieldList.Items[n])^.EntryField).Text:=FindFieldtext;
            end;
        end;  //if field found
    end;  //handle find
END;   // DoOpenDatafile


procedure TMainForm.MakeDatafileBtnClick(Sender: TObject);
VAR
  t:Integer;
  mess,Oldfilelabel:String;
  QESLines:TStrings;
  df:PDatafileInfo;
  TheEdForm: TEdForm;
  qFilename: TFilename;
  Found:Boolean;
begin
  MakeDatafileBtn.Down:=False;
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),   //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      Exit;
    END;

  qFilename:='';
  IF MDIChildCount>0 THEN
    BEGIN
      IF (ActiveMDIChild is TEdForm) THEN
        BEGIN
          TheEdForm:=(ActiveMDIChild AS TEdForm);
          IF TheEdForm.Ed.Modified THEN
            BEGIN
              CASE eDlg(Format(Lang(20300),[TheEdForm.PathName]),  //'Save changes to %s?'
                  mtConfirmation,[mbYes, mbNo, mbCancel],0) OF
                idYes: TheEdForm.Gem1Click(Sender);
                idCancel: Exit;
                idNo: TheEdForm.Ed.Modified:=False;
              END;  //case
            END;
          IF AnsiLowerCase(ExtractFileExt(TheEdForm.PathName))<>'.qes' THEN
            BEGIN
              ErrorMsg(Lang(20400));  //'Datafiles can only be made from QES-files.'
              Exit;
            END
          ELSE
            BEGIN
              qFilename:=TheEdForm.Pathname;
            END;
        END;
      IF (ActiveMDIChild is TDataForm) AND (TestingDataForm) THEN
        BEGIN
          {Make Datafile was called from preview dataform}
          {Find out if the qes-file the called preview is still open}
          qFilename:=AnsiUpperCase((ActiveMDIChild AS TDataForm).df.QESFilename);
          Found:=False;
          t:=0;
          WHILE (NOT Found) AND (t<MDIChildCount-1) DO
            BEGIN
              IF (MDIChildren[t] is TEdForm)
              THEN IF qFilename=AnsiUpperCase((MDIChildren[t] as TEdForm).Pathname)
                THEN Found:=True;
              INC(t);
            END;  //while
          IF NOT Found THEN qFilename:=''
          ELSE
            BEGIN
              {The qes-file that called preview dataform is open}
              {Close preview and set focus to qes-file}
              qFilename:=(ActiveMDIChild as TDataForm).df.QESFilename;
              TheEdForm:=(MDIChildren[t-1] as TEdForm);
              (ActiveMDIChild as TDataForm).Close;
              TheEdForm.SetFocus;
              IF TheEdForm.Ed.Modified THEN
                BEGIN
                  CASE eDlg(Format(Lang(20300), [TheEdForm.PathName]),  //'Save changes to %s?'
                      mtConfirmation,[mbYes, mbNo, mbCancel],0) OF
                    idYes: TheEdForm.Gem1Click(Sender);
                    idCancel: Exit;
                    idNo: TheEdForm.Ed.Modified:=False;
                  END;  //case
                END;  //if modified
            END;  //if qes-file was open
        END;  //if ActiveMDIChild is TDataForm
    END;  //if MDIChildCount>0

  SelectFilesForm:=TSelectFilesForm.Create(MainForm);
  WITH SelectFilesForm DO
    BEGIN
      SelectFilesForm.Caption:=Lang(20402);    //'Create datafile from QES-file'
      Ext1:='.qes';
      Ext2:='.rec';
      File1Label.Caption:=Lang(4710);   //'Enter name of QES-file'
      File2Label.Caption:=Lang(4712);      //'Enter name of datafile'
      File2MustExist:=False;
      WarnOverwrite2:=True;
      UpdateFile2Text:=True;
      IF qFilename='' THEN
        BEGIN
          t:=1;
          WHILE (t<8) AND
            (AnsiUpperCase(ExtractFileExt(RecentFiles[t]))<>'.QES') DO INC(t);
          IF AnsiUpperCase(ExtractFileExt(RecentFiles[t]))='.QES'
          THEN File1Edit.Text:=RecentFiles[t];
        END
      ELSE File1Edit.Text:=qFilename;
    END;  //with


  IF SelectFilesForm.ShowModal<>mrOK THEN
    BEGIN
      SelectFilesForm.Free;
      Exit;
    END;
  IF qFilename<>'' THEN TheEdForm.Close1Click(Sender);
  TRY
    IF NOT GetDatafilePointer(df) THEN
      BEGIN
        SelectFilesForm.Free;
        Exit;
      END;
    df^.QESFileName:=SelectFilesForm.File1Edit.Text;
    df^.RECFilename:=SelectFilesForm.File2Edit.Text;
    OldfileLabel:=SelectFilesForm.OldfileLabel;
    SelectFilesForm.Free;
    TRY
      QESLines:=TStringList.Create;
      QESLines.LoadFromFile(df^.QESFilename);
    EXCEPT
      ErrorMsg(Format(Lang(20406),[df^.QESFilename]));   //'QES-file %s cannot be found or opened.');
      QESLines.Free;
      DisposeDatafilePointer(df);
      MakeDatafileBtn.Down:=False;
      Exit;
    END;  //try..except
    mess:=QESLines.Text;
    QESLines.Free;
    TRY
      InputForm:=TInputForm.Create(Application);
    EXCEPT
      InputForm.Free;
      ErrorMsg(Format(Lang(20204),[751]));   //'Out of memory (reference code 751)');
      DisposeDatafilePointer(df);
      MakeDatafileBtn.Down:=False;
      Exit;
    END;
    InputForm.Maxlength:=50;
    InputForm.LabelText:=Lang(20408);   //'Enter description of datafile (datafile label)'
    Inputform.DefaultValue:=OldfileLabel;
    InputForm.Caption:=Lang(20410)+' '+ExtractFilename(df^.RECFilename);  //'Datafile label for'
    IF InputForm.ShowModal=mrOK THEN df^.Filelabel:=InputForm.UserInput;
    InputForm.Free;

    CreatingFromQesFile:=True;
    df^.EpiInfoFieldNaming:=EpiInfoFieldNaming;
    df^.UpdateFieldnameInQuestion:=UpdateFieldnameInQuestion;
    IF TranslateQes(df,mess)=False THEN
      BEGIN
        CreatingFromQesFile:=False;
        LockWindowUpdate(MainForm.Handle);
        TRY
          RapForm:=TEdform.Create(MainForm);
          RapFormCreated:=TRUE;
          RapForm.Caption:=Lang(20412);   //'Error log'
          RapForm.Ed.Text:=Mess;
          RapForm.Ed.Modified:=FALSE;
        EXCEPT
          RapForm.Free;
          RapFormCreated:=FALSE;
        END;  //try..except
        LockWindowUpdate(0);
      END  //if createIndtastningsFormError
    ELSE  //DataForm created successfully
      BEGIN
        CreatingFromQesFile:=False;
        IF df^.NumFields=0 THEN
          ErrorMsg(Format(Lang(20414),[df^.QESFilename])) //'The QES-file %s does not contain any entryfields.~~Datafile is not created.'
        ELSE
          BEGIN
            IF NOT PeekCreateDataFile(df) THEN
              ErrorMsg(Format(Lang(20416),[df^.RECFilename])+#13+Lang(20206))
              //20416='The datafile with the name %s cannot be created.'
              //20206='Please check if the filename is legal or if the disk is writeprotected or full.
            ELSE
              BEGIN
                IF df^.key<>'User Cancelled' THEN
                  BEGIN
                    eDlg(Format(Lang(20418),[df^.RECFilename]),   //'Datafile %s created.',
                      mtInformation,[mbOK],0);
                    AddToRecentFiles(df^.RECFilename);
                  END;
              END;  //if CreateDataFile=true
          END;  //if FeltListe.Count>0
      END;  //DataForm created successfully
    EXCEPT

    END;  //try..finally
  DisposeDatafilePointer(df);
END;   //procedure CreateDatafileBtnClick

procedure TMainForm.ExportToTxt1Click(Sender: TObject);
begin
  ExportType:=etTxt;
  ExportDatafile;
end;

procedure TMainForm.ExportToDBase1Click(Sender: TObject);
begin
  ExportType:=etDBase;
  ExportDatafile;
end;

procedure TMainForm.Makeqesfilefromdatafile1Click(Sender: TObject);
begin
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),   //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
    END
  ELSE MakeQesFromRec;   //In ExportFormUnit
end;

procedure TMainForm.Options1Click(Sender: TObject);
VAR
  opN:Integer;
  OptionsResult:Integer;
begin
  TRY
    FontChanged:=False;
    ColorChanged:=False;
    OptionsForm:=TOptionsForm.Create(Application);
{    tmpEdFont:=TFont.Create;
    tmpDataFormFont:=TFont.Create;
    tmpDocuFont:=TFont.Create;
    tmpEdFont:=EdFont ;
    tmpEdColor:=EdColor;
    tmpDataFormFont:=DataFormFont;
    tmpDataFormColor:=DataFormColor;
    tmpDocuFont:=DocuFont;
    tmpDocuColor:=DocuColor;}
    OptionsResult:=OptionsForm.ShowModal;
    IF OptionsResult=mrOK THEN
      BEGIN
        WITH OptionsForm DO
          BEGIN
            IF LanguageCombo.Items[LanguageCombo.ItemIndex]<>CurLanguage THEN
              BEGIN
                CurLanguage:=LanguageCombo.Items[LanguageCombo.ItemIndex];
                IF AnsiUpperCase(CurLanguage)='ENGLISH' THEN UsesEnglish:=True ELSE UsesEnglish:=False;
                NoLangError:=False;
                InitLanguage;
                TranslateForm(MainForm);
                TranslateForm(PickListForm);
                ArrangeToolBarButtons;
              END;
            EdColor:=FontExPanel.Color;
            epiEdFont.Assign(FontExPanel.Font);
            DataFormColor:=DataFontExPanel.Color;
            epiDataFormFont.Assign(DataFontExPanel.Font);
            epiDocuFont.Assign(DocuFontExPanel.Font);
            DocuColor:=DocuFontExPanel.Color;
            TRY
              EvenTabValue:=StrToInt(EvenTabEdit.Text);
            EXCEPT
              EvenTabValue:=40;
            END;  //try..Except
            TRY
              NumberOfTabChars:=StrToInt(NumTabCharsEdit.Text);
            EXCEPT
              NumberOfTabChars:=4;
            END;  //try..Except
            TRY
              FirstIDNumber:=StrToInt(IDNUMEdit.Text);
            EXCEPT
              FirstIDNumber:=1;
            END;  //try..except
            CASE FieldNameCaseRadio.ItemIndex OF
              0: FieldNameCase:=fcUpper;
              1: FieldNameCase:=fcLower;
              2: FieldNameCase:=fcDontChange;
            END;  //case
            IF FieldnameTypeRadio.ItemIndex=0
            THEN EpiInfoFieldNaming:=False ELSE EpiInfoFieldNaming:=True;
            UpdateFieldnameInQuestion:=UpdateQuestionCheck.Checked;
            ShowExprErrors:=ShowExprErrorsCheck.Checked;
            WarningSounds:=WarningSoundsCheck.Checked;
            FieldColor:=FieldColorPanel.Color;
            FieldStyle:=FieldStyleRadio.ItemIndex;
            FieldHighlightActive:=HighlightActiveCheck.Checked;
            FieldHighlightActive:=HighlightColorBtn.Enabled;
            FieldHighlightColor:=HighlightColorPanel.Color;
            LineHeight:=LineHeightRadio.ItemIndex;
          END;   //with optionsForm
        IF MDIChildCount>0 THEN
          BEGIN
            FOR opN:=0 TO MDIChildCount-1 DO
              BEGIN
                TranslateForm(MDIChildren[opN]);
                IF (MDIChildren[opN] is TEdForm) THEN
                  BEGIN
                    WITH MDIChildren[opN] AS TEdForm DO
                      BEGIN
                        Case FormType OF
                          ftEditor:BEGIN
                            Ed.Color:=EdColor;
                            Ed.Font.Assign(epiEdFont);
                            END;
                          ftDocumentation:BEGIN
                            Ed.Color:=DocuColor;
                            Ed.Font.Assign(epiDocuFont);
                            END;
                        END;  //case
                      END;  //with
                  END;  //if TEdForm
              END;  //for
          END;  //if MDIChildCount>0
      END;  //if mrOK
    IF OptionsResult=mrAll THEN
      BEGIN
        //Restore to default options was pressed
        EdColor:=clWindow;
        WITH epiEdFont DO
          BEGIN
            Charset:=DEFAULT_CHARSET;
            Color:=clWindowText;
            Name:='Courier New';
            Size:=10;
            Style:=[];
          END;   //With
        WITH epiDataFormFont DO
          BEGIN
            Charset:=DEFAULT_CHARSET;
            Color:=clWindowText;
            Name:='Courier New';
            Size:=10;
            Style:=[];
          END;
        DataFormColor:=clBtnFace;
        WITH epiDocuFont DO
          BEGIN
            Charset:=DEFAULT_CHARSET;
            Color:=clWindowText;
            Name:='Courier New';
            Size:=10;
            Style:=[];
          END;  //With
        DocuColor:=clWindow;
        EvenTabValue:=40;
        NumberOfTabChars:=4;
        FirstIDNumber:=1;
        FieldNameCase:=fcUpper;
        EpiInfoFieldNaming:=True;
        UpdateFieldnameInQuestion:=True;
        ShowExprErrors:=False;
        FieldColor:=clWindow;
        FieldStyle:=1;
        FieldHighlightActive:=False;
        FieldHighlightColor:=clYellow;
        LineHeight:=1;

        IF MDIChildCount>0 THEN
          BEGIN
            FOR opN:=0 TO MDIChildCount-1 DO
              BEGIN
                IF (MDIChildren[opN] is TEdForm) THEN
                  BEGIN
                    WITH MDIChildren[opN] AS TEdForm DO
                      BEGIN
                        Case FormType OF
                          ftEditor:BEGIN
                            Ed.Color:=EdColor;
                            Ed.Font.Assign(epiEdFont);
                            END;
                          ftDocumentation:BEGIN
                            Ed.Color:=DocuColor;
                            Ed.Font.Assign(epiDocuFont);
                            END;
                        END;  //case
                      END;  //with
                  END;  //if TEdForm
              END;  //for
          END;  //if MDIChildCount>0
      END;  //if mrAll
    FOR opN:=0 TO OptionsForm.OptionsPageControl.PageCount-1 DO
      IF OptionsForm.OptionsPageControl.Pages[opN]=OptionsForm.OptionsPageControl.ActivePage
      THEN LastActiveOptionsPage:=opN;
  FINALLY
    OptionsForm.Free;
  END;  //try..finally
end;  //procedure Options1Click

procedure TMainForm.ExporttoExcelfile1Click(Sender: TObject);
begin
  ExportType:=etXLS;
  ExportDatafile;
end;

procedure TMainForm.ExporttoStata1Click(Sender: TObject);
begin
  ExportType:=etStata;
  ExportDatafile;
end;


procedure TMainForm.pNew2Click(Sender: TObject);
{Add/revise checks in peekmode}
VAR
  nN:Integer;
  OldOpenDialogTitle:String;
  df:PDatafileInfo;
  tmpStr:String;
  ADataForm:TDataForm;
  FieldNames:TStrings;
begin
  AddValidationBtn.Down:=False;
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),    //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      MakeDatafileBtn.Down:=False;
      Exit;
    END;
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OldOpenDialogTitle:=OpenDialog1.Title;
  OpenDialog1.Title:=Lang(20500);   //'Select datafile to base the checkfile on'
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF NOT OpenDialog1.Execute THEN
    BEGIN
      OpenDialog1.Title:=OldOpenDialogTitle;
      Exit;
    END;
  OpenDialog1.Title:=OldOpenDialogTitle;
  IF NOT GetDatafilePointer(df) THEN Exit;
  df^.QESFileName:='';
  df^.RECFilename:=OpenDialog1.Filename;
  df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
  AddToRecentFiles(OpenDialog1.Filename);

  Screen.Cursor:=crHourGlass;
  IF NOT PeekDatafile(df) THEN
    BEGIN
      Screen.Cursor:=crDefault;
      DisposeDatafilePointer(df);
      Exit;
    END;
  // Save fieldnames in stringlist
  FieldNames:=TStringList.Create;
  FOR nN:=0 TO df^.FieldList.Count-1 DO
    FieldNames.Append(PeField(df^.FieldList.Items[nN])^.FName);

  tmpStr:='';
  FieldListToQes(df,tmpStr,false);
  DestroyFieldList(df^.FieldList);
  df^.FieldList:=TList.Create;
  IF NOT TranslateQes(df,tmpStr) THEN
    BEGIN
      ErrorMsg(Format(Lang(20104),[df^.RECFilename]));  //'Error building dataform from %s.'
      FieldNames.Free;
      disposeDatafilePointer(df);
      Exit;
    END;
  //  Retrieve fieldnames fra stringlist
  FOR nN:=0 TO df^.FieldList.Count-1 DO
    PeField(df^.FieldList.Items[nN])^.FName:=FieldNames[nN];
  FieldNames.Free;

  tmpStr:='';
  df^.HasCheckFile:=FileExists(df^.CHKFilename);
  IF df^.HasCheckFile THEN
    BEGIN
      CheckFileMode:=True;
      IF NOT PeekApplyCheckFile(df,tmpStr) THEN
        BEGIN
          Screen.Cursor:=crDefault;
          CheckErrorForm:=TCheckErrorForm.Create(MainForm);
          CheckErrorForm.CheckBox1.Checked:=ShowCheckFileCheckMark;
          IF CheckErrorForm.ShowModal=mrYes THEN
            BEGIN
              LockWindowUpdate(MainForm.handle);
              WITH TEdForm.Create(Self) DO
                BEGIN
                  Caption:=Format(Lang(20502),[df^.CHKFilename]);  //'Errors found in checkfile %s'
                  Ed.Lines.Text:=tmpStr;
                  Ed.SelStart:=0;
                END;  //with
              IF CheckErrorForm.CheckBox1.Checked THEN
                BEGIN
                  WITH TEdForm.Create(Self) DO Open(df^.CHKFilename);
                  TileMode:=tbVertical;
                  Tile;
                END;
              LockWindowUpdate(0);
            END;
          ShowCheckFileCheckMark:=CheckErrorForm.CheckBox1.Checked;
          CheckErrorForm.Free;
          DisposeDatafilePointer(df);
          Exit;
        END;
    END;  //if HasCheckFile
  CheckFileMode:=True;
  LockWindowUpdate(MainForm.Handle);
  IF HideToolbarsDuringDataEntry THEN
    BEGIN
      OldWorkProcessToolBar:=WorkProcessToolBar.Visible;
      OldEditorToolbar:=EditorToolBar.Visible;
      WorkProcessToolBar.Visible:=False;
      EditorToolBar.Visible:=False;
    END;
  ADataForm:=TDataForm.Create(MainForm);
  ADataForm.df:=df;
  ADataForm.Caption:=Format(Lang(20504),[ExtractFilename(df^.RECFilename)]);  //'Add/revise checks - %s'
  ADataForm.Goto1.Enabled:=False;   //Hide Goto menu
  ADataForm.Goto1.Visible:=False;
  ADataForm.FirstField1.ShortCut:=ShortCut(0, []);
  ADataForm.LastField1.ShortCut:=Shortcut(0,[]);
  ADataForm.ScrollUp1.ShortCut:=Shortcut(0,[]);
  ADataForm.ScrollDown1.ShortCut:=Shortcut(0,[]);
  ADataForm.Findfield1.ShortCut:=ShortCut(0,[]);
  ADataForm.Fields1.Visible:=True;  //Show Fields menu
  ADataForm.Fields1.Enabled:=True;
  ADataForm.EditChecks1.Enabled:=True;
  LockWindowUpDate(0);
  LockWindowUpdate(ADataForm.ScrollBox1.Handle);
  df^.DatForm:=TObject(ADataForm);
  df^.DataFormCreated:=True;
  ADataForm.PutFieldsOnForm;
  peNewRecord(df);
  pNewCheckFile(df);
  LockWindowUpdate(0);
  Screen.Cursor:=crDefault;
  OpenDialog1.Title:=OldOpenDialogTitle;
  ADataForm.FocusFirstField;
end;

procedure TMainForm.ClearChecks1Click(Sender: TObject);
VAR
  OldOpenDialogTitle,tmpCheckFilename:String;
  tmpBool:Boolean;
begin
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OldOpenDialogTitle:=OpenDialog1.Title;
  OpenDialog1.Title:=Lang(20506);   //'Select the datafile the checks is based on'
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF OpenDialog1.Execute THEN
    BEGIN
      tmpCheckFilename:=ChangeFileExt(OpenDialog1.Filename,'.chk');
      IF WarningDlg(Lang(20508)+' '   //'This will clear all checks added to the datafile'
      +OpenDialog1.Filename+#13#13+Lang(20510))=mrOK THEN   //'Clear all checks?'
        BEGIN
          IF WarningDlg(Lang(20512)+#13+OpenDialog1.Filename  //All checks added to the datafile will be deleted!
          +#13#13+Lang(20510))=mrOK THEN   //'Clear all checks?'
            BEGIN
              IF FileExists(ChangeFileExt(tmpCheckFilename,'.bak'))
              THEN tmpBool:=DeleteFile(ChangeFileExt(tmpCheckFilename,'.bak'));
              RenameFile(tmpCheckFilename,ChangeFileExt(tmpCheckFilename,'.bak'));
              AddToRecentFiles(OpenDialog1.Filename);
            END;  //if OK2
        END;  //if OK
    END;  //if OpenDialog.Execute
  OpenDialog1.Title:=OldOpenDialogTitle;
end;  //procedure ClearChecks

procedure TMainForm.Variableinfo1Click(Sender: TObject);
VAR
  FieldNumber,n,nN,nN2,nN3:Integer;
  tmpLines:TStrings;
  tmpWidth,SizeUnit:String[10];
  tmpType:String[20];
  tmpStr,tmpS:String;
  QuestStr,CheckStr,ValLabelStr:ARRAY [1..25] OF String[20];
  ErrorInCheckFile, UsesValueLabels:Boolean;
  FileSiz:LongInt;
  df:PDatafileInfo;
  AEdForm:TEdForm;
  ALabelRec:PLabelRec;
  tmpBool: Boolean;
  autolist:TStringList;
  AField2: PeField;

  Function CutString(VAR s:String; ch:TCharSet; wid:Integer):String;
  VAR
    LastOccur, cN:Integer;
  BEGIN
    IF Length(s)<=wid THEN
      BEGIN
        Result:=s;
        s:='';
      END
    ELSE
      BEGIN
        LastOccur:=0;
        FOR cN:=1 TO Wid DO
          IF (s[cN] in ch) THEN LastOccur:=cN;
        IF LastOccur=0 THEN LastOccur:=Wid;
        Result:=Copy(s,1,LastOccur);
        Delete(s,1,LastOccur);
      END;
  END;  //End CutString

begin
  DocumentBtn.Down:=False;
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),   //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      MakeDatafileBtn.Down:=False;
      Exit;
    END;
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF NOT OpenDialog1.Execute THEN Exit;
  IF NOT GetDatafilePointer(df) THEN Exit;
  df^.QESFileName:='';
  df^.RECFilename:=OpenDialog1.Filename;
  AddToRecentFiles(df^.RECFilename);
  Screen.Cursor:=crHourGlass;
  df^.DontGetPassword:=True;
  IF PeekDatafile(df) THEN
    BEGIN
      tmpStr:='';
      ErrorInCheckFile:=False;
      df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
      df^.HasCheckFile:=FileExists(df^.CHKFilename);
      IF df^.HasCheckFile
      THEN ErrorInCheckFile:=NOT PeekApplyCheckFile(df,tmpStr);
      TRY
        tmpLines:=TStringList.Create;
        tmpLines.Capacity:=df^.FieldList.Count+15;

        {Write heading}
        tmpLines.Append('');
        tmpLines.Append(Format(Lang(20600),[df^.RECFilename]));   //'DATAFILE: %s'
        IF trim(df^.FileLabel)<>''
        THEN tmpLines.Append(Format(Lang(20602),[df^.FileLabel]))  //'Filelabel: %s'
        ELSE tmpLines.Append(Format(Lang(20602),[Lang(20604)]));   //'Filelabel: %s'
        tmpLines.Append('');

        {Write datafile information}
        //FileSiz:=FileSize(df^.Datfile);
        FileSiz:=df^.DatFile.Size;  //§§§
        SizeUnit:=' '+Lang(20606);   //'bytes';
        IF FileSiz>10000 THEN
          BEGIN
            FileSiz:=FileSiz DIV 1024;
            SizeUnit:=' '+Lang(20608);   //'kb';
          END;
        tmpLines.Append(FitLength(Lang(20610),23)+IntToStr(FileSiz)+SizeUnit);  //'Filesize:'
        tmpLines.Append(FitLength(Lang(20612),23)+      //'Last revision:'
          FormatDateTime('d. mmm yyyy t',
          FileDateToDateTime(FileAge(df^.RECFilename))));
        tmpLines.Append(FitLength(Lang(20614),23)+IntToStr(df^.NumFields));   //Number of fields:
        tmpStr:=FitLength(Lang(20616),23);   //'Number of records:'
        IF df^.NumRecords=-1
        THEN tmpStr:=tmpStr+Lang(20618)    //'Error in datafile. Number of records cannot be counted.'
        ELSE tmpStr:=tmpStr+IntToStr(df^.NumRecords);
        tmpLines.Append(tmpStr);
        tmpStr:=FitLength(Lang(20619),23);   //'Checks applied:';
        IF (df^.HasCheckfile) AND (NOT ErrorInCheckFile)
        THEN tmpStr:=tmpStr+Format(Lang(20620),     //'Yes (Last revision %s)'
          [FormatDateTime('d. mmm yyyy t',FileDateToDateTime(FileAge(df^.CHKFilename)))])
        ELSE tmpStr:=tmpStr+Lang(20622);   //'No'
        tmpLines.Append(tmpStr);
        IF ErrorInCheckFile THEN tmpLines.Add(cFill(' ',23)+Lang(20624));  //'Warning: A checkfile exists but it contains errors.'
        tmpLines.Append('');

        {Check if value labels are used}
        UsesValueLabels:=False;
        FOR nN:=0 TO df^.FieldList.Count-1 DO
          IF PeField(df^.FieldList.Items[nN])^.FCommentLegalRec<>NIL
          THEN UsesValueLabels:=True;
        IF ErrorInCheckfile THEN UsesValueLabels:=False;

        {Write variable information}
        tmpLines.Append('');
        tmpLines.Append(Lang(20626));   //'Fields in datafile:'
        tmpLines.Append('');
{
1   5          16                    38              54     61                    83
-------------------------------------------------------------------------------------------------------
NUM Name       Variable label        Type            Width  Checks                Value labels
-------------------------------------------------------------------------------------------------------
100 andekeltke Abcdefghijklmnopqrst  Integer                Must enter, repeat
           uvxyzæøp              Upper-case text        Legal: 5-10,14,45,
                                 Boolean                  46,50
                                 Floating point  7:3    Jumps:
                                 US date                  2>IFDLE
                                 Today's date             3>IUWLW

3   10         20                    15              5      20                    20
}


        IF UsesValueLabels
        THEN tmpLines.Append(Format('%3s %-10s %-20s  %-15s %-5s  %-20s  %-20s',
          [Lang(20628),Lang(20630),Lang(20632),Lang(20634),Lang(20636),Lang(20638),Lang(20640)]))
          {20628=No.
          20630=Name
          20632=Variable label
          20634=Fieldtype
          20636=Width
          20638=Checks
          20640=Value labels}
        ELSE tmpLines.Append(Format('%3s %-10s %-20s  %-15s %-5s  %-20s',
          [Lang(20628),Lang(20630),Lang(20632),Lang(20634),Lang(20636),Lang(20638)]));
        IF UsesValueLabels THEN tmpLines.Append(cFill('-',102))
        ELSE tmpLines.Append(cFill('-',80));
        FieldNumber:=0;
        FOR nN:=0 TO df^.FieldList.Count-1 DO
          BEGIN
            WITH PeField(df^.FieldList.Items[nN])^ DO
              BEGIN
                IF FeltType<>ftQuestion THEN
                  BEGIN
                    INC(FieldNumber);
                    {Reset arrays}
                    FOR nN2:=1 TO 25 DO
                      BEGIN
                        QuestStr[nN2]:='';
                        CheckStr[nN2]:='';
                        ValLabelStr[nN2]:='';
                      END;
                    {Put Var-label in array}
                    tmpStr:=trim(FVariableLabel);
                    WHILE Pos('@',tmpStr)>0 DO Delete(tmpStr,Pos('@',tmpStr),1);
                    nN2:=1;
                    WHILE (tmpStr<>'') AND (nN2<=25) DO
                      BEGIN
                        QuestStr[nN2]:=CutString(tmpStr,[' '],16);
                        INC(nN2);
                      END;
                    IF tmpStr<>'' THEN
                      BEGIN
                        IF Length(tmpStr)>16 THEN tmpStr:=Copy(tmpStr,1,16);
                        tmpStr:=tmpStr+'...';
                      END;

                    {Put Checks in array}
                    IF NOT ErrorInCheckFile THEN
                      BEGIN
                        nN2:=1;
                        IF FIndex>0 THEN
                          BEGIN
                            tmpStr:='Key ';
                            IF df^.IndexIsUnique[FIndex] THEN tmpStr:=tmpStr+'unique ';
                            tmpStr:=tmpStr+IntToStr(FIndex);
                            CheckStr[nN2]:=tmpStr;
                            INC(nN2);
                          END;
                        IF FAutoSearch THEN
                          BEGIN
                            tmpStr:='Autosearch ';
                            //IF FAutoList THEN tmpStr:=tmpStr+' LIST ';
                            TRY
                              autolist:=TStringList.Create;
                              autolist.CommaText:=FAutoFields;
                              FOR nN3:=0 TO autolist.count-1 DO
                                BEGIN
                                  AField2:=PeField(df^.FieldList.Items[StrToInt(autoList[nN3])]);
                                  tmpStr:=tmpStr+trim(AField2^.FName)+' ';
                                END;
                            FINALLY
                              autolist.Free;
                            END;
                            CheckStr[nN2]:=tmpStr;
                            INC(nN2);
                          END;
                        IF FMustEnter THEN
                          BEGIN
                            CheckStr[nN2]:='Must enter';
                            INC(nN2);
                          END;
                        IF FRepeat THEN
                          BEGIN
                            CheckStr[nN2]:='Repeat';
                            INC(nN2);
                          END;
                        IF FDefaultValue<>'' THEN
                          BEGIN
                            CheckStr[nN2]:='Default value='+FDefaultValue;
                            INC(nN2);
                          END;
                        IF (FMissingValues[0]<>'') THEN
                          BEGIN
                            CheckStr[nN2]:='Missing value='+FMissingValues[0];
                            IF (FMissingValues[1]<>'') THEN CheckStr[nN2]:=CheckStr[nN2]+','+FMissingValues[1];
                            IF (FMissingValues[2]<>'') THEN CheckStr[nN2]:=CheckStr[nN2]+','+FMissingValues[2];
                          END;
                        IF FNoEnter THEN
                          BEGIN
                            CheckStr[nN2]:='NoEnter';
                            INC(nN2);
                          END;
                        IF FLegal<>'' THEN
                          BEGIN
                            tmpStr:='Legal: '+trim(FLegal);
                            WHILE Pos('"',tmpStr)>0 DO
                              Delete(tmpStr,Pos('"',tmpStr),1);
                            WHILE (tmpStr<>'') AND (nN2<=25) DO
                              BEGIN
                                CheckStr[nN2]:=CutString(tmpStr,[' ',','],20);
                                INC(nN2);
                              END;
                            IF tmpStr<>'' THEN
                              BEGIN
                                IF Length(tmpStr)>17
                                THEN tmpStr:=Copy(tmpStr,1,17);
                                tmpStr:=tmpStr+'...';
                              END;
                          END;
                        IF FJumps<>'' THEN
                          BEGIN
                            tmpStr:='Jumps: '+trim(FJumps);
                            WHILE Pos('"',tmpStr)>0 DO
                              Delete(tmpStr,Pos('"',tmpStr),1);
                            WHILE (tmpStr<>'') AND (nN2<=25) DO
                              BEGIN
                                CheckStr[nN2]:=CutString(tmpStr,[' ',','],20);
                                INC(nN2);
                              END;
                            IF tmpStr<>'' THEN
                              BEGIN
                                IF Length(tmpStr)>17
                                THEN tmpStr:=Copy(tmpStr,1,17);
                                tmpStr:=tmpStr+'...';
                              END;
                          END;
                        IF (AfterCmds<>NIL) or (BeforeCmds<>NIL) THEN
                          BEGIN
                            IF nN2=25 THEN CheckStr[25]:=Lang(20642)   //'More: See Checkfile'
                            ELSE CheckStr[nN2]:=Lang(20642);
                          END;
                      END;  //if not errorInCheckfile

                    {Put value labels in array}
                    IF (UsesValueLabels) AND (FCommentLegalRec<>NIL) THEN
                      BEGIN
                        ALabelRec:=FCommentLegalRec;
                        nN2:=1;
                        IF FValueLabel[Length(FValueLabel)]<>'$' THEN
                          BEGIN
                            tmpStr:=FValueLabel;
                            IF tmpStr[Length(tmpStr)]='¤'
                            THEN Delete(tmpStr,Length(tmpStr),1);
                            ValLabelStr[nN2]:=tmpStr;
                            INC(nN2);
                          END;
                        WHILE (ALabelRec<>NIL) AND (nN2<25) DO
                          BEGIN
                            IF ALabelRec^.Value[1]<>'*' THEN   //##
                              BEGIN
                                tmpStr:=ALabelRec^.Value+': '+ALabelRec^.Text;
                                IF Length(tmpStr)>20 THEN ValLabelStr[nN2]:=Copy(tmpStr,1,20)
                                ELSE ValLabelStr[nN2]:=tmpStr;
                                INC(nN2);
                              END;
                            ALabelRec:=ALabelRec^.Next;
                          END;  //While
                        IF (ALabelRec<>NIL) AND (nN2=25)
                        THEN ValLabelStr[25]:='...';
                      END;

                    IF (ORD(FeltType)>=0) AND (ORD(FeltType)<=20)  //&&
                    THEN tmpType:=FieldTypeNames[ORD(FeltType)]
                    ELSE tmpType:=Lang(20644);   //'Unknown type'
                    tmpWidth:=IntToStr(FLength);
                    IF (FeltType=ftFloat) AND (FNumDecimals>0)
                    THEN tmpWidth:=tmpWidth+':'+IntToStr(FNumDecimals);
                    IF FeltType=ftCrypt THEN tmpWidth:=IntToStr(FCryptEntryLength);   //&&
                    {Write first line}
                    IF UsesValueLabels
                    THEN tmpLines.Append(Format('%3d %-10s %-20s  %-15s %-5s  %-20s  %-20s',
                      [FieldNumber,FName,QuestStr[1],tmpType,
                      tmpWidth,CheckStr[1],ValLabelStr[1]]))
                    ELSE tmpLines.Append(Format('%3d %-10s %-20s  %-15s %-5s  %-20s',
                      [FieldNumber,FName,QuestStr[1],tmpType,
                      tmpWidth,CheckStr[1]]));
                    nN2:=2;
                    {Write next lines}
                    WHILE ((QuestStr[nN2]<>'') OR (CheckStr[nN2]<>'')
                    OR (ValLabelStr[nN2]<>'')) AND (nN2<=25) DO
                      BEGIN
                        IF UsesValueLabels
                        THEN tmpLines.Append(Format('%3s %-10s %-20s  %-15s %-5s  %-20s  %-20s',
                        ['','',QuestStr[nN2],'','',CheckStr[nN2],ValLabelStr[nN2]]))
                        ELSE tmpLines.Append(Format('%3s %-10s %-20s  %-15s %-5s  %-20s',
                        ['','',QuestStr[nN2],'','',CheckStr[nN2]]));
                        INC(nN2);
                      END;  //while
                    tmpLines.Append('');
                  END;  //if not fQuestion
              END;  //with
          END;  //for
        IF UsesValueLabels THEN nN:=102 ELSE nN:=80;
        tmpLines.Append(cFill('-',nN));
        tmpLines.Append('');
        LockWindowUpdate(MainForm.Handle);


        IF Length(tmpLines.Text)>65500 THEN
          BEGIN
            tmpS:=ExtractFileDir(ParamStr(0))+'\~EpdLog';
            n:=1;
            WHILE FileExists(tmpS+IntToStr(n)+'.tmp') DO INC(n);
            tmpS:=tmpS+IntToStr(n)+'.tmp';
            tmpLines.SaveToFile(tmpS);
            AEdForm:=TEdForm.Create(Self);
            WITH AEdForm DO
              BEGIN
                Open(tmpS);
                CloseFile(BlockFile);
                PathName:=DefaultFilename+IntToStr(WindowNum);
                Caption:=Format(Lang(20646),[df^.RECFilename]);  //'Datafile documentation for %s'
                MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
                  IndexOfObject(TObject(AEdForm))]:=DefaultFilename+IntToStr(WindowNum);
                FormType:=ftDocumentation;
                Ed.Font.Assign(epiDocuFont);
                Ed.SelStart:=0;
                Ed.Modified:=True;
              END;  //with
            tmpBool:=DeleteFile(tmpS);
          END
        ELSE
          BEGIN
            {Lin.Text < 65500 chars}
            Screen.Cursor:=crHourGlass;
            LockWindowUpdate(MainForm.Handle);
            AEdForm:=TEdForm.Create(MainForm);
            WITH AEdForm DO
              BEGIN
                //Ed.Visible:=False;
                FormType:=ftDocumentation;
                Caption:=Format(Lang(20646),[df^.RECFilename]);
                Ed.Font.Assign(epiDocuFont);
                Ed.Color:=DocuColor;
                Ed.ScrollBars:=ssBoth;
                Ed.Lines.Capacity:=tmpLines.Count;
                Ed.Lines.Text:=tmpLines.Text;
                Ed.ScrollBars:=ssBoth;
                //Ed.Visible:=True;
                Ed.SelStart:=0;
              END;
            //LockWindowUpDate(0);
            AEdform.SetFocus;
            Screen.Cursor:=crDefault;
          END;  //Lin.Text < 65500 chars
      Finally
        tmpLines.Free;
        LockWindowUpdate(0);
      END;  //try..except
    END;  //if datafile opened with succes
  DisposeDatafilePointer(df);
  Screen.Cursor:=crDefault;
end;  // Procedure Variableinfo1Click


procedure TMainForm.Backup1Click(Sender: TObject);
begin
  BackUpDataFile;
end;

procedure TMainForm.EpiDatahomepage1Click(Sender: TObject);
begin
  ExecuteFile('http://www.epidata.dk','', ExtractFileDir(ParamStr(0)), SW_SHOW);
end;

{procedure TMainForm.Openbug1Click(Sender: TObject);
VAR
  BugFilename,BugChkFilename:TFilename;
begin
  BugFilename:=ExtractFileDir(ParamStr(0))+'\Bugreport.rec';
  BugChkFilename:=ExtractFileDir(ParamStr(0))+'\Bugreport.chk';
  IF NOT FileExists(Bugfilename) THEN
    BEGIN
      eDlg(BugFilename+' is not found.'+#13#13+
      'Please download the file from the EpiData homepage.'+#13+
      'Click on ''EpiData homepage'' in the Help menu.',mtError,[mbOK],0);
      Exit;
    END;
  IF NOT FileExists(BugChkFilename) THEN
    BEGIN
      eDlg(BugChkFilename+' is not found.'+#13#13+
      'Please download the file from the EpiData homepage.'+#13+
      'Click on ''EpiData homepage'' in the Help menu.',mtError,[mbOK],0);
      Exit;
    END;
  DoOpenDatafile(BugFilename);
end;}

{procedure TMainForm.TourofEpiData1Click(Sender: TObject);
VAR
  TourFile:TFilename;
begin
  TourFile:=ExtractFileDir(ParamStr(0))+'\EpiTour.Hlp';
  IF NOT UsesEnglish AND (Lang(105)<>'**105**')
  THEN TourFile:=ExtractFileDir(ParamStr(0))+'\EpiTour_'+Lang(105)+'.Hlp';
  IF NOT FileExists(TourFile) THEN TourFile:=ExtractFileDir(ParamStr(0))+'\EpiTour.Hlp';
  IF FileExists(TourFile)
  THEN ExecuteFile(TourFile,'',ExtractFileDir(ParamStr(0)),SW_SHOW)
  ELSE eDlg(Format(Lang(22126),[TourFile]),mtError,[mbOK],0);   //The file %s does not exist.
end;}

procedure TMainForm.Fieldtypes1Click(Sender: TObject);
begin
  Application.HelpContext(100);
end;

procedure TMainForm.CodeHelpBtnClick(Sender: TObject);
begin
  CodeHelpOn:=NOT CodeHelpOn;
  CodeHelpBtn.Down:=CodeHelpOn;
  IF PickListCreated THEN
    BEGIN
      PickListForm.Hide;
      LastActiveEd:=nil;
      PickListBtn.Down:=False;
      PickListCreated:=False;
    END
end;

procedure TMainForm.TabCtrlChange(Sender: TObject);
begin
  IF NOT ChangeGoingOn THEN
    BEGIN
      LockWindowUpDate(MainForm.Handle);
      TForm(TabCtrl.Tabs.Objects[TabCtrl.TabIndex]).Show;
      LockWindowUpdate(0);
    END;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  IF StatusPanel.ClientWidth>398
  THEN StatPanel6.Width:=StatusPanel.ClientWidth-StatPanel6.Left-4;
end;

procedure TMainForm.PeekOpenDataForm1Click(Sender: TObject);
VAR
  n:Integer;
  tmpS: String;
begin
  EnterDataBtn.Down:=False;
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),     //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      MakeDatafileBtn.Down:=False;
      Exit;
    END;
  n:=1;
  tmpS:='';
  REPEAT
    IF AnsiUpperCase(ExtractFileExt(RecentFiles[n]))='.REC' THEN tmpS:=RecentFiles[n];
    INC(n);
  UNTIL (n>8) OR (tmpS<>'');
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  IF (tmpS<>'') AND (ExtractFileDir(tmpS)=GetRecentFiledir) THEN
    BEGIN
      OpenDialog1.InitialDir:=GetRecentFiledir;
      OpenDialog1.Filename:=tmpS;
    END
  ELSE
    BEGIN
      OpenDialog1.InitialDir:=GetRecentFiledir;
      OpenDialog1.Filename:=GetRecentFilename('.rec');
    END;
  IF NOT OpenDialog1.Execute THEN Exit;
  DoOpenDatafile(OpenDialog1.Filename);
END;


procedure TMainForm.Studydescription1Click(Sender: TObject);
VAR
  OldOpenDialogTitle:String;
  DESFilename:TFilename;
  F:TextFile;
begin
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OldOpenDialogTitle:=OpenDialog1.Title;
  OpenDialog1.Title:=Lang(20700);   //'Select the datafile you want to add notes to'
  OpenDialog1.InitialDir:=GetRecentFiledir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF OpenDialog1.Execute THEN
    BEGIN
      OpenDialog1.Title:=OldOpenDialogTitle;
      DESFilename:=ChangeFileExt(OpenDialog1.Filename,'.not');
      AddToRecentFiles(OpenDialog1.Filename);
      AddToRecentFiles(DESFilename);
      IF NOT FileExists(DESFilename) THEN
        BEGIN
          TRY
            AssignFile(F,DESFilename);
            ReWrite(F);
            WriteLN(F,Format(Lang(20702),[OpenDialog1.Filename]));  //'Dataentry notes for %s'
            WriteLN(F);
            CloseFile(F);
          EXCEPT
            ErrorMsg(Format(Lang(20704),   //'A dataentry notes file by the name %s cannot be created.',
            [DESFilename])+#13#13+
            Lang(20208));   //Please check if the file is in use and that the filename is legal.
            Exit;
          END;
        END;
      DoOpenQesFile(DESFilename);
    END;  //if OpenDialog.Execute
  OpenDialog1.Title:=OldOpenDialogTitle;
end;


procedure TMainForm.Shownoopendatafile1Click(Sender: TObject);
VAR
  s: String;
begin
  s:='No. of open datafiles is '+IntToStr(NumberOfOpenDatafiles)+#13;
  IF RelateFiles=NIL THEN s:=s+'RelateFiles=NIL'
  ELSE s:=s+'RelateFiles.Count='+InttoStr(RelateFiles.Count);
  ShowMessage(s);
end;

procedure TMainForm.Abort1Click(Sender: TObject);
begin
  Beep;
  UserAborts:=True;
end;

procedure TMainForm.Hidetoolbarsduringdataentry1Click(Sender: TObject);
begin
  HideToolBarsDuringDataEntry:=NOT HideToolBarsDuringDataEntry;
end;

procedure TMainForm.Datafilelabel2Click(Sender: TObject);
VAR
  OldOpenDialogTitle,Lin,OrigLinStart:String;
  FileLabel:String[50];
  F,F_output:TextFile;
  RecFilename:TFilename;
  n:Integer;
  tmpBool:Boolean;
begin
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OldOpenDialogTitle:=OpenDialog1.Title;
  OpenDialog1.Title:=Lang(20750);  //'Select a datafile to attach a filelabel to'
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF OpenDialog1.Execute THEN
    BEGIN
      AddToRecentFiles(OpenDialog1.Filename);
      RECFileName:=OpenDialog1.Filename;
      AssignFile(F,RECFilename);
      {$I-}
      Reset(F);
      n:=IOResult;
      {$I+}
      IF n<>0 THEN
        BEGIN
          ErrorMsg(Format(Lang(20108),[RECFilename]));  //'Datafile %s could not be opened.'
          Exit;
        END
      ELSE
        BEGIN
          ReadLN(F,Lin);
          n:=Pos('FILELABEL: ',AnsiUpperCase(Lin));
          IF n<>0 THEN
            BEGIN
              Filelabel:=Copy(Lin,n+Length('FILELABEL: '),Length(Lin));
              OrigLinStart:=Copy(Lin,1,n-1);
            END
          ELSE
            BEGIN
              Filelabel:='';
              OrigLinStart:=Lin+' ';
            END;
          TRY
            InputForm:=TInputForm.Create(Application);
          EXCEPT
            InputForm.Free;
            ErrorMsg(Format(Lang(20204),[825]));  //'Out of memory (reference code 825)');
            Exit;
          END;
          InputForm.Maxlength:=50;
          InputForm.LabelText:=Lang(20752);   //'Enter datafile label (max. 50 characters):'
          InputForm.Caption:=Format(Lang(20754),[ExtractFilename(RECFilename)]);  //'Datafile label for %s'
          InputForm.DefaultValue:=Filelabel;
          IF InputForm.ShowModal=mrOK THEN
            BEGIN
              Filelabel:=trim(InputForm.UserInput);
              AssignFile(F_output,ChangeFileExt(RECFilename,'.re$'));
              {$I-}
              Rewrite(F_output);
              n:=IOResult;
              {$I+}
              IF n<>0 THEN
                BEGIN
                  ErrorMsg(Format(Lang(20756),[ChangeFileExt(RECFilename,'.re$')]));  //'Error creating temporary output file %s'
                  CloseFile(F);
                END
              ELSE
                BEGIN
                  MainForm.StatPanel2.Caption:=Lang(20758);  //'Writing changes to datafile'
                  MainForm.StatPanel2.Repaint;
                  Screen.Cursor:=crHourGlass;
                  IF Filelabel<>'' THEN WriteLN(F_output,OrigLinStart+'Filelabel: '+Filelabel)
                  ELSE WriteLN(F_output,OrigLinStart);
                  REPEAT
                    ReadLN(F,Lin);
                    WriteLN(F_output,Lin);
                  UNTIL EOF(F);
                  CloseFile(F_output);
                  CloseFile(F);
                  tmpBool:=DeleteFile(RECFilename);
                  RenameFile(ChangeFileExt(RECFilename,'.re$'),RECFilename);
                  tmpBool:=DeleteFile(ChangeFileExt(RECFilename,'.re$'));
                  MainForm.StatPanel2.Caption:='';
                  Screen.Cursor:=crDefault;
                  eDlg(Format(Lang(20760),   //'Datafile label in %s updated.'
                    [RECFilename]),mtInformation,[mbOK],0);
                END;
            END   //if InputForm=mrOK
          ELSE CloseFile(F);
          InputForm.Free;
        END;  //if IOResult=0;
    END;  //if Datafile was opened;
  OpenDialog1.Title:=OldOpenDialogTitle;
end;

Procedure TMainForm.CloseAll;
VAR
  n: Integer;
BEGIN
  IF MDIChildCount>0 THEN
    FOR N:=MDIChildCount-1 DOWNTO 0 DO
      MDIChildren[N].Close;
END;


procedure TMainForm.Listdata1Click(Sender: TObject);
begin
  ListData;  //in ExportFormUnit
end;


procedure TMainForm.Codebook1Click(Sender: TObject);
TYPE
  TMissCountRec = record
                    misstext: String[10];
                    count: Integer;
                  end;
  TMissCount = Array[1..6] of TMissCountRec;

VAR
  MissCount: TMissCount;
  n,n2,CurRec,CurField,RecordPos:Integer;
  df:PDatafileInfo;
  R:TMemoryStream;
  Lin:TStringList;
  tmpS,tmpS2, tmpS3, FormStr:String;
  FieldT:PChar;
  FieldText:String;
  AField:PeField;
  AEdForm: TEdForm;
  ErrorInCheckFile, Found, CurRecDel, tmpBool: Boolean;
  UnDeletedRecs, NoMissing, NoNotMissing, LongestUnique: Integer;
  CharPointer: ^CHAR;
  MinValue,MaxValue, tmpValue, SumX,SumXsqr, MeanValue: Double;
  UniqueList: TStringList;
  WindowList:Pointer;
  Examples:ARRAY[1..4] OF String;
  ExampleCounter: Integer;
  OldDecimalSep: Char;
  ShowAllChecks: Boolean;
  SkipDel: Boolean;
  FromRec,ToRec,NumSelFields: Integer;
begin
  DocumentBtn.Down:=False;
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),   //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      MakeDatafileBtn.Down:=False;
      Exit;
    END;
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF NOT OpenDialog1.Execute THEN Exit;
  IF NOT GetDatafilePointer(df) THEN Exit;
  df^.QESFileName:='';
  df^.RECFilename:=OpenDialog1.Filename;
  AddToRecentFiles(df^.RECFilename);
  IF NOT PeekDatafile(df) THEN
    BEGIN
      DisposeDatafilePointer(df);
      Exit;
    END;

  df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
  df^.HasCheckFile:=FileExists(df^.CHKFilename);
  ErrorInCheckFile:=False;
  IF df^.HasCheckFile THEN ErrorInCheckFile:=NOT PeekApplyCheckFile(df,tmpS);
  IF ErrorInCheckFile THEN
    BEGIN
      IF eDlg(format(Lang(20800),[df^.CHKFilename])+   //'The checkfile %s contains errors and cannot be applied.'
      #13#13+Lang(20802)+   //'If you choose to continue then information on checks and value labels will be excluded in the codebook.'
      #13#13+Lang(20804),   //'Do you want to continue creating the codebook?',
      mtWarning,[mbYes,mbNo],0)=mrNo THEN
      BEGIN
        DisposeDatafilePointer(df);
        Exit;
      END;  //if users aborts
    END;  //if errorInCheckFile

  TRY
    ExportType:=etCodebook;
    ExportForm:=TExportForm.Create(MainForm);
    WITH ExportForm DO
      BEGIN
        Caption:=Lang(20808);   //'CODEBOOK';
        AllChecksRadio.Checked:=ShowAllChecksInCodebook;
        OnlyBasicChecksRadio.Checked:=NOT ShowAllChecksInCodebook;
        StataGroup.Visible:=False;
        TextFileGroup.Visible:=False;
        ListdataGroup.Visible:=False;
        CodebookGroup.Left:=(PageControl1.ClientWidth DIV 2)-(CodebookGroup.Width DIV 2);
        CodebookGroup.Top:=24;
        UseFilterCheck.Visible:=False;
        FilterLabel.Visible:=False;
        FilterEdit.Visible:=False;
        SkipDeletedCheck.Visible:=False;
        ExportToLabel.Visible:=False;
        ExportFilenameEdit.Visible:=False;
        SearchExpFileBtn.Visible:=False;
        RecordsGroup.Top:=40;
        FieldsGroup.Top:=40;
        FOR n:=0 TO df^.FieldList.Count-1 DO
          BEGIN
            AField:=PeField(df^.FieldList.Items[n]);
            AField^.FieldN:=0;
            IF AField^.FeltType<>ftQuestion THEN
              BEGIN
                FieldCheckList.Items.AddObject(trim(AField^.FName),TObject(AField));
                FieldCheckList.Checked[FieldCheckList.Items.Count-1]:=True;
              END;  //if
          END;  //for
        IF ShowModal<>mrOK THEN
          BEGIN
            Exportform.Free;
            DisposeDatafilePointer(df);
            Exit;
          END
        ELSE
          BEGIN
            ShowAllChecks:=AllChecksRadio.Checked;
            ShowAllChecksInCodebook:=ShowAllChecks;
            NumSelFields:=0;
            FOR n:=0 TO FieldCheckList.Items.Count-1 DO
              IF FieldCheckList.Checked[n] THEN
                BEGIN
                  PeField(FieldCheckList.Items.Objects[n])^.FieldN:=1;
                  INC(NumSelFields);
                END;
            FromRec:=1;
            ToRec:=df^.NumRecords;
            IF SelRecordsCheck.Checked THEN
              BEGIN
                IF (trim(FromRecEdit.Text)<>'') AND (IsInteger(FromRecEdit.Text))
                  THEN FromRec:=StrToInt(FromRecEdit.Text)
                  ELSE FromRec:=1;
                IF (trim(ToRecEdit.Text)<>'') AND (IsInteger(ToRecEdit.Text))
                  THEN ToRec:=StrToInt(ToRecEdit.Text)
                  ELSE ToRec:=df^.NumRecords;
                IF (FromRec>ToRec) OR (FromRec<1) THEN FromRec:=1;
                IF ToRec>df^.NumRecords THEN ToRec:=df^.NumRecords;
                IF ToRec<1 THEN ToRec:=df^.NumRecords;
              END;  //if SelRecordsCheck.Checked
            ExportForm.Free;
          END;  //if ModalResult=mrOK
      END;  //with
  EXCEPT
    ErrorMsg('Out of memory (ref.code 783)');
    ExportForm.Free;
    DisposeDatafilePointer(df);
    Exit;
  END;  //try..except


  //CloseFile(df^.DatFile);
  df^.DatFile.Free;  //§§§
  df^.Datfile:=NIL;  //§§§
  TRY
    R:=TMemoryStream.Create;
    R.LoadFromFile(df^.RECFilename);
    Lin:=TStringList.Create;
  EXCEPT
    ErrorMsg(Format(Lang(20806),[df^.RECFilename]));  //'There is not enough memory to create a codebook for %s'
    R.Free;
    Lin.Free;
    DisposeDatafilePointer(df);
    Exit;
  END;  //try..except
  TRY
    OldDecimalSep:=DecimalSeparator;
    DecimalSeparator:='.';
    WITH Lin DO
      BEGIN
        FormStr:='%-25s %s';
        tmpS:=Lang(20808);   //'CODEBOOK'
        Append(tmpS);
        Append('');
        Append(Format(FormStr,[Lang(20810),FormatDateTime('d. mmm yyyy t',Now)]));  //'Report generated'
        Append('');
        Append(Format(FormStr,[Lang(20811),df^.RECFilename]));  //'Datafile:'
        tmpS:=trim(df^.FileLabel);
        IF tmpS='' THEN tmpS:=Lang(20604);   //'[None]';
        Append(Format(FormStr,[Lang(20812),tmpS]));  //'File label:'
        Append(Format(FormStr,[Lang(20814),          //'File date:'
          FormatDateTime('d. mmm yyyy t',FileDateToDateTime(FileAge(df^.RECFilename)))]));
        IF NOT df^.HasCheckFile THEN tmpS:=Lang(20622)   //'No'
        ELSE tmpS:=Format(Lang(20620),     //'Yes (Last revision %s)'
          [FormatDateTime('d. mmm yyyy t',FileDateToDateTime(FileAge(df^.CHKFilename)))]);

        IF ErrorInCheckFile THEN tmpS:=Lang(20816);   //'Checkfile has errors and is not applied'
        Append(Format(FormStr,[Lang(20619),tmpS]));   //'Checks applied:'
        Append('');
        IF df^.NumFields=NumSelFields
        THEN Append(Format(FormStr,[Lang(20614),IntToStr(df^.NumFields)]))   //'Number of fields:'
        ELSE Append(Format(FormStr,[Lang(20614),IntToStr(df^.NumFields)+'  '+
             Format(Lang(20615),[NumSelFields])]));  //'(only %d is shown)'
        Append('');
      END;

    {Count no. of non-deleted records}
    UnDeletedRecs:=0;
    New(CharPointer);
    FOR CurRec:=FromRec TO ToRec DO
      BEGIN
        RecordPos:=df^.Offset+((CurRec-1)*df^.RecLength);
        R.Position:=RecordPos+df^.RecLength-3;
        R.Read(CharPointer^,1);
        IF CharPointer^='!' THEN INC(UnDeletedRecs);
      END;
    FormStr:='%-25s %'+IntToStr(Length(IntToStr(df^.NumRecords)))+'d';
    Lin.Append(Format(FormStr,[Lang(20818),df^.NumRecords]));   //'Records total:'
    IF (FromRec<>1) OR (ToRec<>df^.NumRecords)
    THEN Lin.Append(Format('%-25s %s',[Lang(20819),IntToStr(FromRec)+' - '+IntToStr(ToRec)]));  //'Included records:'
    Lin.Append(Format(FormStr,[Lang(20820),((ToRec-FromRec)+1)-UndeletedRecs]));  //'Deleted records:'
    Lin.Append(Format(FormStr,[Lang(20822),UndeletedRecs])+' '+Lang(20824));    //'Used in codebook:'  'records'
    Lin.Append('');

    UniqueList:=TStringList.Create;
    UniqueList.Sorted:=True;
    UniqueList.Duplicates:=dupIgnore;

    TRY
      UserAborts:=False;
      ProgressForm:=TProgressForm.Create(MainForm);
      ProgressForm.Caption:=Lang(20826);   //'Creating codebook';
      ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
      ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
      WITH ProgressForm.pBar DO BEGIN
        IF df^.FieldList.Count>2 THEN Max:=df^.FieldList.Count-2 ELSE Max:=2;
        Position:=0;
      END;  //with
      WindowList:=DisableTaskWindows(ProgressForm.Handle);
      ProgressForm.Show;

      MissCount[1].misstext:=df^.GlobalMissingValues[0];
      MissCount[2].missText:=df^.GlobalMissingValues[1];
      Misscount[3].MissText:=df^.GlobalMissingValues[2];
      FOR CurField:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          //Reset missing counter
          FOR n:=1 TO 6 DO
            MissCount[n].count:=0;
          AField:=PeField(df^.FieldList.Items[Curfield]);
          MissCount[4].MissText:=AField^.FMissingValues[0];
          Misscount[5].Misstext:=AField^.FMissingValues[1];
          MissCount[6].MissText:=AField^.FMissingValues[2];
          ProgressForm.pBar.Position:=Curfield+1;
          ProgressForm.pLabel.Caption:=Format(Lang(20828),   //'Writing field no. %d of %d'
          [CurField+1,df^.FieldList.Count]);
          IF (AField^.FeltType<>ftQuestion) AND (AField^.FieldN=1) THEN
            BEGIN
              {Write headerline}
              tmpS:=trim(AField^.FName);
              tmpS2:=trim(AField^.FVariableLabel);
              IF Length(tmpS2)>67 THEN tmpS2:=trim(Copy(tmpS2,1,67));
              tmpS:=tmpS+' '+cFill('-',80-2-Length(tmpS)-Length(tmpS2))+' '+tmpS2;
              Lin.Append(tmpS);
              {Write fieldtype}
              IF (AField^.Felttype=ftFloat) AND (AField^.FNumDecimals>0)
              THEN Lin.Append(format('     %18s:  %-s',[lang(20830),FieldTypeNames[0]+'('+IntToStr(AField^.FNumDecimals)+' '+Lang(20831)+')']))  //'type'  'decimals'
              ELSE Lin.Append(format('     %18s:  %-s',[Lang(20830),FieldTypeNames[ORD(AField^.FeltType)]]));
              {Write name of value label set}
              IF AField^.FCommentLegalRec<>NIL THEN
                BEGIN
                  IF AField^.FValueLabel[Length(AField^.FValueLabel)]<>'$' THEN
                    BEGIN
                      tmpS:=AField^.FValueLabel;
                      IF tmpS[Length(tmpS)]='¤' THEN Delete(tmpS,Length(tmpS),1);
                    END
                  ELSE tmpS:=Lang(20832);   //'Unnamed value label set';
                  Lin.Append(Format('     %18s:  %-s',[Lang(20834),tmpS]));  //'value labels'
                END;
              {Write check properties}
              IF (ShowAllChecks) AND (HasCheckProperties(AField)) THEN
                BEGIN
                  n:=Lin.Count;
                  FieldBlockToStrings(df,Lin,CurField,26);
                  Lin[n]:=Format('     %18s:  %-s',[AnsiLowerCase(Lang(20638)),trim(Lin[n])]);   //'checks'
                END
              ELSE
                BEGIN
                  IF AField^.FJumps<>'' THEN
                  Lin.Append(Format('     %18s:  %-s',['jumps',AField^.FJumps]));
                  IF AField^.FLegal<>'' THEN
                  Lin.Append(Format('     %18s:  %-s',['range/legal',AField^.FLegal]));
                  //IF AField^.BeforeCmds<>NIL
                  //THEN Lin.Append(Format('     %18s:  %-s',['before entry',Lang(20836)]));  //'Commands found (see checkfile)'
                  //IF AField^.AfterCmds<>NIL
                  //THEN Lin.Append(Format('     %18s:  %-s',['after entry',Lang(20836)]));   //'Commands found (see checkfile)'
                END;
              Lin.Append('');
              {Write different info for the diffent fieldtypes}
              MinValue:=MaxNumber;
              MaxValue:=MinNumber;
              SumX:=0;
              SumXsqr:=0;
              NoMissing:=0;
              UniqueList.Clear;
              ExampleCounter:=0;
              FOR CurRec:=FromRec TO ToRec DO
                BEGIN
                  RecordPos:=df^.Offset+((CurRec-1)*df^.RecLength);
                  R.Position:=RecordPos+df^.RecLength-3;
                  R.Read(CharPointer^,1);
                  IF CharPointer^='?' THEN CurRecDel:=True ELSE CurRecDel:=False;
                  IF (NOT CurRecDel) AND (AField^.FeltType<>ftQuestion) THEN
                    BEGIN
                      {Read value of field}
                      FieldT:=PChar(cFill(#0,AField^.FLength+3));
                      R.Position:=RecordPos+AField^.FStartPos;
                      R.ReadBuffer(FieldT^,AField^.FLength);
                      FieldText:=FieldT;
                      IF Pos('!',FieldText)>0 THEN
                        BEGIN
                          R.Position:=RecordPos+AField^.FStartPos;
                          R.ReadBuffer(FieldT^, AField^.FLength+3);
                          FieldText:=FieldT;
                          Delete(FieldText,Pos('!',FieldText),3);
                        END;
                      FieldText:=trim(FieldText);
                      IF trim(FieldText)='' THEN
                        BEGIN
                          INC(NoMissing);
                          n:=UniqueList.IndexOf('.');
                          IF n=-1 THEN UniqueList.AddObject('.',TObject(1))
                          ELSE UniqueList.Objects[n]:=Tobject(Integer(UniqueList.Objects[n])+1);
                        END
                      ELSE
                        BEGIN
                          //Her skal testes for om der er tale om et felt
                          //der kan have missingvalue defineret
                          //Hvis ja - så test om værdien er en missing
                          //Hvis ja - så INC(NoMissing) og INC(relevalt missing tæller)
                          IF (AField^.Felttype in [ftInteger,ftFloat]) THEN
                            BEGIN
                              IF FieldText=MissCount[1].MissText THEN INC(MissCount[1].Count)
                              ELSE IF FieldText=MissCount[2].Misstext THEN INC(MissCount[2].Count)
                              ELSE IF FieldText=MissCount[3].Misstext THEN INC(MissCount[3].Count);
                            END;
                          IF FieldText=MissCount[4].MissText THEN INC(MissCount[4].Count)
                          ELSE IF FieldText=MissCount[5].MissText THEN INC(MissCount[5].Count)
                          ELSE IF FieldText=MissCount[6].MissText THEN INC(MissCount[6].Count);
                          IF (AField^.Felttype=ftInteger) or (AField^.Felttype=ftFloat)
                          THEN tmpS:=format('%'+IntToStr(AField^.FLength)+'s',[FieldText])
                          ELSE tmpS:=format('%-'+IntTostr(AField^.FLength)+'s',[FieldText]);
                          n:=UniqueList.IndexOf(tmpS);
                          IF n=-1 THEN UniqueList.AddObject(tmpS,TObject(1))
                          ELSE UniqueList.Objects[n]:=TObject(Integer(UniqueList.Objects[n])+1);
                          IF (AField^.FeltType=ftInteger) or (AField^.FeltType=ftFloat) THEN
                            BEGIN
                              TRY
                                tmpValue:=eStrToFloat(FieldText);
                                IF tmpValue<MinValue THEN MinValue:=tmpValue;
                                IF tmpValue>MaxValue THEN MaxValue:=tmpValue;
                                sumX:=sumX+tmpValue;
                                sumXsqr:=sumXsqr+(tmpValue*tmpValue);
                              EXCEPT
                                INC(NoMissing);
                              END;  //try..except
                            END;  //if numeric
                          IF (Afield^.FeltType in [ftDate,ftEuroDate,ftYMDDate,
                            ftToday,ftEuroToday,ftYMDToday]) THEN   //&&
                          //(Afield^.FeltType=ftDate) or (AField^.FeltType=ftEuroDate)
                          //or (AField^.FeltType=ftToday)  or (AField^.Felttype=ftEuroToday) THEN
                            BEGIN
                              tmpValue:=mibStrToDate(FieldText,AField^.Felttype);
                              IF tmpValue<MinValue THEN MinValue:=tmpValue;
                              IF tmpValue>MaxValue THEN MaxValue:=tmpValue;
                            END;  //if date field
                          IF (AField^.FeltType=ftAlfa) OR (AField^.FeltType=ftUpperAlfa)
                            OR (AField^.FeltType=ftCrypt) THEN
                            BEGIN
                              IF ExampleCounter<5 THEN
                                BEGIN
                                  INC(ExampleCounter);
                                  Examples[ExampleCounter]:=FieldText;
                                END;
                            END;  //if text field
                        END;  //if not missing
                    END;  //Not Deleted and ftInteger

                END;  //for CurRec
              IF MinValue=MaxNumber THEN MinValue:=0;
              IF MaxValue=MinNumber THEN MaxValue:=0;
              tmpS:=IntToStr(NoMissing)+'/'+IntToStr(UnDeletedRecs);
              tmpS2:='';
              FOR n:=1 TO 6 DO
                IF MissCount[n].count>0 THEN tmpS2:=tmpS2+'  '+MissCount[n].MissText+': '+IntToStr(MissCount[n].Count);
              IF tmpS2<>'' THEN tmpS2:='  ('+trim(tmpS2)+')';
              tmpS:=tmpS+tmpS2;
              Lin.Append(Format('     %18s:  %-s',[Lang(20838),tmpS]));    //'missing'
              CASE AField^.FeltType OF
                ftInteger:
                  Lin.Append(Format('     %18s:  %-s',[Lang(20840),   //'range'
                  '['+IntToStr(Round(MinValue))+' ; '+IntToStr(Round(MaxValue))+']']));
                ftFloat:
                  BEGIN
                    TmpS:=Format('%'+IntToStr(AField^.FLength)+'.'+IntToStr(AField^.FNumDecimals)+'f',[MinValue]);
                    TmpS2:=Format('%'+IntToStr(AField^.FLength)+'.'+IntToStr(AField^.FNumDecimals)+'f',[MaxValue]);
                    TmpS:=trim(TmpS);
                    TmpS2:=trim(TmpS2);
                    Lin.Append(Format('     %18s:  %-s',[Lang(20840),'['+TmpS+' ; '+tmpS2+']']));  //'range'
                  END;
                ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday:   //&&
                  BEGIN
                    tmpS:=mibDateToStr(MinValue,AField^.Felttype);
                    tmpS2:=mibDateToStr(MaxValue,AField^.Felttype);
                    Lin.Append(Format('     %18s:  %-s',[Lang(20840),'['+TmpS+' ; '+tmpS2+']']));  //'range'
                  END;
                END;
              Lin.Append(Format('     %18s:  %-s',[Lang(20842),IntToStr(UniqueList.Count)]));   //'unique values'

              {Make frequency table for integer, float (0 dec.), boolean}
              IF (AField^.FCommentLegalRec<>NIL)
              OR (AField^.Felttype=ftBoolean)
              OR ((AField^.FeltType=ftInteger) AND (UniqueList.Count<=15))
              OR ((AField^.FeltType=ftFloat) AND (AField^.FNumDecimals=0) AND (UniqueList.Count<=15))
              OR (AField^.FeltType in [ftAlfa,ftUpperAlfa,ftSoundex]) THEN
                BEGIN
                  IF (UniqueList.Count<=15) OR (Afield^.FCommentLegalRec<>NIL) THEN
                    BEGIN
                      Lin.Append('');
                      LongestUnique:=0;
                      FOR n:=0 TO UniqueList.Count-1 DO
                        IF Length(trim(UniqueList[n]))>LongestUnique
                        THEN LongestUnique:=Length(trim(UniqueList[n]));
                      IF LongestUnique<6 THEN LongestUnique:=6;
                      IF LongestUnique>20 THEN LongestUnique:=20;
                      FormStr:='     %18s:  %6s  %6s  %-'+IntToStr(LongestUnique)+'s  %-s';
                      Lin.Append(Format(FormStr,[Lang(20844),Lang(20846),Lang(20848),Lang(20850),Lang(20852)]));
                      {20844=tabulation
                      20846=Freq.
                      20848=Pct.
                      20850=Value
                      20852=Label}
                      FormStr:='     %18s  %6d  %6s  %'+IntToStr(LongestUnique)+'s  %-s';
                      FOR n:=0 TO UniqueList.Count-1 DO
                        BEGIN
                          tmpValue:=(Integer(UniqueList.Objects[n])/UnDeletedRecs)*100;
                          //Str(tmpValue:5:1,tmpS);
                          tmpS:=Format('%5.1f',[tmpValue]);
                          IF AField^.FCommentLegalRec<>NIL
                          THEN tmpS2:=GetCommentLegalText(UniqueList[n],AField^.FCommentLegalRec)
                          ELSE tmpS2:='';
                          IF AField^.Felttype=ftBoolean THEN
                            BEGIN
                              IF UniqueList[n]='N' THEN tmpS2:=Lang(20212);  //'No'
                              IF UniqueList[n]='Y' THEN tmpS2:=Lang(20210);  //'Yes'
                              IF trim(UniqueList[n])='.' THEN tmpS2:=Lang(20838);  //'Missing'
                            END;
                          tmpS3:=trim(UniqueList[n]);
                          IF Length(tmpS3)>20 THEN tmpS3:=Copy(tmpS3,1,18)+'..';
                          Lin.Append(Format(FormStr,['',Integer(UniqueList.Objects[n]),
                          tmpS,tmpS3,tmpS2]));
                        END;  //for n
                    END  //if max 10 unique values
                  ELSE IF (ExampleCounter>0) THEN
                    BEGIN
                      //Field should have freq-table but has more than 10 unique values
                      Lin.Append('');
                      FormStr:='      %18s  %-s';
                      FOR n:=1 TO ExampleCounter DO
                        IF n=1 THEN Lin.Append(Format(FormStr,[Lang(20854),Examples[n]]))   //'Examples:'
                        ELSE Lin.Append(Format(FormStr,['',Examples[n]]));
                    END;
                END;  //if freq.table should be made

              {Calulate mean and standard diviation for ftFloat (>0 decimals)}
              IF (AField^.FCommentLegalRec=NIL)
              AND (  ((AField^.Felttype=ftFloat) AND (AField^.FNumDecimals>0))
                 OR  ((AField^.Felttype in [ftFloat,ftInteger]) AND (UniqueList.Count>10))  ) THEN
                BEGIN
                  Lin.Append('');
                  try
                    NoNotMissing:=UnDeletedRecs-NoMissing;
                    tmpValue:=((NoNotMissing*SumXsqr)-(SumX*SumX)) / (NoNotMissing*NoNotMissing);
                    tmpValue:=Sqrt(tmpValue);
                    MeanValue:=SumX/NoNotMissing;
                    FormStr:='     %18s:  %-.4f';    //'+IntToStr(AField^.FNumDecimals)+'f';
                    Lin.Append(Format(FormStr,[Lang(20856),MeanValue]));  //'mean'
                    Lin.Append(Format(Formstr,[Lang(20858),tmpValue]));   //'std. dev'
                  Except
                    Lin.Append(Format('     %18s:  %-s',[Lang(20856),'n/a']));
                    Lin.Append(Format('     %18s:  %-s',[Lang(20858),'n/a']));
                  END;
                END;  //if floating point

              Lin.Append('');

            END;  //if felttype<>ftQuestion

          Application.ProcessMessages;
          IF UserAborts THEN
            BEGIN
              IF eDlg(Lang(20860),mtConfirmation,[mbYes,mbNo],0)=mrYes  //'Abort codebook?'
              THEN Exit
              ELSE UserAborts:=False;
            END;  //if UserAborts

        END;  //for Curfield
    FINALLY
      EnableTaskWindows(WindowList);
      ProgressForm.Free;
      Dispose(CharPointer);
      UniqueList.Free;
    END;

    IF Length(Lin.Text)>65500 THEN
      BEGIN
        tmpS:=ExtractFileDir(ParamStr(0))+'\~EpdLog';
        n:=1;
        WHILE FileExists(tmpS+IntToStr(n)+'.tmp') DO INC(n);
        tmpS:=tmpS+IntToStr(n)+'.tmp';
//        tmpS2:=ChangeFileExt(df^.RECFilename,'.Log');
        Lin.SaveToFile(tmpS);
        AEdForm:=TEdForm.Create(MainForm);
        WITH AEdForm DO
          BEGIN
            Open(tmpS);
            CloseFile(BlockFile);
            PathName:=DefaultFilename+IntToStr(WindowNum);
            Caption:=Format(Lang(20862),[ExtractFilename(df^.RECFilename)]);  //'Codebook based on %s'
            MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
              IndexOfObject(TObject(AEdForm))]:=DefaultFilename+IntToStr(WindowNum);
            FormType:=ftDocumentation;
            Ed.Font.Assign(epiDocuFont);
            Ed.SelStart:=0;
            Ed.Modified:=True;
          END;  //with
        tmpBool:=DeleteFile(tmpS);
      END
    ELSE
      BEGIN
        Screen.Cursor:=crHourGlass;
        LockWindowUpdate(MainForm.Handle);
        AEdForm:=TEdForm.Create(Self);
        WITH AEdForm DO
          BEGIN
            FormType:=ftDocumentation;
            Caption:=Format(Lang(20862),[df^.RECFilename]);   //'Codebook based on %s'
            Ed.Font.Assign(epiDocuFont);
            Ed.Color:=DocuColor;
            Ed.ScrollBars:=ssBoth;
            Ed.Lines.Capacity:=Lin.Count;
            Ed.Lines.Assign(Lin);
            Ed.ScrollBars:=ssBoth;
            Ed.SelStart:=0;
          END;
//        MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
//        IndexOfObject(TObject(AEdForm))]:=ExtractFilename(AEdForm.PathName);
      END;
  FINALLY
    LockWindowUpDate(0);
    DecimalSeparator:=OldDecimalSep;
    Screen.Cursor:=crDefault;
    Lin.Free;
    R.Free;
    DisposeDatafilePointer(df);
  END;  //try..finally
end;

Function TMainForm.DoRevisedatafile(NameOfNewQesFile, NameOfOldRecFile:string):Boolean;
VAR
  NewDf,OldDf:        PDatafileInfo;
  t,n:                Integer;
  QESLines:           TStringList;
  Mess,tmpS:          String;
  F,OldRecFile,NewRecFile:       TextFile;
  tmpBool,
  ok,
  OK2looseDecimals:   Boolean;
  CurField:           Integer;
  CurRec:             Longint;
  OldField,NewField:  PeField;
  ft:                 TFeltTyper;
  OldRecFilename:     TFilename;
  WindowList:         Pointer;
  TempNum:            Double;
  tmpDate:            TDateTime;
  oldHasPW:           Boolean;
BEGIN
  Result:=False;
  Olddf:=NIL;
  Newdf:=NIL;
  TRY
    IF (NOT GetDatafilePointer(Olddf)) OR (NOT GetDatafilePointer(Newdf)) THEN
      BEGIN
        DisposeDatafilePointer(Olddf);
        DisposeDatafilePointer(Newdf);
        Exit;
      END;

    Newdf^.QESFileName:=NameOfNewQesFile;
    Olddf^.RECFilename:=NameOfOldRecFile;
    Newdf^.RECFilename:=ChangeFileExt(olddf^.RECFilename,'.re$');
    AddToRecentFiles(Olddf^.RECFilename);

    TRY
      QESLines:=TStringList.Create;
      TRY
        QESLines.LoadFromFile(Newdf^.QESFilename);
        mess:=QESLines.Text;
      EXCEPT
        ErrorMsg(Format(Lang(20406),[Newdf^.QESFilename]));  //'QES-file %s cannot be found or opened.'
        DisposeDatafilePointer(Newdf);
        DisposeDatafilePointer(Olddf);
        Exit;
      END;  //try..Except
    FINALLY
      QESLines.Free;
    END;  //try..except

    IF NOT FileExists(Olddf^.RECFilename) THEN
      BEGIN
        ErrorMsg(Format(Lang(20110),[Olddf^.RECFilename]));  //Datafile %s does not exist.
        DisposeDatafilePointer(Newdf);
        DisposeDatafilePointer(Olddf);
        Exit;
      END;

    TRY
      AssignFile(F,Olddf^.RECFilename);
      Reset(F);
      ReadLN(F,tmpS);
      CloseFile(F);
    EXCEPT
      ErrorMsg(Format(Lang(20108),[Olddf^.RECFilename])+#13+Lang(20208));   //Datafile %s could not be opened.+Please check if the file is in use and that the filename is legal.
      DisposeDatafilePointer(Newdf);
      DisposeDatafilePointer(Olddf);
      Exit;
    END;  //try..except

    n:=Pos('FILELABEL: ',AnsiUpperCase(tmpS));
    IF n<>0 THEN Newdf^.FileLabel:=Copy(tmpS,n+Length('FILELABEL: '),Length(tmpS))
    ELSE newdf^.FileLabel:='';
    IF Pos(' VLAB',tmpS)>0 THEN tmpBool:=False ELSE tmpBool:=True;
    Newdf^.EpiInfoFieldNaming:=tmpBool;
    IF tmpBool<>EpiInfoFieldNaming THEN
      BEGIN
        IF tmpBool THEN tmpS:=Format(Lang(20906),[Olddf^.RECFilename])  //The datafile %s was created with the option Automatic Fieldnaming, but the current settings in Options are Use First Word As Fieldname.
        +#13#13+Lang(20908)    //'Do you want to continue using Automatic Fieldnaming?'
        ELSE tmpS:=Format(Lang(20910),[Olddf^.RECFilename])    //'The datafile %s was created with the option Use First Word As Fieldname, but the current settings in options are Automatic Fieldnaming.'
        +#13#13+Lang(20912);    //'Do you want to continue using First Word As Fieldname?';
        CASE eDlg(tmpS,mtConfirmation,[mbYes,mbNo,mbCancel,mbHelp],120) OF
          mrYes: newdf^.EpiInfoFieldNaming:=tmpBool;
          mrNo:  newdf^.EpiInfoFieldNaming:=NOT tmpBool;
          mrCancel:
            BEGIN
              DisposeDatafilePointer(newdf);
              DisposeDatafilePointer(Olddf);
              Exit;
            END;
        END;  //case
      END;  //if tmpBool<>EpiInfoFieldNaming

    CreatingFromQesFile:=True;
    IF TranslateQes(newdf,mess)=False THEN
      BEGIN
        CreatingFromQesFile:=False;
        LockWindowUpdate(MainForm.Handle);
        TRY
          RapForm:=TEdform.Create(MainForm);
          RapFormCreated:=TRUE;
          RapForm.Caption:=Lang(20412);   //'Error log';
          RapForm.Ed.Text:=Mess;
          RapForm.Ed.Modified:=FALSE;
        EXCEPT
          RapForm.Free;
          RapFormCreated:=FALSE;
        END;  //try..except
        LockWindowUpdate(0);
        DisposeDatafilePointer(newdf);
        DisposeDatafilePointer(Olddf);
        Exit;
      END;  //if errors in qes-file
    CreatingFromQesFile:=False;

    IF newdf^.NumFields=0 THEN
      BEGIN
        ErrorMsg(Format(Lang(20414),[newdf^.QESFileName])); //The QES-file %s does not contain any entryfields.~~Datafile is not created.
        DisposeDatafilePointer(newdf);
        DisposeDatafilePointer(Olddf);
        Exit;
      END;

    //Open oldDf now to get the encryptionpassword, if present
    IF NOT PeekDatafile(Olddf) THEN
      BEGIN
        DisposeDatafilePointer(olddf);
        DisposeDatafilePointer(newdf);
        Exit;
      END;
    newdf^.Key:=olddf^.Key;


    IF FileExists(newdf^.RECFilename) THEN tmpBool:=DeleteFile(newdf^.RECFilename);
    IF NOT PeekCreateDataFile(newdf) THEN
      BEGIN
        ErrorMsg(Format(Lang(20416),[newdf^.RECFilename])  //The datafile with the name %s cannot be created.
        +#13#13+Lang(20206));   //Please check if the filename is legal or if the disk is writeprotected or full.
        tmpBool:=DeleteFile(newdf^.RECFilename);
        DisposeDatafilePointer(newdf);
        DisposeDatafilePointer(Olddf);
        Exit;
      END;
  EXCEPT
    DisposeDatafilePointer(newdf);
    DisposeDatafilePointer(Olddf);
    Exit;
  END;



{  IF Olddf^.HasLongFieldnames THEN
    BEGIN
      ErrorMsg(Format(Lang(20914),[Olddf^.RECFilename])  //'The datafile %s was created with Epi Info and has one or more fieldnames with a length larger than 8 characters.'
      +#13#13+Lang(20916));  //'EpiData cannot revise the structure of such files - please use Epi Info instead.'
      {$I-}
      //CloseFile(newdf^.datfile);
{      newdf^.Datfile.Free;  //§§§
      newdf^.Datfile:=NIL;  //§§§
      n:=IOResult;
      {$I+}
{      tmpBool:=DeleteFile(NewDf^.RECFilename);
      DisposeDatafilePointer(olddf);
      DisposeDatafilePointer(newdf);
      Exit;
    END;
}

  {Test if fields are compatible}
  OK2looseDecimals:=False;
  FOR CurField:=0 TO newdf^.FieldList.Count-1 DO
    BEGIN
      NewField:=PeField(newdf^.FieldList.Items[CurField]);
      NewField^.FieldN:=-1;
      IF NewField^.Felttype<>ftQuestion THEN
        BEGIN
          n:=GetfieldNumber(NewField^.FName,oldDf);
          NewField^.FieldN:=n;
          IF n=-1 THEN Oldfield:=NIL
          ELSE OldField:=PeField(olddf^.FieldList.Items[n]);
          //OldField:=GetField(NewField^.FName,Olddf);
          ok:=False;
          IF OldField<>NIL THEN IF OldField^.FeltType<>ftQuestion THEN ok:=True;
          IF ok THEN
            BEGIN
              {fieldname in new recfile exists in old recfile}
              ok:=False;
              ft:=NewField^.FeltType;
              CASE OldField^.FeltType OF
                ftIDNUM:      IF (ft=ftInteger) OR (ft=ftFloat)   THEN ok:=True;
                ftUpperAlfa:  IF (ft=ftAlfa) or (ft=ftCrypt)      THEN ok:=True;  //&&
                ftFloat:      IF (ft=ftInteger) or (ft=ftIDNUM) THEN ok:=True;
                ftInteger:    IF (ft=ftFloat)   or (ft=ftIDNUM) THEN ok:=True;
                ftBoolean:    IF (ft=ftInteger) or (ft=ftFloat) THEN ok:=True;  //MIB131205
                ftDate,ftToday,
                ftEuroDate, ftYMDDate,ftYMDToday,    //&&
                ftEuroToday:  ok:=(ft in [ftDate,ftToday,ftEuroDate,ftEuroToday,ftYMDDate,ftYMDToday]);  //&&
              END;
              IF (ft=ftAlfa) or (ft=ftUpperAlfa) or (ft=ftCrypt) THEN ok:=True;
              IF (ft=ftIDNUM) THEN
                BEGIN
                  IF OldField^.Felttype=ftInteger THEN ok:=True;
                  IF (OldField^.FeltType=ftFloat) AND (OldField^.FNumDecimals=0) THEN ok:=True;
                END;
              IF OldField^.FeltType=ft THEN ok:=True;

              IF (ok) AND (OK2looseDecimals=False) AND (NewField^.FNumDecimals<OldField^.FNumDecimals) THEN
                BEGIN
                  OK2looseDecimals:=True;
                  IF WarningDlg(Format(
                  Lang(20938)+    //'The field %s in the revised QES-file only has %d decimals while the same field in the datafile has %d decimals'
                  #13#13+Lang(20940),[NewField^.FName,NewField^.FNumDecimals,OldField^.FNumDecimals]))=mrCancel THEN  //'This could lead to a loss of data.'
                    BEGIN
                      tmpBool:=DeleteFile(newdf^.RECFilename);
                      DisposeDatafilePointer(olddf);
                      DisposeDatafilePointer(newdf);
                      Exit;
                    END;
                END;  //if NewField has less decimals than OldField

              IF NOT ok THEN
                BEGIN
                  Screen.Cursor:=crDefault;
                  ErrorMsg(
                    Format(Lang(20926),[trim(NewField^.FName)])   //'A field with the name "%s" exists in both the old datafile and in the revised QES-file'
                    +Lang(20928)                              //'but the field are not compatible.'
                    +#13#13+Format(Lang(20930),[FieldTypeNames[ORD(OldField^.FeltType)],FieldTypeNames[ORD(ft)]])  //'Field type in datafile: %s~Field type in revised QES-file: %s'
                    +#13#13+Lang(20924) );   //Revise Datafile terminates.
                  tmpBool:=DeleteFile(newdf^.RECFilename);
                  DisposeDatafilePointer(olddf);
                  DisposeDatafilePointer(newdf);
                  Exit;
                END;

            END;  //if fieldname exists in both files
        END;  //if NewField<>ftQuestion
    END;  //for Curfield


  {Initialize inputfile}
  //CloseFile(olddf^.DatFile);
  olddf^.Datfile.Free;  //§§§
  olddf^.Datfile:=NIL;  //§§§
  AssignFile(OldRecFile,olddf^.RECFilename);
  Reset(OldRecFile);
  FOR n:=0 TO olddf^.FieldList.Count-1 DO
    BEGIN
      ReadLn(OldRecFile,tmpS);
      PeField(olddf^.FieldList.Items[n])^.FieldN:=0;
    END;
  ReadLn(OldRecFile,tmpS);
  {filepointer in ReadOnlyRecFile now points to first record}

  {Open outputfile}
  AssignFile(NewRecFile,newdf^.RECFilename);
  Append(NewRecFile);

  TRY
    IF olddf^.NumRecords>0 THEN
      BEGIN
        {Begin transferring records from old datafile to new datafile}
        TRY
          UserAborts:=False;
          ProgressForm:=TProgressForm.Create(MainForm);
          ProgressForm.Caption:=Lang(20918);   //'Transferring data'
          ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
          ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
          WITH ProgressForm.pBar DO BEGIN
            IF Olddf^.NumRecords>2 THEN Max:=olddf^.NumRecords-2 ELSE Max:=2;
            Position:=0;
          END;  //with
          WindowList:=DisableTaskWindows(ProgressForm.Handle);
          ProgressForm.Show;

          OK2looseDecimals:=False;
          FOR CurRec:=1 TO olddf^.NumRecords DO
            BEGIN
              IF ProgressStep(OldDf^.NumRecords,CurRec) THEN
                BEGIN
                  ProgressForm.pBar.Position:=CurRec;
                  ProgressForm.pLabel.Caption:=Format(' '+Lang(20942),[CurRec,olddf^.NumRecords]);  //'Writing record no. %d of %d'
                  Application.ProcessMessages;
                END;
              eReadOnlyNextRecord(olddf,OldRecFile);
              FOR CurField:=0 TO newdf^.FieldList.Count-1 DO
                BEGIN
                  NewField:=PeField(newdf^.FieldList.Items[CurField]);
                  IF NewField^.Felttype<>ftQuestion THEN
                    BEGIN
                      //OldField:=GetField(NewField^.FName,Olddf);
                      IF NewField^.FieldN=-1 THEN OldField:=NIL
                      ELSE OldField:=PeField(olddf^.FieldList.Items[NewField^.FieldN]);
                      ok:=False;
                      IF OldField<>NIL THEN IF OldField^.FeltType<>ftQuestion THEN ok:=True;
                      IF ok THEN
                        BEGIN
                          {fieldname in new recfile exists in old recfile}

                          IF ok THEN
                            BEGIN
                              {new and old field are of the same type}
                              ft:=NewField^.FeltType;
                              tmpS:=trim(OldField^.FFieldText);
                              if (OldField^.Felttype=ftBoolean) AND (ft in [ftInteger,ftFloat]) AND (tmpS<>'') THEN tmpS:=inttostr(ord(tmpS='Y'));  //MIB131205
                              IF (ft=ftFloat) THEN
                                BEGIN
                                  IF (tmpS<>'') AND (NewField^.FNumDecimals>OldField^.FNumDecimals) THEN
                                    BEGIN
                                      IF OldField^.FNumDecimals=0 THEN tmpS:=tmpS+'.';
                                      tmpS:=tmpS+cFill('0',NewField^.FNumDecimals-OldField^.FNumDecimals);
                                    END;
                                END;
                              IF (tmpS<>'') AND (NewField^.FNumDecimals<OldField^.FNumDecimals) THEN
                                BEGIN
                                  TRY
                                    FOR n:=1 TO Length(tmpS) DO
                                      BEGIN
                                        IF tmpS[n]='.' THEN tmpS[n]:=DecimalSeparator;
                                        IF tmpS[n]=',' THEN tmpS[n]:=DecimalSeparator;
                                      END;
                                    TempNum:=StrToFloat(tmpS);
                                    Str(TempNum:NewField^.FLength:NewField^.FNumDecimals,tmpS);
                                  EXCEPT
                                    ErrorMsg(Format(Lang(20944),[CurRec,NewField^.FName]));  //'A non-valid fixed decimal number was found in record %d, field %s'
                                    CloseFile(OldRecFile);
                                    CloseFile(NewRecFile);
                                    tmpBool:=DeleteFile(newdf^.RECFilename);
                                    DisposeDatafilePointer(olddf);
                                    DisposeDatafilePointer(newdf);
                                    Exit;
                                  END;
                                END;
                              IF (tmpS<>'') AND (ft in [ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday])  //&&
                              AND (ft<>OldField^.Felttype) THEN
                                BEGIN
                                  tmpDate:=mibStrToDate(tmpS,OldField^.Felttype);
                                  tmpS:=mibDateToStr(tmpDate,NewField^.Felttype);
                                END;  //if datefields
                              IF Length(tmpS)>NewField^.FLength THEN
                                BEGIN
                                  {Data does not fit in new field length}
                                  Screen.Cursor:=crDefault;
                                  ErrorMsg(OldDf^.RECFilename+#13#13
                                   +Format(Lang(20922),[CurRec,trim(NewField^.FName)])  //The revised QES-file would lead to loss of data in record no. %d, field %s
                                   +#13#13+Lang(20924));   //'Revise Datafile terminates.'
                                  CloseFile(OldRecFile);
                                  CloseFile(NewRecFile);
                                  tmpBool:=DeleteFile(newdf^.RECFilename);
                                  DisposeDatafilePointer(olddf);
                                  DisposeDatafilePointer(newdf);
                                  Exit;
                                END
                              ELSE
                                BEGIN
                                  {copy data from old datafile to new datafile}
                                  IF ft=ftUpperAlfa THEN tmpS:=AnsiUpperCase(tmpS);
                                  NewField^.FFieldText:=tmpS;
                                  OldField^.FieldN:=1;
                                END;
                            END  //if fields have the same field type
                          ELSE
                            BEGIN
                              Screen.Cursor:=crDefault;
                              ErrorMsg(
                                Format(Lang(20926),[trim(NewField^.FName)])   //'A field with the name "%s" exists in both the old datafile and in the revised QES-file'
                                +Lang(20928)                              //'but the field are not compatible.'
                                +#13#13+Format(Lang(20930),[FieldTypeNames[ORD(OldField^.FeltType)],FieldTypeNames[ORD(ft)]])  //'Field type in datafile: %s~Field type in revised QES-file: %s'
                                +#13#13+Lang(20924) );   //Revise Datafile terminates.

                              CloseFile(OldRecFile);
                              CloseFile(NewRecFile);
                              tmpBool:=DeleteFile(newdf^.RECFilename);
                              DisposeDatafilePointer(olddf);
                              DisposeDatafilePointer(newdf);
                              Exit;
                            END;
                        END  //if fieldname in new recfile exists in old recfile
                      ELSE
                        BEGIN
                          {New field does not exist in old recfile}
                          NewField^.FFieldText:='';
                          IF NewField^.FeltType=ftIDNUM
                          THEN NewField^.FFieldText:=IntToStr(FirstIDNumber+CurRec-1);
                        END;
                    END; //if Felttype<>ftQuestion
                END;  //for CurField
              NewDf^.CurRecDeleted:=OldDf^.CurRecDeleted;
              WriteNextRecord(newdf,NewRecFile);
              //Application.ProcessMessages;
              IF UserAborts THEN
                BEGIN
                  IF eDlg(Lang(20932),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort Revise Datafile?'
                  THEN
                    BEGIN
                      CloseFile(OldRecFile);
                      CloseFile(NewRecFile);
                      tmpBool:=DeleteFile(newdf^.RECFilename);
                      Exit;
                    END
                  ELSE UserAborts:=False;
                END;  //if UserAborts

            END;  //for CurRec
          FINALLY
            EnableTaskWindows(WindowList);
            ProgressForm.Free;
          END;  //try..Finally
      END;  //if olddf^.NumRecords>0
    Screen.Cursor:=crDefault;
    tmpS:='';
    IF olddf^.NumRecords>0 THEN
      BEGIN
        FOR n:=0 TO olddf^.FieldList.Count-1 DO
          BEGIN
            OldField:=PeField(olddf^.FieldList.Items[n]);
            IF (OldField^.FeltType<>ftQuestion) AND (OldField^.FieldN=0)
            THEN tmpS:=tmpS+trim(OldField^.FName)+', ';
          END;
      END;
    ok:=True;
    IF tmpS<>'' THEN
      BEGIN
        tmpS:=Copy(tmpS,1,Length(tmpS)-2);
        //IF eDlg(olddf^.RECFilename+':'+#13#13
        //+Lang(20934)     //'The revised QES-file will lead to loss of the data in these fields:'
        //+#13#13+tmpS,mtWarning, [mbAbort,mbIgnore],0)=mrAbort THEN
        IF WarningDlg(olddf^.RECFilename+':'+#13#13+Lang(20934)  //'The revised QES-file will lead to loss of the data in these fields:'
        +#13#13+tmpS)=mrCancel THEN
          BEGIN
            ok:=False;
            CloseFile(OldRecFile);
            CloseFile(NewRecFile);
            tmpBool:=DeleteFile(newdf^.RECFilename);
          END;
      END;
    IF ok THEN
      BEGIN
        CloseFile(OldRecFile);
        CloseFile(NewRecFile);
        olddf^.IndexFilename:=ChangeFileExt(olddf^.RECFilename,'.eix');
        IF (FileExists(olddf^.IndexFilename)) THEN tmpBool:=Deletefile(olddf^.IndexFilename);
        OldRecFilename:=ChangeFileExt(olddf^.RECFilename,'')+'.old.rec';
        IF FileExists(OldRecFilename) THEN tmpBool:=Deletefile(OldRecFilename);
        Rename(OldRecFile,OldRecFilename);
        Rename(NewRecFile,OldDf^.RECFilename);
        eDlg(Format(Lang(20936),[olddf^.RECFilename,OldRecFilename]),  //'The revised datafile %s has been created.~~The original datafile has been renamed to %s'
        mtInformation,[mbOK],0);
        Result:=True;
      END;
  FINALLY
    DisposeDatafilePointer(olddf);
    DisposeDatafilePointer(newdf);
  END;
END;

procedure TMainForm.RevisedatafilefromrevisedQESfile1Click(Sender: TObject);
VAR
  newqesfilename,oldrecfilename: String;
  t:Integer;
begin
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles-1 THEN
    BEGIN
      ErrorMsg(Format(lang(20102),    //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      Exit;
    END;
  t:=1;
  WHILE (t<8) AND
    (AnsiUpperCase(ExtractFileExt(RecentFiles[t]))<>'.QES') DO INC(t);

  SelectFilesForm:=TSelectFilesForm.Create(MainForm);
  WITH SelectFilesForm DO
    BEGIN
      Caption:=Lang(20900);    //'Revise datafile from revised QES-file'
      Ext1:='.qes';
      Ext2:='.rec';
      File1Label.Caption:=Lang(20902);   //'Name of revised QES-file'
      File2Label.Caption:=lANG(20904);   //'Datafile to revise'
      UpdateFile2Text:=True;
      IF LastSelectFilestype=sfRevise THEN
        BEGIN
          File1Edit.Text:=LastSelectFile1;
          File2Edit.Text:=lastSelectFile2;
        END
      ELSE
        BEGIN
          IF AnsiUpperCase(ExtractFileExt(RecentFiles[t]))='.QES'
          THEN File1Edit.Text:=RecentFiles[t] ELSE File1Edit.Text:='';
        END;
    END;  //with
  IF SelectFilesForm.ShowModal<>mrOK THEN
    BEGIN
      SelectFilesForm.Free;
      Exit;
    END;

  LastSelectFilestype:=sfRevise;
  LastSelectFile1:=SelectFilesForm.File1Edit.Text;
  LastSelectFile2:=SelectFilesForm.File2Edit.Text;

  newqesfilename:=SelectFilesForm.File1Edit.Text;
  oldrecfilename:=SelectFilesForm.File2Edit.Text;
  SelectFilesForm.Free;

  DoReviseDatafile(newqesfilename,oldrecfilename);
END;


procedure TMainForm.Aboutregistration1Click(Sender: TObject);
begin
  Application.HelpContext(130);
end;

procedure TMainForm.Registeronline1Click(Sender: TObject);
begin
  ExecuteFile('http://www.epidata.dk/register.htm',
  '', ExtractFileDir(ParamStr(0)), SW_SHOW);
end;

procedure TMainForm.Validate1Click(Sender: TObject);
begin
  DoValidate;
end;

procedure TMainForm.Copydatafilestructure1Click(Sender: TObject);
VAR
  n,n2:Integer;
  HeaderLine,tmpS,OldRecFileKey: String;
  tmpBool:Boolean;
  OldRec: TextFile;
  NumFields,NewRecNumFields: Integer;
  OldRecHasEpiInfoNaming:Boolean;
  RecLines: TStringList;
begin
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),    //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      MakeDatafileBtn.Down:=False;
      Exit;
    END;
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  tmpS:=OpenDialog1.Title;
  OpenDialog1.Title:=Lang(21000);   //'Select datafile to copy'
  tmpBool:=OpenDialog1.Execute;
  OpenDialog1.Title:=tmpS;
  IF NOT tmpBool THEN Exit;
  TRY
    AssignFile(OldRec,OpenDialog1.Filename);
    Reset(OldRec);
  EXCEPT
    ErrorMsg(Format(Lang(20108),[OpenDialog1.Filename])   //Datafile %s could not be opened.
      +#13+Lang(20208));  //Please check if the file is in use and that the filename is legal.
    Exit;
  END;
  AddToRecentFiles(OpenDialog1.Filename);
  TRY
    CopyDatafileForm:=TCopyDatafileForm.Create(MainForm);
  EXCEPT
    CopyDatafileForm.Free;
    ErrorMsg(Format(Lang(20204),[921]));  //Out of memory (reference code %d)
    CloseFile(OldRec);
    Exit;
  END;
  ReadLn(OldRec,HeaderLine);
  tmpS:=COPY(HeaderLine,1,POS(' ',HeaderLine)-1);
  IF IsInteger(tmpS) THEN NumFields:=StrToInt(tmpS)
  ELSE
    BEGIN
      CloseFile(OldRec);
      ErrorMsg(Format(Lang(20112),[OpenDialog1.Filename]));  //'Incorrect format of datafile %s.'
      CopyDatafileForm.Free;
      Exit;
    END;
  CopyDatafileForm.OldRecFilenameLabel.Caption:=OpenDialog1.Filename;
  CopyDatafileForm.NewRecFilenameEdit.Text:=ExtractFileDir(OpenDialog1.Filename)+'\';

  OldRecfileKey:='';
  n:=pos('~kq:',HeaderLine);
  IF n>0 THEN
    BEGIN
      //Datafile contains a crypt-key
      n2:=pos(':kq~',HeaderLine);
      IF (n2>0) AND (n2>n) THEN OldRecfileKey:=copy(HeaderLine,n+4,n2-n-4);
    END;

  n:=Pos('FILELABEL: ',AnsiUpperCase(HeaderLine));
  IF n<>0 THEN
    BEGIN
      CopyDatafileForm.OldRecDatafileLabel.Caption:=Copy(HeaderLine,n+Length('FILELABEL: '),Length(HeaderLine));
      CopyDatafileForm.NewRecDatafileLabel.Text:=CopyDatafileForm.OldRecDatafileLabel.Caption;
    END
  ELSE
    BEGIN
      CopyDatafileForm.OldRecDatafileLabel.Caption:=Lang(20604);   //'[none]'
      CopyDatafileForm.NewRecDatafileLabel.Text:='';
    END;
  IF Pos(' VLAB',HeaderLine)>0 THEN OldRecHasEpiInfoNaming:=False ELSE OldRecHasEpiInfoNaming:=True;
  IF NOT FileExists(ChangeFileExt(OpenDialog1.Filename,'.chk')) THEN
    BEGIN
      CopyDatafileForm.DoCopyCheckFile.Checked:=False;
      CopyDatafileForm.DoCopyCheckFile.Enabled:=False;
    END;
  IF CopyDatafileForm.ShowModal=mrOK THEN
    BEGIN
      RecLines:=TStringList.Create;
      RecLines.Append(HeaderLine);
      NewRecNumFields:=0;
      FOR n:=1 TO NumFields DO
        BEGIN
          ReadLn(OldRec,tmpS);
          IF IsInteger(Copy(tmpS,33,4)) THEN n2:=StrToInt(Trim(Copy(tmpS,33,4))) ELSE n2:=0;
          tmpBool:=CopyDatafileForm.DontCopyTextFields.Checked;
          IF (NOT tmpBool) OR
          (  (tmpBool) AND (n2<>ORD(ftAlfa)) AND (n2<>ORD(ftUpperAlfa)) ) THEN
            BEGIN
              INC(NewRecNumFields);
              RecLines.Append(tmpS);
            END;  //if
        END;  //for
      tmpS:=IntToStr(NewRecNumFields)+' 1';
      IF (NOT OldRecHasEpiInfoNaming) THEN tmpS:=tmpS+' VLAB';
      IF OldRecfileKey<>'' THEN tmpS:=tmpS+' ~kq:'+OldRecfileKey+':kq~';
      IF trim(CopyDatafileForm.NewRecDatafileLabel.Text)<>''
      THEN tmpS:=tmpS+' Filelabel: '+CopyDatafileForm.NewRecDatafileLabel.Text;
      RecLines[0]:=tmpS;
      IF CopyDatafileForm.DoCopyCheckFile.Checked THEN
        BEGIN
          TRY
            CopyFile(ChangeFileExt(OpenDialog1.Filename,'.chk'),
            ChangeFileExt(CopyDatafileForm.NewRecFilenameEdit.Text,'.chk'));
          EXCEPT
            eDlg(format(Lang(21002),    //'The checkfile %s could not be copied'
            [ChangeFileExt(CopyDatafileForm.NewRecFilenameEdit.Text,'.chk')]),
            mtWarning,[mbOK],0);
          END;  //try..Except
        END;  //if
      TRY
        RecLines.SaveToFile(CopyDatafileForm.NewRecFilenameEdit.Text);
        AddToRecentFiles(CopyDatafileForm.NewRecFilenameEdit.Text);
        eDlg(Format(Lang(21004),     //'Datafile %s has been copied to %s'
        [OpenDialog1.Filename,CopyDatafileForm.NewRecFilenameEdit.Text]),
        mtInformation,[mbOK],0);
      EXCEPT
        ErrorMsg(Format(Lang(21006),    //'Error saving the new datafile with the name %s'
        [CopyDatafileForm.NewRecFilenameEdit.Text]));
      END;
      RecLines.Free;
    END;  //if showModal
  CloseFile(OldRec);
  CopyDatafileForm.Free;
end;

procedure TMainForm.Rebuildindex1Click(Sender: TObject);
VAR
  tmpStr:String;
  tmpBool:Boolean;
  df:PDatafileInfo;
begin
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),    //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      MakeDatafileBtn.Down:=False;
      Exit;
    END;
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  tmpStr:=OpenDialog1.Title;
  OpenDialog1.Title:=Lang(21100);    //'Select datafile to rebuild index for'
  tmpBool:=OpenDialog1.Execute;
  OpenDialog1.Title:=tmpStr;
  IF NOT tmpBool THEN Exit;
  IF NOT GetDatafilePointer(df) THEN Exit;
  df^.QESFileName:='';
  df^.RECFilename:=OpenDialog1.Filename;
  AddToRecentFiles(df^.RecFilename);
  IF DoRebuildIndex(df) THEN
    eDlg(format(Lang(21106),[df^.RECFilename]),mtInformation,[mbOK],0);  //Index for %s has been rebuilt
  DisposeDatafilePointer(df);
end;




procedure TMainForm.Packdatafile1Click(Sender: TObject);
VAR
  df:PDatafileInfo;
  n,CurRec,NumFields,NumDeleted: Integer;
  s,tmpS: String;
  OldRec,NewRec: TextFile;
  NewRecFilename,BakRecfilename: TFilename;
  tmpBool:Boolean;
begin
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),   //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      Exit;
    END;
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF NOT OpenDialog1.Execute THEN Exit;
  IF NOT GetDatafilePointer(df) THEN Exit;
  df^.QESFileName:='';
  df^.RECFilename:=OpenDialog1.Filename;
  AddToRecentFiles(df^.RECFilename);

  IF WarningDlg(Format(Lang(23200),[df^.RECFilename])+   //'This function will permanently remove the records in %s that are marked as deleted'
    #13#13+Lang(20452))=mrCancel THEN       //'Are you sure?' 
    BEGIN
      DisposeDatafilePointer(df);
      Exit;
    END;

  IF NOT PeekDatafile(df) THEN
    BEGIN
      DisposeDatafilePointer(df);
      Exit;
    END;

  TRY
    //CloseFile(df^.Datfile);
    df^.Datfile.Free;  //§§§
    df^.Datfile:=NIL;  //§§§
    AssignFile(OldRec,df^.RECFilename);
    Reset(OldRec);
  EXCEPT
    {$I-}
    CloseFile(OldRec);
    {$I+}
    ErrorMsg(Format(Lang(20108),[df^.RECFilename]));  //'Datafile %s could not be opened.'
    DisposeDatafilePointer(df);
    Exit;
  END;

  TRY
    NewRecFilename:=ChangeFileExt(df^.RECFilename,'.re$');
    AssignFile(NewRec,NewRecFilename);
    Rewrite(NewRec);
  EXCEPT
    {$I-}
    CloseFile(NewRec);
    {$I+}
    DisposeDatafilePointer(df);
    ErrorMsg(Format(Lang(20756),[NewRecFilename]));    //'Error creating temporary output file %s'
    Exit;
  END;

  TRY
    {Read header}
    ReadLn(OldRec,s);
    TmpS:=COPY(s,1,POS(' ',s)-1);
    IF IsInteger(TmpS) THEN NumFields:=StrToInt(TmpS)
    ELSE
      BEGIN
        CloseFile(OldRec);
        CloseFile(NewRec);
        ErrorMsg(Format(Lang(20112),[df^.RECfilename]));  //Incorrect format of datafile %s.
        DisposeDatafilePointer(df);
        Exit;
      END;
    WriteLn(NewRec,s);
    FOR n:=1 TO NumFields DO
      BEGIN
        ReadLn(OldRec,s);
        WriteLn(NewRec,s);
      END;

    NumDeleted:=0;

    IF df^.NumRecords>0 THEN
      BEGIN
        FOR CurRec:=1 TO df^.NumRecords DO
          BEGIN
            eReadOnlyNextRecord(df,OldRec);
            IF df^.CurRecDeleted THEN INC(NumDeleted)
            ELSE
              BEGIN
                s:='';
                FOR n:=0 TO df^.FieldList.Count-1 DO    //Iterate through all fields
                  BEGIN
                    WITH PeField(df^.FieldList.Items[n])^ DO
                      BEGIN
                        TmpS:=FFieldText;
                        IF ((Felttype=ftInteger) or (Felttype=ftFloat)) AND (Trim(TmpS)<>'') THEN
                          BEGIN
                            IF Felttype=ftFloat THEN
                              BEGIN
                                WHILE pos(',',TmpS)<>0 DO TmpS[Pos(',',TmpS)]:='.';
                                s:=s+FormatFloating(TmpS,FLength);
                              END  //if ftFloat
                            ELSE s:=s+FormatInt(StrToInt(TmpS),FLength);
                          END   //if ftInteger or ftFloat
                        ELSE IF Felttype=ftCrypt THEN s:=s+FormatStr(EncryptString(trim(TmpS),df^.Key),FLength)
                        ELSE IF Felttype<>ftQuestion
                             THEN s:=s+FormatStr(TmpS,FLength);
                      END;  //with
                  END;  //for n
                WHILE Length(s)>MaxRecLineLength DO
                  BEGIN
                    tmpS:=Copy(s,1,MaxRecLineLength)+'!';
                    WriteLn(NewRec,tmpS);
                    Delete(s,1,MaxRecLineLength)
                  END;  //while
                WriteLn(NewRec,s+'!');
              END;  //if not CurRecDeleted
          END;  //For CurRec
      END;  //if NumRecords>0
    CloseFile(NewRec);
    CloseFile(OldRec);

    IF WarningDlg(Format(Lang(23202)+#13#13+   //'%s contains %d records'
      Lang(23204),[df^.RECFilename,df^.NumRecords,NumDeleted]))=mrOK THEN   //'%d records will permanently be deleted'
      BEGIN
        BakRecFilename:=ChangeFileExt(df^.RECFilename,'.old')+'.rec';
        IF FileExists(BakRecFilename) THEN tmpBool:=DeleteFile(BakRecFilename);
        Rename(OldRec,BakRecFilename);  //renames *.rec to *.old.rec
        Rename(NewRec,df^.RECFilename);  //renames *.re$ to *.rec
        IF FileExists(ChangeFileExt(df^.RECFilename,'.eix'))
        THEN DeleteFile(ChangeFileExt(df^.RECFilename,'.eix'));
        eDlg(Format(Lang(23206)+    //'%s has been packed and contains now %d records'
          #13#13+Lang(23208),    //'A backup of the datafile before it was packed is saved in %s'
          [df^.RECFilename,df^.NumRecords-NumDeleted,BakRecFilename]),mtInformation,[mbOK],0);
        DisposeDatafilePointer(df);
      END
    ELSE
      BEGIN
        tmpBool:=DeleteFile(NewRecFilename);
        eDlg(Format(Lang(23210)+#13#13+   //'Pack datafile is cancelled'
          Lang(23212),[df^.RECFilename]),mtInformation,[mbOK],0);  //'No changes are made to the datafile %s'
        DisposeDatafilePointer(df);
      END;
  EXCEPT
    ErrorMsg(Lang(23214)+   //'An error occured during the pack operation.'
    Format(Lang(23212),[df^.RECFilename]));  //'No changes are made to the datafile %s'
    {$I-}
    CloseFile(NewRec);
    CloseFile(OldRec);
    {$I+}
    tmpBool:=DeleteFile(NewRecFilename);
    DisposeDatafilePointer(df);
  END;
end;

procedure TMainForm.Importfromtextfile1Click(Sender: TObject);
begin
  ImportType:=etTxt;
  ImportDatafile;
end;

procedure TMainForm.Analysistest1Click(Sender: TObject);
VAR
  df: PDatafileInfo;
  ErrorInCheckFile: Boolean;
  tmpS: String;
begin
  TRY
    IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
      BEGIN
        ErrorMsg(Format(Lang(20102),   //'Only %d datafiles can be open at the same time.'
        [MaxNumberOfDatafiles]));
        MakeDatafileBtn.Down:=False;
        Exit;
      END;
    OpenDialog1.FilterIndex:=2;    //set filter to *.rec
    OpenDialog1.InitialDir:=GetRecentFileDir;
    OpenDialog1.Filename:=GetRecentFilename('.rec');
    IF NOT OpenDialog1.Execute THEN Exit;
    IF NOT GetDatafilePointer(df) THEN Exit;
    df^.QESFileName:='';
    df^.RECFilename:=OpenDialog1.Filename;
    AddToRecentFiles(df^.RECFilename);
    IF NOT PeekDatafile(df) THEN Exit;

    df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
    df^.HasCheckFile:=FileExists(df^.CHKFilename);
    ErrorInCheckFile:=False;
    IF df^.HasCheckFile THEN ErrorInCheckFile:=NOT PeekApplyCheckFile(df,tmpS);
    IF ErrorInCheckFile THEN
      BEGIN
        IF eDlg(format(Lang(20800),[df^.CHKFilename])+   //'The checkfile %s contains errors and cannot be applied.'
        #13#13+Lang(20802)+   //'If you choose to continue then information on checks and value labels will be excluded in the codebook.'
        #13#13+Lang(20804),   //'Do you want to continue creating the codebook?',
        mtWarning,[mbYes,mbNo],0)=mrNo THEN Exit;
      END;  //if errorInCheckFile
    //CloseFile(df^.DatFile);
    df^.Datfile.Free;  //§§§
    df^.Datfile:=NIL;  //§§§
    //DoAnalysisTest(df);

  FINALLY
    DisposeDatafilePointer(df);
  END;
end;

procedure TMainForm.ImportfromdBasefile1Click(Sender: TObject);
begin
  ImportType:=etdBase;
  ImportDatafile;
end;

procedure TMainForm.Changefieldnames1Click(Sender: TObject);
VAR
  df:PDataFileInfo;
  ErrorInCheckFile: Boolean;
  tmpS: String;
begin
  df:=NIL;
  ErrorInCheckFile:=False;
  TRY
    IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
      BEGIN
        ErrorMsg(Format(Lang(20102),   //'Only %d datafiles can be open at the same time.'
        [MaxNumberOfDatafiles]));
        Exit;
      END;
    OpenDialog1.FilterIndex:=2;    //set filter to *.rec
    OpenDialog1.InitialDir:=GetRecentFileDir;
    OpenDialog1.Filename:=GetRecentFilename('.rec');
    IF NOT OpenDialog1.Execute THEN Exit;
    IF NOT GetDatafilePointer(df) THEN Exit;
    df^.QESFileName:='';
    df^.RECFilename:=OpenDialog1.Filename;
    AddToRecentFiles(df^.RECFilename);
    IF NOT PeekDatafile(df) THEN Exit;
    {Change fieldblock names in checkfile}
    df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
    ErrorInCheckFile:=False;
    df^.HasCheckFile:=FileExists(df^.CHKFilename);
    IF df^.HasCheckFile THEN ErrorInCheckFile:=NOT PeekApplyCheckFile(df,tmpS);
    IF ErrorInCheckFile THEN
      BEGIN
        IF WarningDlg(Lang(23820))=mrOK THEN df^.HasCheckFile:=False  //23820=Checkfile has incorrect contents.~~Renaming fields will not rename fields in checkfile!
        ELSE Exit;
      END;

    //CloseFile(df^.DatFile);
    df^.Datfile.Free;  //§§§
    df^.Datfile:=NIL;  //§§§
    ChangeFieldnames(df);   //in GridUnit

  FINALLY
    DisposeDatafilePointer(df);
  END;
end;

procedure TMainForm.AppendMergedatafiles1Click(Sender: TObject);
begin
  AppendMergeDatafiles;   //in MergeUnit
end;


Function TMainForm.HandleVars( const Identifier: String; ParameterList: TParameterList): IValue;
VAR
  n:Integer;
  AField:PeField;
  aUDF: TepiUDF;
  tmpStr: String;
  tmpFieldType: TFeltTyper;
  tmpDefVar: PDefVar;
  tmpNumDec: Integer;
BEGIN
  //Handle identifiers that requires parameters
  IF      Identifier='DATE'         THEN Result:=TDateExpr.Create(ParameterList)
  ELSE IF Identifier='YEAR'         THEN Result:=TYearExpr.Create(ParameterList)
  ELSE IF Identifier='MONTH'        THEN Result:=TMonthExpr.Create(ParameterList)
  ELSE IF Identifier='DAY'          THEN Result:=TDayExpr.Create(ParameterList)
  ELSE IF Identifier='WEEKNUM'      THEN Result:=TWeekNumExpr.Create(ParameterList)
  ELSE IF Identifier='DAYOFWEEK'    THEN Result:=TDayOfWeekExpr.Create(ParameterList)
  ELSE IF Identifier='ISBLANK'      THEN Result:=TIsBlankExpr.Create(ParameterList)
  ELSE IF Identifier='SOUNDEX'      THEN Result:=TSoundexExpr.Create(ParameterList)
  ELSE IF Identifier='TIME2NUM'     THEN Result:=TTimeValueExpr.Create(ParameterList)
  ELSE IF Identifier='NUM2TIME'     THEN Result:=TTimeExpr.Create(ParameterList)
  ELSE IF Identifier='COUNTMISSING' THEN Result:=TCountMissingExpr.Create(ParameterList)
  ELSE IF Identifier='SUM'          THEN Result:=TSumExpr.Create(ParameterList)
  ELSE IF Identifier='RANGE'        THEN Result:=TRangeExpr.Create(ParameterList)
  ELSE
    BEGIN
      //Handle identifiers that does not require parameters
      //if Assigned(ParameterList) then
      //  raise EExpression.CreateFmt(Lang(21668), [Identifier]);  //'Identifier %s does not require parameters'
      IF Identifier='MISSING'             THEN Result:=TStringLiteral.Create('')
      ELSE IF Identifier='_M'             THEN Result:=TStringLiteral.Create('')
      ELSE IF Identifier='TODAY'          THEN Result:=TDateLiteral.Create(Int(now))
      ELSE IF Identifier='NOW'            THEN Result:=TDateLiteral.Create(now)
      ELSE IF (Identifier='RECORDNUMBER') THEN Result:=TIntegerLiteral.Create(HandleVarsdf^.CurRecord)
      ELSE IF (Identifier='RECNUMBER')    THEN Result:=TIntegerLiteral.Create(HandleVarsdf^.CurRecord)
      ELSE IF (Identifier='RECORDCOUNT')  THEN Result:=TIntegerLiteral.Create(HandleVarsdf^.NumRecords)
      ELSE IF (Identifier='RESULTVALUE')  AND (ResultVar=0) THEN Result:=TStringLiteral.Create('')
      ELSE IF (Identifier='RESULTVALUE')  AND (ResultVar>0) THEN Result:=TIntegerLiteral.Create(ResultVar)
      ELSE IF (Identifier='RESULTLETTER') AND (ResultVar=0) THEN Result:=TStringLiteral.Create('')
      ELSE IF (Identifier='RESULTLETTER') AND (ResultVar>0) THEN Result:=TStringLiteral.Create(HelpBoxLegalKeys[ResultVar])
      ELSE
        BEGIN
          //Test if Identifier is fieldname or variablename
          n:=GetFieldNumber(Identifier,HandleVarsDf);
          IF n<>-1 THEN
            BEGIN
              //ordinary field
              AField:=PeField(HandleVarsdf^.FieldList.Items[n]);
              tmpStr:=AField^.FFieldText;
              tmpFieldType:=AField^.Felttype;
              tmpNumDec:=AField^.FNumDecimals;
            END
          ELSE
            BEGIN
              tmpDefVar:=GetDefField(Identifier,HandleVarsdf);
              IF tmpDefVar<>NIL THEN
                BEGIN
                  //Identifier is DEFINEd variable
                  n:=1;
                  tmpStr:=tmpDefVar^.FFieldText;
                  tmpFieldType:=tmpDefVar^.Felttype;
                  tmpNumDec:=tmpDefVar^.FNumDecimals;
                END;
            END;
          IF n<>-1 THEN
            BEGIN
              INC(NumVariables);
              IF trim(tmpStr)='' THEN
                BEGIN
                  Result:=TMissingLiteral.Create;
                  INC(NumMissingVariables);
                END
              ELSE
              CASE tmpFieldType OF
                ftInteger,ftIDNUM:
                  Result:=TIntegerLiteral.Create(StrToInt(tmpStr));
                ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt:
                  Result:=TStringLiteral.Create(tmpStr);
                ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday:
                  Result:=TDateLiteral.Create(mibStrToDate(tmpStr,tmpFieldType));
                ftFloat: IF (tmpNumDec=0) AND (NOT Length(tmpStr)>9) THEN Result:=TIntegerLiteral.Create(Round(eStrToFloat(tmpStr)))
                         ELSE Result:=TFloatLiteral.Create(eStrToFloat(tmpStr));
                ftBoolean: Result:=TBooleanLiteral.Create(tmpStr='Y');
              END;  //Case;
            END  //if Identifier is fieldname or variablename
          ELSE
            BEGIN
              //Check if identifier is a User Defined Function or User Defined Command from a DLL
              //Salah entry point!
              IF Assigned(Handlevarsdf^.UDFList) THEN
                BEGIN
                  IF Handlevarsdf^.UDFList.GetUDFByCommandString(Identifier,aUDF) THEN
                    BEGIN
                      //Identifier is an UDF!
                      Result:= TUDFExpression.Create(ParameterList,aUDF);
                    END;
                END;
            END;
        END;  //Test if identifier is fieldname or variablename
    END;  //Handle Identifiers that doesn't require parameters
END;  //HandleVars




procedure TMainForm.Assertdatafile1Click(Sender: TObject);
VAR
  n,t,CurRec,CurField,CurAss,ReportField:Integer;
  df:PDataFileInfo;
  RECFilename,AssertFilename:TFilename;
  AssList: TList;
  F: TextFile;
  windowList:Pointer;
  ResLin,LegalVals: TStringList;
  E: IValue;
  tmpAss: PAssert;
  tmpS,s: String;
  AEdForm: TEdForm;
  Value: String;
  NumValue: Double;
  AField: PeField;
  ok,rangefailed,legalfailed: Boolean;
  ALabelRec: PLabelRec;
begin
  df:=NIL;
  AssList:=NIL;
  ResLin:=NIL;

  TRY
    SelectFilesForm:=TSelectFilesForm.Create(MainForm);
    WITH SelectFilesForm DO
      BEGIN
        Caption:=Lang(23300);  //'Consistency check'
        File1Label.Caption:=Lang(23302);  //'Datafile to check:'
        File2Label.Caption:=Lang(23304);  //'File containing checks:'
        Ext1:='.rec';
        Ext2:='.chk';
        IgnoreExt2:=True;
        IF LastSelectFilestype=sfAssert THEN
          BEGIN
            File1Edit.Text:=LastSelectFile1;
            File2Edit.Text:=LastSelectFile2;
          END
        ELSE
          BEGIN
            File1Edit.Text:=GetRecentFilename('.rec');
            IF File1Edit.Text<>'' THEN File2Edit.Text:=ChangeFileExt(File1Edit.Text,Ext2);
          END;
        IF ShowModal<>mrOK THEN Exit;
        RECFilename:=File1Edit.Text;
        AssertFilename:=File2Edit.Text;
        LastSelectFilestype:=sfAssert;
        LastSelectFile1:=File1Edit.Text;
        LastSelectFile2:=File2Edit.Text;
      END;  //with
  FINALLY
    SelectFilesForm.Free;
  END;  //try..finally

  TRY
    IF NOT GetDatafilePointer(df) THEN Exit;
    df^.QESFileName:='';
    df^.RECFilename:=RECFilename;
    AddToRecentFiles(df^.RECFilename);
    IF NOT FileExists(AssertFilename) THEN
      BEGIN
        ErrorMsg(Format(Lang(22114),[AssertFilename]));  //'%s' not found
        Exit;
      END;
    IF NOT PeekDatafile(df) THEN Exit;
    IF df^.NumRecords=0 THEN
      BEGIN
        ErrorMsg(Format(Lang(22334),[df^.RECFilename]));  //'The datafile %s contains no records.'
        Exit;
      END;
    df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
    df^.HasCheckFile:=FileExists(df^.CHKFilename);
    IF df^.HasCheckFile THEN
      BEGIN
        IF NOT PeekApplyCheckFile(df,tmpS) THEN
          BEGIN
            ErrorMsg(format(Lang(20800),[df^.ChkFilename])+#13#13+   //20800=The checkfile %s contains errors and cannot be applied.
            Lang(23306));  //'Consistency check terminates.'
            Exit;
          END;
      END;

    AssList:=TList.Create;
    IF NOT LoadAsserts(AssertFilename,AssList,df,ReportField) THEN Exit;  //PeekCheckUnit.LoadAsserts
    IF AssList.Count=0 THEN
      BEGIN
        ErrorMsg(Format(Lang(23308),[AssertFilename]));  //'No consistency checks found in %s'
        Exit;
      END;

    //Prepare datafile for readonly
    //CloseFile(df^.DatFile);
    df^.Datfile.Free;  //§§§
    df^.Datfile:=NIL;  //§§§
    AssignFile(F,df^.RECFilename);
    Reset(F);
    FOR n:=0 TO df^.FieldList.Count DO
      ReadLn(F,tmpS);
    {filepointer in ReadOnlyRecFile now points to first record}

    TRY
      UserAborts:=False;
      ProgressForm:=TProgressForm.Create(MainForm);
      ProgressForm.Caption:=Lang(23338)+' '+ExtractFilename(df^.RECFilename);  //'Checking'
      ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
      ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
      WITH ProgressForm.pBar DO
        BEGIN
          Max:=df^.NumRecords;
          Position:=0;
        END;  //with
      WindowList:=DisableTaskWindows(ProgressForm.Handle);
      ProgressForm.Show;

      HandleVarsDf:=df;
      FOR CurRec:=1 TO df^.NumRecords DO
        BEGIN
          IF ProgressStep(df^.NumRecords,CurRec) THEN
            BEGIN
              ProgressForm.pBar.Position:=CurRec;
              ProgressForm.pLabel.Caption:=Format(Lang(23310),[CurRec,df^.NumRecords]);  //23310=Reading record %d of %d
              Application.ProcessMessages;
            END;

          eReadOnlyNextRecord(df,F);
          FOR n:=0 TO AssList.Count-1 DO
            BEGIN
              tmpAss:=PAssert(AssList.Items[n]);
              s:=AnsiUpperCase(tmpAss^.AssExpr);
              IF (s='(CHECKRANGE)') OR (s='(CHECKLEGAL)') OR (s='(CHECKRANGELEGAL)')
              OR (s='(CHECKMUSTENTER)') THEN
                BEGIN
                  FOR CurField:=0 TO df^.FieldList.Count-1 DO
                    BEGIN
                      rangefailed:=false;    //*rettet*
                      legalfailed:=false;    //*rettet*
                      AField:=PeField(df^.FieldList.Items[CurField]);
                      IF AField^.Felttype=ftQuestion THEN CONTINUE;
                      Value:=trim(AField^.FFieldText);
                      IF Value<>'' THEN
                        BEGIN
                          CASE AField^.Felttype OF
                            ftInteger,ftFloat,ftIDNUM:
                              BEGIN
                                IF NOT IsFloat(Value) THEN
                                  BEGIN
                                    ErrorMsg(Format(Lang(23312),[trim(AField^.FName),CurRec]));    //'Invalid numeric value found in field %s, record %d'
                                    Exit;
                                  END;
                                NumValue:=eStrToFloat(Value);
                              END;
                            ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday:   //&&
                              BEGIN
                                IF NOT mibIsDate(Value,AField^.FeltType) THEN
                                  BEGIN
                                    ErrorMsg(Format(Lang(23314),[trim(AField^.FName),CurRec]));  //Invalid date value found in field %s, record %d
                                    Exit;
                                  END;
                                NumValue:=mibStrToDate(Value,AField^.Felttype);
                              END;
                          END;  //case
                        END;  //if value<>''
                      IF (AnsiUpperCase(tmpAss^.AssExpr)='(CHECKRANGE)')
                      OR (AnsiUpperCase(tmpAss^.AssExpr)='(CHECKRANGELEGAL)') THEN    //*rettet*
                        BEGIN
                          IF (Value<>'') AND (AField^.FRangeDefined) THEN
                            BEGIN
                              ok:=True;
                              IF AField^.FMin<>'' THEN
                                BEGIN
                                  CASE AField^.FeltType OF
                                    ftInteger,ftFloat,
                                      ftIDNUM: IF NOT (NumValue>=eStrToFloat(AField^.FMin)) THEN ok:=False;
                                    ftDate,ftEuroDate,ftYMDDate,ftYMDToday,        //&&
                                      ftToday,ftEuroToday: IF NOT (NumValue>=mibStrToDate(AField^.FMin,AField^.FeltType)) THEN ok:=False;
                                  ELSE IF NOT(Value >= AField^.FMin) THEN ok:=False;
                                  END;  //case
                                END;  //if Minimum defined
                              IF AField^.FMax<>'' THEN
                                BEGIN
                                  CASE AField^.FeltType OF
                                    ftInteger,ftFloat,
                                      ftIDNUM: IF NOT (NumValue<=eStrToFloat(AField^.FMax)) THEN ok:=False;
                                    ftDate,ftEuroDate,ftYMDDate,ftYMDToday,        //&&
                                      ftToday,ftEuroToday: IF NOT (NumValue<=mibStrToDate(AField^.FMax,AField^.FeltType)) THEN ok:=False;
                                  ELSE IF NOT(Value <= AField^.FMax) THEN ok:=False;
                                  END;  //case
                                END;  //if Maximum defined
                              IF NOT ok THEN rangefailed:=true;
                                {BEGIN
                                  tmpAss.ViolCount:=tmpAss.ViolCount+1;
                                  IF tmpAss.Violaters='' THEN tmpS:='' ELSE tmpS:=', ';
                                  IF ReportField=-1 THEN tmpS:=tmpS+IntToStr(CurRec)
                                  ELSE
                                    BEGIN
                                      s:=trim(Pefield(df^.FieldList.Items[Reportfield])^.FFieldText);
                                      IF s='' THEN tmpS:=tmpS+'(#'+IntToStr(CurRec)+')'
                                      ELSE tmpS:=tmpS+s;
                                    END;
                                  tmpS:=tmpS+' ('+trim(AField^.FName)+')';
                                  tmpAss.Violaters:=tmpAss.Violaters+tmpS;
                                END;  //if not ok}
                            END;  //if Value<>''
                        END;  //if checkrange
                      IF (AnsiUpperCase(tmpAss^.AssExpr)='(CHECKLEGAL)')
                      OR (AnsiUpperCase(tmpAss^.AssExpr)='(CHECKRANGELEGAL)') THEN    //*rettet*
                        BEGIN
                          IF Value<>'' THEN
                            BEGIN
                              TRY
                                //Check legals
                                LegalVals:=TStringList.Create;
                                ok:=False;
                                LegalVals.CommaText:=AField^.FLegal;
                                IF ( (LegalVals.Count>0) AND (NOT AField^.FRangeDefined) )
                                  OR ( (LegalVals.Count>1) AND (AField^.FRangeDefined) ) THEN
                                  BEGIN  //Legals are defined
                                    IF AField^.FRangeDefined THEN LegalVals.Delete(0);
                                    t:=0;
                                    REPEAT
                                      CASE AField^.Felttype OF
                                        ftInteger,ftFloat,
                                          ftIDNUM: IF NumValue=eStrToFloat(LegalVals[t]) THEN ok:=True;
                                        ftDate,ftEuroDate,ftYMDDate,ftYMDToday,        //&&
                                          ftToday,ftEuroToday: IF NumValue=mibStrToDate(LegalVals[t],AField^.FeltType) THEN ok:=True;
                                      ELSE IF Value=LegalVals[t] THEN ok:=True;
                                      END;  //Case
                                      INC(t);
                                    UNTIL (ok) OR (t=LegalVals.Count);
                                  END  //if legals defined
                                ELSE ok:=True;
                              EXCEPT
                                ErrorMsg(Format(Lang(20204),[331]));  //20204=Out of memory (reference code %d)
                                LegalVals.Free;
                                Exit;
                              END;  //try..except
                              LegalVals.Free;

                              //Check comment legal
                              IF (ok) AND (AField^.FCommentLegalRec<>NIL) THEN
                                BEGIN
                                  ok:=False;
                                  ALabelRec:=AField^.FCommentLegalRec;
                                  WHILE (ALabelRec<>NIL) AND (NOT ok) DO
                                    BEGIN
                                      IF ALabelRec^.Value=Value THEN ok:=True;
                                      ALabelRec:=ALabelRec^.Next;
                                    END;  //while
                                END;  //if has Comment legal

                              IF NOT ok THEN legalfailed:=true;
                                {BEGIN
                                  tmpAss.ViolCount:=tmpAss.ViolCount+1;
                                  IF tmpAss.Violaters='' THEN tmpS:='' ELSE tmpS:=', ';
                                  IF ReportField=-1 THEN tmpS:=tmpS+IntToStr(CurRec)
                                  ELSE
                                    BEGIN
                                      s:=trim(Pefield(df^.FieldList.Items[Reportfield])^.FFieldText);
                                      IF s='' THEN tmpS:=tmpS+'(#'+IntToStr(CurRec)+')'
                                      ELSE tmpS:=tmpS+s;
                                    END;
                                  tmpS:=tmpS+' ('+trim(AField^.FName)+')';
                                  tmpAss.Violaters:=tmpAss.Violaters+tmpS;
                                END;  //if not ok}
                            END;  //if value<>''
                        END;  //if checklegal
                      IF AnsiUpperCase(tmpAss^.AssExpr)='(CHECKMUSTENTER)' THEN
                        BEGIN
                          IF (AField^.FMustEnter) AND (trim(AField^.FFieldText)='') THEN
                            BEGIN
                              tmpAss.ViolCount:=tmpAss.ViolCount+1;
                              IF tmpAss.Violaters='' THEN tmpS:='' ELSE tmpS:=', ';
                              IF ReportField=-1 THEN tmpS:=tmpS+IntToStr(CurRec)
                              ELSE
                                BEGIN
                                  s:=trim(Pefield(df^.FieldList.Items[Reportfield])^.FFieldText);
                                  IF s='' THEN tmpS:=tmpS+'(#'+IntToStr(CurRec)+')'
                                  ELSE tmpS:=tmpS+s;
                                END;
                              tmpS:=tmpS+' ('+trim(AField^.FName)+')';
                              tmpAss.Violaters:=tmpAss.Violaters+tmpS;
                            END;
                        END;  //if CheckMustEnter
                      s:=AnsiUpperCase(tmpAss^.AssExpr);                  //*rettet*
                      IF (s='(CHECKRANGE)') OR (s='(CHECKLEGAL)') OR (s='(CHECKRANGELEGAL)') THEN
                        BEGIN
                          IF ((s='(CHECKRANGE)') AND (rangefailed))
                          OR ((s='(CHECKLEGAL)') and (legalfailed))
                          OR ((s='(CHECKRANGELEGAL)') AND (rangefailed) AND (legalfailed)) THEN
                            BEGIN
                              tmpAss.ViolCount:=tmpAss.ViolCount+1;
                              IF tmpAss.Violaters='' THEN tmpS:='' ELSE tmpS:=', ';
                              IF ReportField=-1 THEN tmpS:=tmpS+IntToStr(CurRec)
                              ELSE
                                BEGIN
                                  s:=trim(Pefield(df^.FieldList.Items[Reportfield])^.FFieldText);
                                  IF s='' THEN tmpS:=tmpS+'(#'+IntToStr(CurRec)+')'
                                  ELSE tmpS:=tmpS+s;
                                END;
                              tmpS:=tmpS+' ('+trim(AField^.FName)+'='+trim(AField^.FFieldText)+')';
                              tmpAss.Violaters:=tmpAss.Violaters+tmpS;
                            END;
                        END;
                    END;  //for Curfield
                END
              ELSE
                BEGIN
                  //AssExpr contains a logical expression
                  TRY
                    E:= CreateExpression(tmpAss^.AssExpr,MainForm.HandleVars);
                    IF Assigned(E) THEN
                      BEGIN
                        IF E.CanReadAs(ttBoolean) THEN
                          BEGIN
                            IF E.AsBoolean=False THEN
                              BEGIN
                                tmpAss.ViolCount:=tmpAss.ViolCount+1;
                                IF tmpAss.Violaters='' THEN tmpS:='' ELSE tmpS:=', ';
                                IF ReportField=-1 THEN tmpS:=tmpS+IntToStr(CurRec)
                                ELSE
                                  BEGIN
                                    s:=trim(Pefield(df^.FieldList.Items[Reportfield])^.FFieldText);
                                    IF s='' THEN tmpS:=tmpS+'(#'+IntToStr(CurRec)+')'
                                    ELSE tmpS:=tmpS+s;
                                  END;
                                tmpAss.Violaters:=tmpAss.Violaters+tmpS;
                              END;
                          END
                        ELSE
                          BEGIN
                            ErrorMsg(Format(Lang(23316),[AssertFilename,tmpAss^.OrigExpr])+#13+Lang(23318));  //'Error in file %s~CHECK %s'  'is not a valid boolean expression'
                            Exit;
                          END;
                      END;  //if assigned(E)
                  EXCEPT
                    On Er:EExpression do
                      BEGIN
                        ErrorMsg(Format(Lang(23316)+#13+Er.Message,[AssertFilename,tmpAss^.OrigExpr]));   //Error in file %s~CHECK %s
                        Exit;
                      END;
                  END;  //try..except
                END;  //if logical expression

            END;  //for n

          //Application.ProcessMessages;
          IF UserAborts THEN
            BEGIN
              IF eDlg(Lang(23320),mtConfirmation,[mbYes,mbNo],0)=mrYes  //'Abort Consistency Check?'
              THEN Exit ELSE UserAborts:=False;
            END;  //if UserAborts
        END;  //for CurRec

    FINALLY
      EnableTaskWindows(WindowList);
      ProgressForm.Free;
      CloseFile(F);
    END;  //try..finally

    ResLin:=TStringList.Create;
    ResLin.Append(Format(Lang(23322),[ExpandFilename(df^.RECFilename)]));   //'Consistency checks for %s'
    ResLin.Append(Format(Lang(23324),[ExpandFilename(AssertFilename)]));  //'Based on %s'
    ResLin.Append(FormatDateTime('dd mmm yyyy hh":"nn',now));
    ResLin.Append('');
    tmpS:=Lang(23326)+' ';   //'Records identified by'
    IF ReportField=-1 THEN
      BEGIN
        tmpS:=tmpS+Lang(23328);    //'recordnumber'
        ResLin.Append(tmpS);
      END
    ELSE
      BEGIN
        tmpS:=tmpS+Lang(23330)+' '+trim(PeField(df^.FieldList.Items[ReportField])^.FName);    //'field'
        ResLin.Append(tmpS);
        ResLin.Append(Format(Lang(23332),    //'Records where %s is missing is indicated with recordnumber as (#...)'
          [trim(PeField(df^.FieldList.Items[ReportField])^.FName)]));
      END;
    ResLin.Append('');
    FOR CurAss:=0 TO AssList.Count-1 DO
      BEGIN
        tmpAss:=PAssert(AssList.Items[CurAss]);
        ResLin.Append(cFill('-',80));
        ResLin.Append(tmpAss^.AssName);
        ResLin.Append(tmpAss^.OrigExpr);
        ResLin.Append('');
        tmpS:=Lang(23334)+' ';   //'Consistency check failed for'
        IF tmpAss^.ViolCount=0 THEN tmpS:=Lang(23336)   //'No failures.'
        ELSE IF ReportField=-1 THEN tmpS:=tmpS+Lang(23328)+' '+tmpAss^.Violaters  //'recordnumber'
        ELSE tmpS:=tmpS+trim(Pefield(df^.FieldList.Items[Reportfield])^.FName)+' = '+tmpAss^.Violaters;
        WHILE Length(tmpS)>60 DO
          BEGIN
            n:=60;
            WHILE NOT (tmpS[n] in [',',' ']) DO DEC(n);
            ResLin.Append(Copy(tmpS,1,n));
            Delete(tmpS,1,n);
          END;
        ResLin.Append(tmpS);
        ResLin.Append(cFill('-',80));
        ResLin.Append('');
        ResLin.Append('');
      END;  //for CurAss

    TRY
      Screen.Cursor:=crHourGlass;
      LockWindowUpdate(MainForm.Handle);
      AEdForm:=TEdForm.Create(Self);
      WITH AEdForm DO
        BEGIN
          FormType:=ftDocumentation;
          Caption:=Format(Lang(23322),[df^.RECFilename]);   //'Consistency Checks for %s'
          Ed.Font.Assign(epiDocuFont);
          Ed.Color:=DocuColor;
          Ed.ScrollBars:=ssBoth;
          Ed.Lines.Capacity:=ResLin.Count;
          Ed.Lines.Assign(ResLin);
          Ed.ScrollBars:=ssBoth;
          Ed.SelStart:=0;
        END;
    FINALLY
      LockWindowUpdate(0);
      Screen.Cursor:=crDefault;
    END;

  FINALLY
    IF Assigned(ResLin) THEN ResLin.Free;
    IF Assigned(AssList) THEN
      BEGIN
        IF AssList.Count>0 THEN
          BEGIN
            FOR n:=0 TO AssList.Count-1 DO
              Dispose(PAssert(AssList.Items[n]));
          END;
        AssList.Free;
      END;
    DisposeDatafilePointer(df);
  END;
end;

procedure TMainForm.ImportfromStatafile1Click(Sender: TObject);
begin
  ImportType:=etStata;
  ImportDatafile;
end;

procedure TMainForm.ExporttoSPSS1Click(Sender: TObject);
begin
  ExportType:=etSPSS;
  ExportDatafile;
end;

procedure TMainForm.ExporttoSAS1Click(Sender: TObject);
begin
  ExportType:=etSAS;
  ExportDatafile;
end;


Function TMainForm.ExecRecodeCommandList(VAR df:PDatafileInfo; VAR CmdList:TList):Boolean;
VAR
  ok:Boolean;
  tmpFloat:Double;
  tmpStr,tmpResult,s:String;
  CmdCounter:Integer;
  cmd:PCmds;
  E:IValue;
  AField:PeField;
  tmpDefVar: PDefVar;
  tmpFieldtype: TFelttyper;
  tmpNumDec,tmpFLength: Integer;

BEGIN  //ExecCommandList
  IF ExitExecutionBlock THEN
    BEGIN
      Result:=True;
      Exit;
    END;
  IF CheckFileMode      THEN Exit;
  IF TestingDataForm    THEN Exit;
  IF CmdList=NIL        THEN Exit;
  IF CmdList.Count=0    THEN Exit;
  HandleVarsDf:=df;
  Result:=False;
  FOR CmdCounter:=0 TO CmdList.Count-1 DO
    BEGIN
      IF ExitExecutionBlock THEN
        BEGIN
          Result:=True;
          Exit;
        END;
      Cmd:=PCmds(CmdList.Items[CmdCounter]);
      CASE Cmd^.Command OF
        cmdLET:
            BEGIN
              TRY
                E:= CreateExpression(Cmd^.LetExpr, MainForm.HandleVars);
                IF Assigned(E) THEN
                  BEGIN
                    //check if the result can be assigned to the field
                    ok:=true;
                    IF Cmd^.VarIsField THEN
                      BEGIN
                        AField:=PeField(df^.FieldList.Items[Cmd^.VarNumber]);
                        tmpFieldtype:=AField^.Felttype;
                        tmpNumDec:=AField^.FNumDecimals;
                        tmpFLength:=AField^.FLength;
                      END
                    ELSE
                      BEGIN
                        {Var is DEFINE-variable}
                        tmpDefVar:=GetDefField(cmd^.VarName,df);
                        tmpFieldType:=tmpDefVar^.Felttype;
                        tmpNumDec:=tmpDefVar^.FNumDecimals;
                        tmpFLength:=tmpDefVar^.FLength;
                      END;
                    s:=AnsiUpperCase(E.AsString);
                    IF ResultEqualsMissing THEN s:='';  //IF MissingAction=maRejectMissing THEN ResultEqualsMissing:=True;
                    IF (NumVariables>0) AND (NumVariables=NumMissingVariables) THEN s:='';   //result=missing if all variables are missing
                    IF (s='') OR (Cmd^.LetExpr='_M') THEN ok:=true
                    ELSE IF ((s='Y') OR (s='N')) AND (tmpFieldType=ftBoolean) THEN ok:=True
                    ELSE
                      CASE tmpFieldType OF
                        ftInteger,ftFloat:
                            IF NOT (E.CanReadAs(ttInteger) OR E.CanReadAs(ttFloat)) THEN ok:=False;
                        ftBoolean:
                            IF NOT E.CanReadAs(ttBoolean) THEN ok:=False;
                        ftAlfa,ftUpperAlfa,ftSoundex:
                            IF NOT E.CanReadAs(ttString) THEN ok:=False;
                        ftDate,ftEuroDate,ftYMDDate:   //&&
                            IF NOT E.CanReadAs(ttFloat) THEN ok:=False;
                      END;  //case
                    IF NOT ok THEN
                      BEGIN
                        ErrorMsg(Format(Lang(23500),[cmd^.LetExpr,cmd^.VarName]));  //'Error in LET-expression~%s~Result can not be assigned to %s'
                        Exit;
                      END
                    ELSE
                      BEGIN
                        tmpResult:='';
                        IF (E.AsString='') OR (Cmd^.LetExpr='_M') THEN tmpResult:=''
                        ELSE
                        CASE tmpFieldType OF
                          ftDate,ftEuroDate,ftYMDDate,ftYMDToday:   //&&
                            tmpResult:=mibDateToStr(E.AsFloat,tmpFieldType);
                          ftBoolean:
                            BEGIN
                              IF E.CanReadAs(ttBoolean) THEN
                                BEGIN
                                  IF E.AsBoolean=True THEN tmpResult:='Y' ELSE tmpResult:='N';
                                END
                              ELSE tmpResult:=E.AsString;
                            END;
                          ftFloat,ftInteger:
                            BEGIN
                              tmpFloat:=eStrToFloat(E.AsString);
                              Str(TmpFloat:tmpFLength:tmpNumDec,TmpStr);
                              tmpResult:=trim(tmpStr);
                            END;
                          ELSE tmpResult:=E.AsString;
                        END;  //case
                        IF Length(tmpResult)>tmpFLength
                        THEN raise EExpression.CreateFmt(Lang(23502),[trim(cmd^.VarName)]);  //'Result is too wide to fit %s'
                        IF Cmd^.VarIsField THEN
                          BEGIN
                            AField^.FFieldText:=tmpResult;
                            df^.CurRecModified:=True;
                          END
                        ELSE tmpDefVar^.FFieldText:=tmpResult;
                      END;
                  END;  //if assigned(E)
              EXCEPT
                On Er:EExpression do
                  BEGIN
                    ErrorMsg(Lang(21670)+#13+   //'Error in LET-expression:'
                    trim(Cmd^.VarName)+'='+Cmd^.LetExpr+#13#13+Er.Message);
                    ExitExecutionBlock:=True;
                    UserAborts:=True;
                    Exit;
                  END;
              END;  //try..except
            END;  //case cmdLET
        cmdIF:
            BEGIN
              TRY
                E:= CreateExpression(Cmd^.IfExpr, MainForm.HandleVars);
                IF Assigned(E) THEN
                  BEGIN
                    {Check om E kan læses som boolean
                    hvis E=True så udfør IfCmds
                    hvis E=False og ElseCmds<>NIL så udfør ElseCmds}
                    IF E.CanReadAs(ttBoolean) THEN
                      BEGIN
                        IF (E.AsBoolean=True) AND (cmd^.IfCmds<>NIL)
                        THEN ExecRecodeCommandList(df,cmd^.IfCmds)
                        ELSE IF (E.AsBoolean=False) AND (cmd^.ElseCmds<>NIL)
                        THEN ExecRecodeCommandList(df,cmd^.ElseCmds);
                      END
                    ELSE
                      BEGIN
                        ErrorMsg(Cmd^.IfExpr+#13+Lang(23318));  //'is not a valid boolean expression'
                        Exit;
                      END;
                  END;  //if assigned(E)
              EXCEPT
                On Er:EExpression do
                  BEGIN
                    ErrorMsg(Lang(21672)+#13+Cmd^.IFExpr+#13#13+Er.Message);   //'Error in IF-expression:'
                    UserAborts:=True;
                    Exit;
                  END;
              END;  //try..except
            END;  //Case cmdIF
        cmdExit:
            BEGIN
              ExitExecutionBlock:=True;
              Result:=True;
              Exit;
            END;  //case cmdExit
        cmdClear:
            BEGIN
              IF Cmd^.HideVarNumber>=0 THEN
                BEGIN
                  AField:=PeField(df^.FieldList.Items[Cmd^.HideVarNumber]);
                  AField.FFieldText:='';
                  df^.CurRecModified:=True;
                END;
            END;  //case cmdClear
      END;  //Case command
    END;  //for CmdCounter
  Result:=True;
END;  //Function ExecRecodeCommandList


procedure TMainForm.Recodedatafile1Click(Sender: TObject);
VAR
  n,CurRec,RecsRecoded:Integer;
  df,NewDf:PDataFileInfo;
  RECFilename,tmpRecFilename,RecodeFilename:TFilename;
  windowList:Pointer;
  tmpS: String;
  ChkLin: TStringList;
  AField,NewField: PeField;
  tmpBool:Boolean;
  F,NewRecFile: TextFile;
  CheckObj: TCheckObj;
begin
  df:=NIL;
  NewDf:=NIL;
  ChkLin:=NIL;

  TRY
    SelectFilesForm:=TSelectFilesForm.Create(MainForm);
    WITH SelectFilesForm DO
      BEGIN
        Caption:=Lang(23504);  //'Recode datafile'
        File1Label.Caption:=Lang(23506);  //'Datafile to recode:'
        File2Label.Caption:=Lang(23508);  //'Recode command file:'
        Ext1:='.rec';
        Ext2:='.chk';
        IgnoreExt2:=True;
        UpdateFile2Text:=True;
        IF LastSelectFilestype=sfRecode THEN
          BEGIN
            File1Edit.Text:=LastSelectFile1;
            File2Edit.Text:=LastSelectFile2;
          END
        ELSE
          BEGIN
            File1Edit.Text:=GetRecentFilename('.rec');
            IF File1Edit.Text<>'' THEN File2Edit.Text:=ChangeFileExt(File1Edit.Text,Ext2);
          END;
        IF ShowModal<>mrOK THEN Exit;
        RECFilename:=File1Edit.Text;
        RecodeFilename:=File2Edit.Text;
        LastSelectFilestype:=sfRecode;
        LastSelectFile1:=File1Edit.Text;
        LastSelectFile2:=File2Edit.Text;
      END;  //with
  FINALLY
    SelectFilesForm.Free;
  END;  //try..finally

  TRY
    IF NOT GetDatafilePointer(df) THEN Exit;
    df^.QESFileName:='';
    df^.RECFilename:=RECFilename;
    AddToRecentFiles(df^.RECFilename);
    IF NOT FileExists(RecodeFilename) THEN
      BEGIN
        ErrorMsg(Format(Lang(22114),[RecodeFilename]));  //'%s' not found
        Exit;
      END;
    IF NOT PeekDatafile(df) THEN Exit;
    IF df^.NumRecords=0 THEN
      BEGIN
        ErrorMsg(Format(Lang(22334),[df^.RECFilename]));   //22334=The datafile %s contains no records.
        Exit;
      END;


    {Make temporary datafile}
    tmpRecFilename:=ChangeFileExt(df^.RECFilename,'.re$');
    IF NOT GetDatafilePointer(NewDf) THEN
      BEGIN
        ErrorMsg(Format(Lang(20756),[tmpRecFilename]));   //20756=Error creating temporary output file %s
        Exit;
      END;
    NewDf^.RECFilename:=tmpRecFilename;
    NewDf^.FileLabel:=df^.FileLabel;
    NewDf^.EpiInfoFieldNaming:=df^.EpiInfoFieldNaming;
    NewDf^.RecodeCmds:=df^.RecodeCmds;
    NewDf^.NumFields:=df^.NumFields;
    FOR n:=0 TO df^.FieldList.Count-1 DO
      BEGIN
        New(NewField);
        AField:=PeField(df^.FieldList.Items[n]);
        NewField^:=AField^;
        NewField^.FOriginalQuest:=AField^.FQuestion;
        NewField^.FIndex:=0;
        NewDf^.FieldList.Add(NewField);
      END;
    IF NOT PeekCreateDatafile(NewDf) THEN
      BEGIN
        ErrorMsg(Format(Lang(20756),[tmpRecFilename]));   //20756=Error creating temporary output file %s
        Exit;
      END;
    //AssignFile(NewDf^.DatFile,tmpRecFilename);
    //Reset(NewDf^.DatFile);

    TRY
      {Read file with recode commands}
      //GlobalDefList:=TStringList.Create;
      ChkLin:=TStringList.Create;
      ChkLin.LoadFromFile(RecodeFilename);
      tmpS:=ChkLin.Text;
      TRY
        CheckObj:=TCheckObj.Create;
        CheckObj.OnTranslate:=self.TranslateEvent;
        tmpBool:=CheckObj.ApplyChecks(df,tmpS);
      Finally
        CheckObj.Free;
      END;
      IF NOT tmpBool THEN
        BEGIN
          ErrorMsg(Format(Lang(23510),[RecodeFilename]));   //'The recodefile %s has errors and cannot be applied'
          Exit;
        END;
      IF df^.RecodeCmds=NIL THEN
        BEGIN
          ErrorMsg(Format(Lang(23512),[RecodeFilename]));    //'No recodeblock was found in %s'
          Exit;
        END;
    EXCEPT
      ErrorMsg(Format(Lang(22104),[RecodeFilename]));  //22104=The file %s cannot be opened.
      Exit;
    END;

    TRY
      //Open New datafile for output
      AssignFile(NewRecFile,tmpRecFilename);
      Append(NewRecFile);
      //Prepare input datafile for readonly
      //CloseFile(df^.DatFile);
      df^.Datfile.Free;
      df^.Datfile:=NIL;  //§§§
      AssignFile(F,df^.RECFilename);
      Reset(F);
      FOR n:=0 TO df^.FieldList.Count DO
        ReadLn(F,tmpS);
      {filepointer in ReadOnlyRecFile now points to first record}

      UserAborts:=False;
      ProgressForm:=TProgressForm.Create(MainForm);
      ProgressForm.Caption:=Lang(23514)+' '+ExtractFilename(df^.RECFilename);  //'Recoding'
      ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
      ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
      WITH ProgressForm.pBar DO
        BEGIN
          Max:=df^.NumRecords;
          Position:=0;
        END;  //with
      WindowList:=DisableTaskWindows(ProgressForm.Handle);
      ProgressForm.Show;
      HandleVarsDf:=df;
      RecsRecoded:=0;

      FOR CurRec:=1 TO df^.NumRecords DO
        BEGIN
          IF ProgressStep(df^.NumRecords,CurRec) THEN
            BEGIN
              ProgressForm.pBar.Position:=CurRec;
              ProgressForm.pLabel.Caption:=Format(Lang(23516),[CurRec,df^.NumRecords]);  //23516=Recoding record %d of %d
              Application.ProcessMessages;
            END;

          eReadOnlyNextRecord(df,F);
          df^.CurRecModified:=False;
          ExitExecutionBlock:=False;
          IF NOT ExecRecodeCommandList(df,df^.RecodeCmds) THEN Exit;
          IF df^.CurRecModified THEN INC(RecsRecoded);

          {Transfer record to NewDf and save it}
          FOR n:=0 TO df^.FieldList.Count-1 DO
            BEGIN
              AField:=PeField(df^.FieldList.Items[n]);
              NewField:=PeField(NewDf^.FieldList.Items[n]);
              IF AField^.Felttype<>ftQuestion THEN NewField^.FFieldText:=AField^.FFieldText;
            END;  //for n
          NewDf^.CurRecDeleted:=df^.CurRecDeleted;
          WriteNextRecord(NewDf,NewRecFile);

          //Application.ProcessMessages;
          IF UserAborts THEN
            BEGIN
              IF eDlg(Lang(23518),mtConfirmation,[mbYes,mbNo],0)=mrYes  //'Abort Recode?'
              THEN Exit ELSE UserAborts:=False;
            END;  //if UserAborts
        END;  //for CurRec

    FINALLY
      EnableTaskWindows(WindowList);
      ProgressForm.Free;
      CloseFile(F);
      CloseFile(NewRecFile);
    END;  //try..finally

    IF WarningDlg(Format(Lang(23520),      //'Recoding of %s ready'#13#13'%d records will be changed'
    [RECFilename,RecsRecoded]))=mrOK THEN
      BEGIN
        IF FileExists(ChangeFileExt(df^.RECFilename,'.old')+'.rec')
        THEN tmpBool:=DeleteFile(ChangeFileExt(df^.RECFilename,'.old')+'.rec');
        Rename(F,ChangeFileExt(df^.RECFilename,'.old')+'.rec');  //renames *.rec to *.old.rec
        Rename(NewRecFile,RECFilename);                          //renames *.re$ to *.rec
        eDlg(Format(Lang(23522),   //'%s has been recoded~%d records changed~~Backup of original datafile saved as %s'
        [RECFilename,RecsRecoded,ChangeFileExt(df^.RECFilename,'.old')+'.rec']),mtInformation,[mbOK],0);

        //Add note to dataentry notes file
        ChkLin.Clear;
        ChkLin.Append(Format(Lang(23526),[RecsRecoded]));  //'Datafile recoded. %d records were changed'
        ChkLin.Append('RECODEBLOCK');
        AddCommandList(df,ChkLin,df^.RecodeCmds,2);
        ChkLin.Append('END');
        AddToNotesFile(df,ChkLin.Text);
      END
    ELSE
      BEGIN
        eDlg(Format(Lang(23524),   //'Recode datafile was cancelled~~No changes were made in %s'
        [RECFilename]),mtInformation,[mbOK],0);
        tmpBool:=DeleteFile(tmpRecFilename);
      END;

  FINALLY
    IF Assigned(ChkLin) THEN ChkLin.Free;
    //GlobalDefList.Free;
    {$I-}
    CloseFile(NewRecFile);
    n:=IOResult;
    {$I+}
    IF Assigned(NewDf) THEN NewDf^.RecodeCmds:=NIL;
    DisposeDatafilePointer(df);
    DisposeDatafilePointer(NewDf);
  END;
end;

procedure TMainForm.Countvalues1Click(Sender: TObject);
begin
  CountValues;  //in CountValuesUnit
end;



procedure TMainForm.ExportEpiData1Click(Sender: TObject);
begin
  ExportType:=etEpiData;
  ExportDatafile;
end;


procedure TMainForm.WMDropFiles(var Msg: TWMDropFiles);
VAR
  i: Integer;
  s: String;
  Ext: String[4];
BEGIN
  WITH Msg DO
    BEGIN
      FOR i:=0 TO DragQueryFile(Drop,$FFFFFFFF,nil,0)-1 DO   //første 0 var -1 i delphi 3
        BEGIN
          SetLength(s,DragQueryFile(Drop,i,nil,0)+1);
          DragQueryFile(Drop,i,PCHar(s),Length(s));
          Ext:=AnsiUpperCase(ExtractFileExt(s));
          IF Ext='.REC' THEN
            BEGIN
              IF MDIChildCount>0 THEN eDlg(Lang(20100),mtInformation,[mbOK],0)   //Please close all open files before opening a datafile.
              ELSE DoOpenDatafile(s);
            END
          ELSE
            BEGIN
              LockWindowUpdate(MainForm.Handle);
              WITH TEdForm.Create(Self) DO Open(s);
              LockWindowUpdate(0);
            END;
        END;  //for
      DragFinish(Drop);
    END;  //with
END;  //WMDropFiles


procedure TMainForm.Compressdatafile1Click(Sender: TObject);
VAR
  n,CurRec:Integer;
  OldDf,NewDf:PDataFileInfo;
  OldRecFile,NewRecFile: TextFile;
  OldField,NewField: PeField;
  tmpS: String;
  WindowList:Pointer;
  tmpBool: Boolean;
begin
  OldDf:=NIL;
  NewDf:=NIL;
  TRY
    IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
      BEGIN
        ErrorMsg(Format(Lang(20102),   //'Only %d datafiles can be open at the same time.'
        [MaxNumberOfDatafiles]));
        Exit;
      END;
    OpenDialog1.FilterIndex:=2;    //set filter to *.rec
    OpenDialog1.InitialDir:=GetRecentFileDir;
    OpenDialog1.Filename:=GetRecentFilename('.rec');
    IF NOT OpenDialog1.Execute THEN Exit;
    IF NOT GetDatafilePointer(OldDf) THEN Exit;
    IF NOT GetDatafilePointer(NewDf) THEN Exit;
    OldDf^.QESFileName:='';
    OldDf^.RECFilename:=OpenDialog1.Filename;
    NewDf^.RECFilename:=ExtractFileDir(OldDf^.RECFilename)+'temp.re$';
    AddToRecentFiles(OldDf^.RECFilename);

    IF WarningDlg(Lang(23608)+#13#13+Lang(23610))=mrCancel THEN Exit;   //'Compress data will narrow input fields to width of current data~If you want to delete records use PACK instead.'

    IF NOT PeekDatafile(OldDf) THEN Exit;
    IF OldDf^.NumRecords=0 THEN
      BEGIN
        ErrorMsg(Format(Lang(22334),[OldDf^.RECFilename]));  //22334=The datafile %s contains no records.
        Exit;
      END;
    TRY
      UserAborts:=False;
      ProgressForm:=TProgressForm.Create(MainForm);
      ProgressForm.Caption:=Lang(23600)+' '+ExtractFilename(OldDf^.RECFilename);   //'Compressing datafile'
      ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
      ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
      ProgressForm.pLabel.Visible:=False;
      WITH ProgressForm.pBar DO BEGIN
        Max:=OldDf^.NumRecords*2;
        Position:=0;
      END;  //with
      WindowList:=DisableTaskWindows(ProgressForm.Handle);
      ProgressForm.Show;

      {Initialize inputfile}
      //CloseFile(olddf^.DatFile);
      olddf^.Datfile.Free;  //§§§
      olddf^.Datfile:=NIL;  //§§§
      AssignFile(OldRecFile,olddf^.RECFilename);
      Reset(OldRecFile);
      FOR n:=0 TO olddf^.FieldList.Count DO
        ReadLn(OldRecFile,tmpS);
      {filepointer in OldRecFile now points to first record}

      NewDf^.EpiInfoFieldNaming:=OldDf^.EpiInfoFieldNaming;
      NewDf^.FileLabel:=OldDf^.FileLabel;

      {Copy fields from OldDf to NewDf}
      FOR n:=0 TO OldDf^.FieldList.Count-1 DO
        BEGIN
          OldField:=PeField(OldDf^.FieldList.Items[n]);
          New(NewField);
          NewField^:=OldField^;
          ResetCheckProperties(NewField);
          NewField^.FOriginalQuest:=NewField^.FQuestion;
          NewField^.FLength:=0;
          NewDf^.FieldList.Add(NewField);
          IF NewField^.Felttype<>ftQuestion THEN INC(NewDf^.NumFields);
        END;

      //Get maximum width by scanning data
      FOR CurRec:=1 TO OldDf^.NumRecords DO
        BEGIN
          IF ProgressStep(OldDf^.NumRecords*2,CurRec) THEN
            BEGIN
              ProgressForm.pBar.Position:=CurRec;
              Application.ProcessMessages;
              IF UserAborts THEN
                BEGIN
                  IF eDlg(Lang(23602),mtConfirmation,[mbYes,mbNo],0)=mrYes THEN     //'Abort compress datafile?'
                    BEGIN
                      CloseFile(OldRecFile);
                      Exit;
                    END
                  ELSE UserAborts:=False;
                END;
            END;
          eReadOnlyNextRecord(OldDf,OldRecFile);
          FOR n:=0 TO OldDf^.FieldList.Count-1 DO
            BEGIN
              OldField:=PeField(OldDf^.FieldList.Items[n]);
              NewField:=PeField(NewDf^.FieldList.Items[n]);
              IF (OldField^.Felttype<>ftQuestion) THEN
                BEGIN
                  tmpS:=trim(OldField^.FFieldText);
                  IF Length(tmpS)>NewField^.FLength THEN NewField^.FLength:=Length(tmpS);
                END;
            END;  //for n
        END;  //for CurRec

      FOR n:=0 TO OldDf^.FieldList.Count-1 DO
        BEGIN
          NewField:=PeField(NewDf^.FieldList.Items[n]);
          IF (NewField^.Felttype<>ftQuestion) AND (NewField^.FLength=0)
          THEN NewField^.FLength:=PeField(OldDf^.FieldList.Items[n])^.FLength;
        END;

      IF NOT PeekCreateDatafile(NewDf) THEN
        BEGIN
          ErrorMsg(Format(Lang(20756),[NewDf^.RECFilename])+#13#13+Lang(23604));  //20756=Error creating temporary output file %s  23604=Compress datafile terminates
          Exit;
        END;

      {Prepare NewRecFile to WriteNextRecord}
      AssignFile(NewRecFile,NewDf^.RECFilename);
      Append(NewRecFile);

      {Initialize inputfile}
      Reset(OldRecFile);
      FOR n:=0 TO olddf^.FieldList.Count DO
        ReadLn(OldRecFile,tmpS);
      OldDf^.CurRecord:=1;
      {filepointer in OldRecFile now points to first record}

      {Transfer data from OldRecFile to NewRecFile}
      FOR CurRec:=1 TO OldDf^.NumRecords DO
        BEGIN
          IF ProgressStep(OldDf^.NumRecords*2,CurRec+OldDf^.NumRecords) THEN
            BEGIN
              ProgressForm.pBar.Position:=CurRec+OldDf^.NumRecords;
              Application.ProcessMessages;
              IF UserAborts THEN
                BEGIN
                  IF eDlg(Lang(23602),mtConfirmation,[mbYes,mbNo],0)=mrYes THEN     //'Abort compress datafile?'
                    BEGIN
                      CloseFile(OldRecFile);
                      CloseFile(NewRecFile);
                      DeleteFile(NewDf^.RECFilename);
                      Exit;
                    END
                  ELSE UserAborts:=False;
                END;
            END;
          eReadOnlyNextRecord(OldDf,OldRecFile);
          FOR n:=0 TO OldDf^.FieldList.Count-1 DO
            BEGIN
              OldField:=PeField(OldDf^.FieldList.Items[n]);
              IF OldField^.Felttype<>ftQuestion THEN
                BEGIN
                  NewField:=PeField(NewDf^.FieldList.Items[n]);
                  NewField^.FFieldText:=trim(OldField^.FFieldText);
                END;  //if not ftQuestion
            END;  //for n
          NewDf^.CurRecDeleted:=OldDf^.CurRecDeleted;
          WriteNextRecord(NewDf,NewRecFile);
        END;  //for CurRec

      CloseFile(NewRecFile);
      CloseFile(OldRecFile);
      tmpS:=ChangeFileExt(olddf^.RECFilename,'')+'.old.rec';
      IF FileExists(tmpS) THEN tmpBool:=Deletefile(tmpS);
      Rename(OldRecFile,tmpS);
      Rename(NewRecFile,OldDf^.RECFilename);

      eDlg(Format(Lang(23606),[OldDf^.RECFilename,tmpS]),mtInformation,[mbOK],0);  //'Datafile %s compressed by narrowing input fields to fit current data.~~The orginal datafile renamed to %s'

    FINALLY
      EnableTaskWindows(WindowList);
      ProgressForm.Free;
    END;
  FINALLY
    DisposeDatafilePointer(OldDf);
    DisposeDatafilePointer(NewDf);
  END;
end;


procedure TMainForm.fys1Click(Sender: TObject);
VAR
  prog: String;
begin
  Prog:=ExtractFileDir(ParamStr(0))+'\FysFiler.Exe';
  IF FileExists(Prog)
  THEN ExecuteFile(Prog,'',ExtractFileDir(ParamStr(0)),SW_SHOW)
  ELSE eDlg(Format('Programmet %s kan ikke findes',[Prog]),mtError,[mbOK],0);   //The file %s does not exist.
end;

procedure TMainForm.ShowRelateTreeMenuItemClick(Sender: TObject);
VAR
  n,t:Integer;
  MumDf,df: PDatafileInfo;
  topFile: String;
  topFileNode,MumNode: TTreeNode;
  CurMum: Integer;
begin
  IF RelateMothers=NIL THEN Exit;
  IF RelateTreeCount>0 THEN
    BEGIN
      IF RelateTreeForm.HostDockSite=NIL THEN
        BEGIN
          RelateTreeForm.BringToFront;
          Exit;
        END
      ELSE
        BEGIN
          RelateTreeForm.Close;
          Exit;
        END;
    END;
  INC(RelateTreeCount);
  RelateNodes:=TList.Create;   //Each member of RelateNodes corresponds to a member of RelateFiles
  FOR n:=0 TO RelateFiles.Count-1 DO
    RelateNodes.Add(NIL);
  RelateTreeForm:=TRelateTreeForm.Create(Application);
  WITH RelateTreeForm DO
    BEGIN
      RelateTree.Images:=RelateTreeImages;
      //RelateTree.HideSelection:=False;
      MumDf:=PDatafileInfo(RelateMothers.Items[0]);
      df:=PDatafileInfo(Relatefiles.Objects[0]);
      TopFile:=MumDf^.RECFilename;
      TopFileNode:=RelateTree.Items.AddChild(NIL,ExtractFilename(MumDf^.RECFilename));
      TopFileNode.ImageIndex:=0;
      TopFileNode.SelectedIndex:=1;
      TopFileNode.StateIndex:=-1;
      TopFileNode.Data:=Pointer(MumDf);
      RelateNodes.Items[0]:=Pointer(RelateTree.Items.AddChild(TopFileNode,ExtractFilename(df^.RECFilename)));
      TTreeNode(RelateNodes.Items[0]).Data:=Pointer(df);
      TTreeNode(RelateNodes.Items[0]).SelectedIndex:=1;
      TTreeNode(RelateNodes.Items[0]).StateIndex:=-1;
      FOR CurMum:=1 TO RelateMothers.Count-1 DO
        BEGIN
          //Get MumNode
          MumDf:=PDatafileInfo(RelateMothers.Items[CurMum]);
          IF MumDf^.RECFilename=TopFile THEN MumNode:=TopFileNode
          ELSE
            BEGIN
              t:=RelateFiles.IndexOf(AnsiLowerCase(MumDf^.RECFilename));  //get index in relateFiles AND in RelateNodes
              MumNode:=TTreeNode(RelateNodes.Items[t]);
              MumNode.Data:=Pointer(MumDf);
            END;
          //Add child to tree and to RelateNodes
          df:=PDatafileInfo(Relatefiles.Objects[CurMum]);
          RelateNodes.Items[CurMum]:=Pointer(RelateTree.Items.AddChild(MumNode,ExtractFilename(df^.RECFilename)));
          TTreeNode(RelateNodes.Items[CurMum]).Data:=Pointer(df);
          TTreeNode(RelateNodes.Items[CurMum]).SelectedIndex:=1;
          TTreeNode(RelateNodes.Items[CurMum]).StateIndex:=-1;
        END;  //for CurMum
    END;  //with
  IF (RelateTreeDock<0) OR (RelateTreeDock>2) THEN RelateTreeDock:=1;
  IF RelateTreeRect.Top+RelateTreeRect.Bottom>10 THEN
    BEGIN
      RelateTreeForm.BoundsRect:=RelateTreeRect;
      RelateTreeForm.UndockHeight:=RelateTreeRect.Bottom-RelateTreeRect.Top;
      RelateTreeForm.UndockWidth:=RelateTreeRect.Right-RelateTreeRect.Left;
    END;
  CASE RelateTreeDock OF
    1: BEGIN
         RelateTreeForm.ManualDock(LeftDockPanel,nil,alClient);
         LeftSplitter.Visible:=True;
       END;
    2: BEGIN
         RelateTreeForm.ManualDock(RightDockPanel,nil,alClient);
         RightSplitter.Visible:=True;
       END;
  END;  //case
  RelateTreeForm.Show;
end;

procedure TMainForm.LeftDockPanelDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  (Sender AS TPanel).Width:=OldDockPanelWidth;
  IF Source.Control.Parent=NIL THEN Source.Control.Parent:=self;
  IF Sender=LeftDockPanel THEN
    BEGIN
      LeftSplitter.Left:=LeftDockPanel.Left+LeftDockPanel.width+LeftSplitter.width;
      LeftSplitter.Visible:=True;
    END
  ELSE
    BEGIN
      RightSplitter.Left:=RightDocKPanel.Left-RightSplitter.Width;
      RightSplitter.Visible:=True;
    END;
end;


procedure TMainForm.LeftDockPanelUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
begin
  OldDockPanelWidth:=(Sender AS TPanel).Width;
  (Sender AS TPanel).Width:=0;
  LeftSplitter.Visible:=False;
  RightSplitter.Visible:=False;
end;

procedure TMainForm.TabCtrlChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  (Sender AS TTabControl).Tag:=(Sender AS TTabControl).TabIndex;
end;

procedure TMainForm.Colortable1Click(Sender: TObject);
begin
  ColorTabelForm:=TColorTabelForm.Create(self);
  TRY
    ColorTabelForm.ShowModal;
  FINALLY
    ColorTabelForm.Free;
  END;
end;

procedure TMainForm.Window1Click(Sender: TObject);
begin
  IF (RelateTreeCount>0) AND (ShowRelateTreeMenuItem.Visible) THEN
    BEGIN
      IF RelateTreeForm.HostDockSite<>NIL
      THEN ShowRelateTreeMenuItem.Caption:=Lang(1622)  //1622=Hide relate tree
      ELSE ShowRelateTreeMenuItem.Caption:=Lang(1620);  //1620=Show relate tree;
    END
  ELSE ShowRelateTreeMenuItem.Caption:=Lang(1620);  //1620=Show relate tree;
end;

procedure TMainForm.btnFindPanelCloseClick(Sender: TObject);
VAR
  ADataForm: TDataForm;
  theDf: PDataFileInfo;
begin
  IF (ActiveMDIChild is TDataForm) THEN
    BEGIN
      ADataForm:=(ActiveMDIChild as TDataForm);
      theDf:=ADataForm.df;
      IF theDf^.IsFinding THEN QuitFindByExample(theDf);
    END;
end;

procedure TMainForm.btnFindForwardClick(Sender: TObject);
begin
//  IF (ActiveMDIChild is TDataForm) THEN
//    (ActiveMDIChild as TDataForm).Findrecord2Click(Sender);
end;

procedure TMainForm.btnFindEditClick(Sender: TObject);
begin
  IF (ActiveMDIChild is TDataForm) THEN
    (ActiveMDIChild as TDataForm).FindEditClick(Sender);
end;

procedure TMainForm.btnFindNewClick(Sender: TObject);
begin
  IF (ActiveMDIChild is TDataForm) THEN
    (ActiveMDIChild as TDataForm).FindNewClick(Sender);
end;

procedure TMainForm.LocalHomepageLabelClick(Sender: TObject);
begin
  ExecuteFile('http://www.epidata.dk','', ExtractFileDir(ParamStr(0)), SW_SHOW);
end;

procedure TMainForm.Viewer1Click(Sender: TObject);
VAR
  AGrid: TGridForm;
  df: PDatafileInfo;
  n: Integer;
  tmpStr: String;
begin
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),   //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      MakeDatafileBtn.Down:=False;
      Exit;
    END;
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF NOT OpenDialog1.Execute THEN Exit;
  GetDatafilePointer(df);
  df^.RECFilename:=OpenDialog1.FileName;
  AddToRecentFiles(df^.RECFilename);
  IF NOT PeekDatafile(df) THEN Exit;
  df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
  df^.HasCheckFile:=FileExists(df^.CHKFilename);
  IF df^.HasCheckFile THEN IF NOT PeekApplyCheckFile(df,tmpStr) THEN
    BEGIN
      ErrorMsg(Lang(3212)+#13+Lang(3210));   //3212=The check file has one or more errors.3210=Could not apply checks.
      Exit;
    END;


  TRY
    LockWindowUpdate(MainForm.Handle);
    AGrid:=TGridForm.Create(MainForm);
    AGrid.FormStyle:=fsMDIChild;
    AGrid.BorderStyle:=bsSizeable;
    AGrid.borderIcons:=[biSystemMenu,biMinimize,biMaximize];
    AGrid.GridContent:=gcViewer;
    AGrid.WindowState:=wsMaximized;
    AGrid.Grid1.OnDrawCell:=AGrid.Grid1DrawCell;

    AGrid.df:=df;
    IF df^.IndexCount>0 THEN
      BEGIN
        ApplyIndex(df);
        InitSortIndex(df);
      END;
    IF (ViewerSortByRec=False) AND (df^.IndexCount>0) THEN
      BEGIN
        AGrid.SortByRec:=False;
      END;

   AGrid.Grid1.RowCount:=df^.NumRecords+1;
  //  FOR n:=1 TO df^.NumRecords DO
  //    IF AGrid.SortByRec THEN AGrid.Grid1.Cells[0,n]:=IntToStr(n)   //  AGrid.AddRecord(n)
  //    ELSE AGrid.Grid1.Cells[0,n]:=IntToStr(ReadIndexNoFromSortIndex(df,n));     //AGrid.AddRecord(ReadIndexNoFromSortIndex(df,n));
    //AGrid.StopAdding;
    //AGrid.Grid1.RowCount:=AGrid.Grid1.RowCount-1;
        LockWindowUpdate(0);
    //AGrid.Show;
  FINALLY
    //DisposeDatafilePointer(df);
    //AGrid.Free;
  END;

end;

procedure TMainForm.Zipfiles1Click(Sender: TObject);
begin
  IF Sender=ZipFiles1 THEN DoZip
  ELSE DoUnzip;    //in ZipFormUnit
end;

procedure TMainForm.IntroduktiontoEpiData1Click(Sender: TObject);
VAR
  ReadFilename:TFilename;
begin
  ReadFilename:=ExtractFileDir(ParamStr(0))+'\epdintro.pdf';
  IF NOT UsesEnglish AND (Lang(105)<>'**105**')
  THEN ReadFilename:=ExtractFileDir(ParamStr(0))+'\epdintro_'+Lang(105)+'.pdf';
  IF NOT FileExists(ReadFilename) THEN ReadFilename:=ExtractFileDir(ParamStr(0))+'\epdintro.pdf';
  IF FileExists(ReadFilename)
  THEN ExecuteFile(ReadFilename,'', ExtractFileDir(ParamStr(0)), SW_SHOW)
  ELSE ErrorMsg(Lang(20216));   //'The ReadMe.rtf file was not found.~~Please get an updated version of EpiData at www.EpiData.dk'
end;


procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  IF IsZipping THEN
    BEGIN
      CanClose:=False;
      eDlg(Lang(50308),mtWarning,[mbOK],0);  //'Please wait.'#13'Archive operation is still in progess.'
    END;
end;

procedure TMainForm.Doubleentry1Click(Sender: TObject);
VAR
  w,n,n2:Integer;
  HeaderLine,tmpS,OldRecFileKey,s: String;
  tmpBool:Boolean;
  OldRec: TextFile;
  NumFields,NewRecNumFields: Integer;
  OldRecHasEpiInfoNaming:Boolean;
  RecLines: TStringList;
  df:PDatafileInfo;
  HasVarlabels:Boolean;
  Afield:PeField;
begin
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),    //'Only %d datafiles can be open at the same time.'
      [MaxNumberOfDatafiles]));
      MakeDatafileBtn.Down:=False;
      Exit;
    END;
  OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.rec');
  tmpS:=OpenDialog1.Title;
  OpenDialog1.Title:=Lang(25010);   //Select datafile to validate with double entry
  tmpBool:=OpenDialog1.Execute;
  OpenDialog1.Title:=tmpS;
  IF NOT tmpBool THEN Exit;
  TRY
    AssignFile(OldRec,OpenDialog1.Filename);
    Reset(OldRec);
  EXCEPT
    ErrorMsg(Format(Lang(20108),[OpenDialog1.Filename])   //Datafile %s could not be opened.
      +#13+Lang(20208));  //Please check if the file is in use and that the filename is legal.
    Exit;
  END;
  AddToRecentFiles(OpenDialog1.Filename);
  TRY
    CopyDatafileForm:=TCopyDatafileForm.Create(MainForm);
  EXCEPT
    CopyDatafileForm.Free;
    ErrorMsg(Format(Lang(20204),[921]));  //Out of memory (reference code %d)
    CloseFile(OldRec);
    Exit;
  END;
  ReadLn(OldRec,HeaderLine);
  tmpS:=COPY(HeaderLine,1,POS(' ',HeaderLine)-1);
  IF IsInteger(tmpS) THEN NumFields:=StrToInt(tmpS)
  ELSE
    BEGIN
      CloseFile(OldRec);
      ErrorMsg(Format(Lang(20112),[OpenDialog1.Filename]));  //'Incorrect format of datafile %s.'
      CopyDatafileForm.Free;
      Exit;
    END;
  CopyDatafileForm.OldRecFilenameLabel.Caption:=OpenDialog1.Filename;
  tmpS:=ChangefileExt(OpenDialog1.Filename,'_dbl.rec');
  CopyDatafileForm.NewRecFilenameEdit.Text:=tmpS;
  CopyDatafileForm.Caption:=Lang(25012);    //'Create data file - double entry verification'
  CopyDatafileForm.NewDatafileGroup.Caption:=Lang(25014);    //'New datafile for double entry'
  CopyDatafileForm.DontCopyTextFields.Caption:=Lang(25016);   //'Ignore &textfields in double entry';
  copydatafileForm.DoCopyCheckFile.Visible:=False;
  CopyDatafileForm.HelpBtn.Visible:=False;
  CopyDatafileForm.checkMatchbyKeyfield.Visible:=True;
  CopyDatafileForm.MatchOldAndNewPath:=true;

  OldRecfileKey:='';
  n:=pos('~kq:',HeaderLine);
  IF n>0 THEN
    BEGIN
      //Datafile contains a crypt-key
      n2:=pos(':kq~',HeaderLine);
      IF (n2>0) AND (n2>n) THEN OldRecfileKey:=copy(HeaderLine,n+4,n2-n-4);
    END;

  n:=Pos('FILELABEL: ',AnsiUpperCase(HeaderLine));
  IF n<>0 THEN
    BEGIN
      CopyDatafileForm.OldRecDatafileLabel.Caption:=Copy(HeaderLine,n+Length('FILELABEL: '),Length(HeaderLine));
      CopyDatafileForm.NewRecDatafileLabel.Text:=CopyDatafileForm.OldRecDatafileLabel.Caption;
    END
  ELSE
    BEGIN
      CopyDatafileForm.OldRecDatafileLabel.Caption:=Lang(20604);   //'[none]'
      CopyDatafileForm.NewRecDatafileLabel.Text:='';
    END;
  IF Pos(' VLAB',HeaderLine)>0 THEN OldRecHasEpiInfoNaming:=False ELSE OldRecHasEpiInfoNaming:=True;
  CloseFile(OldRec);
  GetDatafilePointer(df);
  df^.RECFilename:=OpenDialog1.FileName;
  TRY
    IF (NOT PeekDatafile(df)) THEN
      BEGIN
        ErrorMsg(Format(Lang(20112),[OpenDialog1.Filename]));  //'Incorrect format of datafile %s.'
        CopyDatafileForm.Free;
        Exit;
      END;
    //Make fieldnamelist
    w:=0;
    FOR n:=0 TO df^.FieldList.Count-1 DO
      BEGIN
        AField:=PeField(df^.FieldList.Items[n]);
        IF AField^.Felttype<>ftQuestion THEN
          BEGIN
            IF Length(trim(AField^.FName))>w THEN w:=Length(trim(AField^.FName));
            IF (trim(AField^.FVariableLabel)<>'')
            AND (LowerCase(trim(AField^.FVariableLabel))<>LowerCase(trim(AField^.FName))) THEN HasVarLabels:=True;
          END;
      END;
    df^.FieldNamesList:=TStringList.Create;
    FOR n:=0 TO df^.FieldList.Count-1 DO
      BEGIN
        AField:=PeField(df^.FieldList.Items[n]);
        IF AField^.FeltType<>ftQuestion THEN
          BEGIN
            //IF HasVarLabels
            //THEN s:=Format('%-'+IntToStr(w)+'s - %s',[trim(Afield^.FName),trim(AField^.FVariableLabel)])
            //ELSE s:=Format('%-'+IntToStr(w)+'s  ',[trim(AField^.FName)]);
            //IF AField^.FIndex>0 THEN s:=s+' (KEY '+IntToStr(AField^.FIndex)+')';
            s:=Format('%-'+IntToStr(w)+'s  ',[trim(AField^.FName)]);
            df^.FieldNamesList.AddObject(s,TObject(n));
          END;
      END;
    CopyDatafileForm.FieldList.Assign(df^.FieldNamesList);
  FINALLY
    DisposeDatafilePointer(df);
  END;  //try..finally

  //Re-open the original datafile
  AssignFile(OldRec,OpenDialog1.Filename);
  Reset(OldRec);
  ReadLn(OldRec,tmpS);

  IF CopyDatafileForm.ShowModal=mrOK THEN
    BEGIN
      RecLines:=TStringList.Create;
      RecLines.Append(HeaderLine);
      NewRecNumFields:=0;
      FOR n:=1 TO NumFields DO
        BEGIN
          ReadLn(OldRec,tmpS);
          INC(NewRecNumFields);
          RecLines.Append(tmpS);
        END;  //for
      tmpS:=IntToStr(NewRecNumFields)+' 1';
      IF (NOT OldRecHasEpiInfoNaming) THEN tmpS:=tmpS+' VLAB';
      IF OldRecfileKey<>'' THEN tmpS:=tmpS+' ~kq:'+OldRecfileKey+':kq~';
      IF trim(CopyDatafileForm.NewRecDatafileLabel.Text)<>''
      THEN tmpS:=tmpS+' Filelabel: '+CopyDatafileForm.NewRecDatafileLabel.Text;
      RecLines[0]:=tmpS;
      IF FileExists(ChangeFileExt(OpenDialog1.Filename,'.chk')) THEN
        BEGIN
          TRY
            CopyFile(ChangeFileExt(OpenDialog1.Filename,'.chk'),
            ChangeFileExt(CopyDatafileForm.NewRecFilenameEdit.Text,'.chk'));
          EXCEPT
            eDlg(format(Lang(21002),    //'The checkfile %s could not be copied'
            [ChangeFileExt(CopyDatafileForm.NewRecFilenameEdit.Text,'.chk')]),
            mtWarning,[mbOK],0);
          END;  //try..Except
        END;  //if
      TRY
        RecLines.SaveToFile(CopyDatafileForm.NewRecFilenameEdit.Text);
        //Now make the db-config file
        RecLines.Clear;
        RecLines.Append('dbfile='+ExtractFileName(OpenDialog1.FileName));
        IF CopyDatafileForm.DontCopyTextFields.Checked
        THEN RecLines.Append('text=ignore')
        ELSE RecLines.Append('text=check');
        IF CopyDatafileForm.MatchFieldNo<>-1 THEN
          BEGIN
            RecLines.Append('keyfield='+InttoStr(CopyDatafileForm.MatchFieldNo));
            RecLines.Append('keyfieldname='+CopyDatafileForm.MatchField);
          END;
        RecLines.SaveToFile(ChangeFileExt(CopyDatafileForm.NewRecFilenameEdit.Text,'.dbc'));
        AddToRecentFiles(CopyDatafileForm.NewRecFilenameEdit.Text);
        tmpS:=Format(Lang(25018),                    //'Structure in %s'#13'copied to %s'
              [OpenDialog1.Filename,CopyDatafileForm.NewRecFilenameEdit.Text]) +
              #13#13 + format(Lang(25020),[ExtractFilename(CopyDataFileForm.NewRecFilenameEdit.Text)]);  //'Enter data for double entry verification~in %s'
        eDlg(tmpS,mtInformation,[mbOK],0);
      EXCEPT
        ErrorMsg(Format(Lang(21006),    //'Error saving the new datafile with the name %s'
        [CopyDatafileForm.NewRecFilenameEdit.Text]));
      END;
      RecLines.Free;
    END;  //if showModal
  CloseFile(OldRec);
  CopyDatafileForm.Free;
end;

Procedure TMainForm.TranslateEvent(stringnumber:Integer; origstring:string; VAR transstring:string);
BEGIN
  transstring:=Lang(stringnumber);
END;

procedure TMainForm.EpiDataAnalysis1Click(Sender: TObject);
var
  prog: string;
begin
  Prog:=ExtractFileDir(ParamStr(0))+'\EpiDataStat.Exe';
  IF FileExists(Prog)
  THEN ExecuteFile(Prog,'',ExtractFileDir(ParamStr(0)),SW_SHOW)
  ELSE eDlg(Format(Lang(22126),[Prog]),mtError,[mbOK],0);   //22126=The file %s does not exist.
end;

end.
