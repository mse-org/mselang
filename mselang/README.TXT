MSElang   2013-11-01 mse
=======
In the beginning of 2013 I decided to make an own compiler for the MSEide+MSEgui project and started to experiment. The reason is the development direction of Delphi since Delphi 7 which makes it less suitable for my tasks and knowing that Free Pascal is closely following the same direction.

The design goals
----------------
Ultimate goal is to build the most productive universal programming environment, usable from programming of microcontrollers to MSEgui projects.

1. Simple.
Reduce the language concepts one has to learn to the minimum, make them as orthogonal as possible.

2. Readable.
MSElang programs should read like a letter.

3. Easy to learn.
Because of 1. and 2. it should be suitable for pupils as first programming language.

4. Powerful
Allow to go down to the bare metal, it has pointers and pointer arithmetic. ;-)
Object orientated high level programming.

5. Fast running
State of the art optimizations.

6. Fast compiling
While defining the language keep in mind how it can be implemented efficiently.

The Steps
---------
At the beginning MSElang will be the language currently used in MSEgui project, a subset of Delphi 7 and FPC 2.6.2. Later syntax changes are possible.
In order to develop and test the front-end there first will be an intermediate code interpreter which can be used in MSEifi projects and in MSEgui report generator. Most likely there will be not much effort invested to make it fast at runtime but compiletime must be lightning fast.
Later native code back-ends and a simple RTL will be added.

The time frame
--------------
3..5 years until a usable interpreter, additional 3..5 years for one or two native backends.

Experiments up to now
---------------------
Currently I am experimenting how to make a fast and nonetheless easy maintainable compiler frontend . Some ideas:

- There is a syntax generator program which transforms a grammar into Pascal structures. Example:

starttoken definition:
@whitespace
 ' ',#$0d,#$0a

macro:
{whitespace}
"@whitespace,
 '{$',directive-^*
 '{',comment0-^*
 '//',linecomment0-^*"

more starttokens:
@keywordstart
 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p'
 'q','r','s','t','u','v','w','x','y','z'
 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'
 'Q','R','S','T','U','V','W','X','Y','Z'
@identstart
 '_',@keywordstart
@num
 '0','1','2','3','4','5','6','7','8','9'

...

a contextline with branches:
start,nounit,
 ${whitespace} 
 'unit'.,unit0-

a transition context with a handler procedure:
nounit,,handlenouniterror

more contexts:
unit0,nounitname,handlenounitnameerror
 ${whitespace}
 @identstart,ident^*,unit1
nounitname,,handlenounitnameerror
unit1,unit2,setunitname
unit2,semicolonexpected,
 ${whitespace}
 ';',start1-

...

transforms to the Pascal structures:

const
 tks_none = 0;
 tks_classes = $2468ACF1;
 tks_private = $48D159E3;
 tks_protected = $91A2B3C6;
 tks_public = $2345678C;
 tks_published = $468ACF19;
 tk_unit = $8D159E33;
 tk_uses = $1A2B3C66;
 tk_implementation = $345678CD;
 tk_const = $68ACF19B;
 tk_var = $D159E337;
 tk_type = $A2B3C66E;
...
 tokens: array[0..25] of string = ('',
  '.classes','.private','.protected','.public','.published',
  'unit','uses','implementation','const','var','type','procedure','begin',
  'dumpelements','abort','end','if','then','else','record','class','private',
  'protected','public','published');

 tokenids: array[0..25] of identty = (
  $00000000,$2468ACF1,$48D159E3,$91A2B3C6,$2345678C,$468ACF19,$8D159E33,
  $1A2B3C66,$345678CD,$68ACF19B,$D159E337,$A2B3C66E,$45678CDD,$8ACF19BB,
  $159E3376,$2B3C66ED,$5678CDDB,$ACF19BB7,$59E3376E,$B3C66EDD,$678CDDBA,
  $CF19BB75,$9E3376EB,$3C66EDD6,$78CDDBAD,$F19BB75B);

var
 startco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; 
               pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'start');
 nounitco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; 
               pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'nounit');
 unit0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; 
               pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'unit0');
 nounitnameco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; 
               pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'nounitname');
 unit1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; 
               pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'unit1');
 unit2co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; 
               pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'unit2');
...
const
 bstart: array[0..5] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @unit0co); stack: nil; 
     keyword: $8D159E33{'unit'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bunit0: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @identco); stack: @unit1co; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bunit2: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @start1co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
...

- There is a small language independent kernel function in compiler which parses the source based on the above language data structure and calls the language specific handler procedures. Because it is small, the kernel can be highly optimised, even coding it in assembler or implementing in an FPGA should be possible.

- There is a central element hash list where the data and function structure of the program is stored. Hierarchy is handled by storing the sum of the element ID's up to the root, possible collisions must be handled by checking the path ID's.

- The data of unit implementation sections can be released with a mark/release mechanism in order to free not anymore used elements.

- Text tokens and keywords get a hash and a unique ID while reading the source. The ID is a random number in order to minimize conflicts in the central element hash list.

- The compiler kernel maintains a single context stack, the context handler procedures use the stack to store intermediate information and the central element hash list for persistent data.

Thoughts for a future syntax
----------------------------
- records, objects and classes could be unified in a single concept.
- instead of "begin"/"end" there could be a mandatory "end" in structured statements.

What will not be implemented
----------------------------
- Macros.
- Generics/templates, there will be functionality which makes them unnecessary.
- "codepage aware AnsiStrings". ;-)
 
Martin
