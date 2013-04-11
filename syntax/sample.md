This is a sample markdown file for testing syntax.vim. The highlighting in this file should be consistent with what is generated when ran through the Markdown Dingus (whatever a "dingus" is) at <http://daringfireball.net/projects/markdown/dingus>.

- - - -

ITALICS

- - - -



abc
_ abc_

  _abc_

 ab*c
  
  *abc*

_abc

  def_

Abc _123_:

abc _under\_score_
abc
_ abc_aa_

  _  abc_

_ab
cde_

_abc _
The 2nd underscore in the line above is ignored as the end of italics because its surrounded by spaces._

_abc _

Neither 'abc' above or this line are italicized because of the transition to another paragraph._
This line is also not italic because, although the end of the previous line has an underscore, and this line is in the same paragraph, you can't start italics at the end of a line._

Below, 'cd' is italicized across a line because they're still in the same paragraph.
_ ab_c
d_abc

Below, the 'c' is not italicized across a line like the previous example because the '\_' on the 2nd line starts with a non-word char.
_ ab_c
_abc

Unlike the above example, there *is* a valid ending '\_', so it creates italics.
_ ab_c
_abc_

_ ab_c
 _

  _abc_
