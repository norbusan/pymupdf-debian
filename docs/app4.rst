.. _Appendix 4:

================================================
Appendix 4: Assorted Technical Information
================================================

.. _Base-14-Fonts:

PDF Base 14 Fonts
---------------------
The following 14 builtin font names **must be supported by every PDF viewer** application. They are available as a dictionary, which maps their full names amd their abbreviations in lower case to the full font basename. Whereever a **fontname** must be provided in PyMuPDF, any **key or value** from the dictionary may be used::

    In [2]: fitz.Base14_fontdict
    Out[2]:
    {'courier': 'Courier',
    'courier-oblique': 'Courier-Oblique',
    'courier-bold': 'Courier-Bold',
    'courier-boldoblique': 'Courier-BoldOblique',
    'helvetica': 'Helvetica',
    'helvetica-oblique': 'Helvetica-Oblique',
    'helvetica-bold': 'Helvetica-Bold',
    'helvetica-boldoblique': 'Helvetica-BoldOblique',
    'times-roman': 'Times-Roman',
    'times-italic': 'Times-Italic',
    'times-bold': 'Times-Bold',
    'times-bolditalic': 'Times-BoldItalic',
    'symbol': 'Symbol',
    'zapfdingbats': 'ZapfDingbats',
    'helv': 'Helvetica',
    'heit': 'Helvetica-Oblique',
    'hebo': 'Helvetica-Bold',
    'hebi': 'Helvetica-BoldOblique',
    'cour': 'Courier',
    'coit': 'Courier-Oblique',
    'cobo': 'Courier-Bold',
    'cobi': 'Courier-BoldOblique',
    'tiro': 'Times-Roman',
    'tibo': 'Times-Bold',
    'tiit': 'Times-Italic',
    'tibi': 'Times-BoldItalic',
    'symb': 'Symbol',
    'zadb': 'ZapfDingbats'}

In contrast to their obligation, not all PDF viewers support these fonts correctly and completely -- this is especially true for Symbol and ZapfDingbats. Also, the glyph (visual) images will be specific to every reader.

To see how these fonts can be used -- including the **CJK built-in** fonts -- look at the table in :meth:`Page.insertFont`.

------------

.. _AdobeManual:

Adobe PDF References
---------------------------

This PDF Reference manual published by Adobe is frequently quoted throughout this documentation. It can be viewed and downloaded from `here <http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_reference_1-7.pdf>`_.

There is a newer version of this, which can be found `here <https://www.adobe.com/content/dam/acom/en/devnet/pdf/pdfs/PDF32000_2008.pdf>`_. Redaction annotations are an example contained in this one, but not in the earlier version.

------------

.. _SequenceTypes:

Using Python Sequences as Arguments in PyMuPDF
------------------------------------------------
When PyMuPDF objects and methods require a Python **list** of numerical values, other Python **sequence types** are also allowed. Python classes are said to implement the **sequence protocol**, if they have a *__getitem__()* method.

This basically means, you can interchangeably use Python *list* or *tuple* or even *array.array*, *numpy.array* and *bytearray* types in these cases.

For example, specifying a sequence *"s"* in any of the following ways

* *s = [1, 2]*
* *s = (1, 2)*
* *s = array.array("i", (1, 2))*
* *s = numpy.array((1, 2))*
* *s = bytearray((1, 2))*

will make it usable in the following example expressions:

* *fitz.Point(s)*
* *fitz.Point(x, y) + s*
* *doc.select(s)*

Similarly with all geometry objects :ref:`Rect`, :ref:`IRect`, :ref:`Matrix` and :ref:`Point`.

Because all PyMuPDF geometry classes themselves are special cases of sequences, they (with the exception of :ref:`Quad` -- see below) can be freely used where numerical sequences can be used, e.g. as arguments for functions like *list()*, *tuple()*, *array.array()* or *numpy.array()*. Look at the following snippet to see this work.

>>> import fitz, array, numpy as np
>>> m = fitz.Matrix(1, 2, 3, 4, 5, 6)
>>>
>>> list(m)
[1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
>>>
>>> tuple(m)
(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
>>>
>>> array.array("f", m)
array('f', [1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
>>>
>>> np.array(m)
array([1., 2., 3., 4., 5., 6.])

.. note:: :ref:`Quad` is a Python sequence object as well and has a length of 4. Its items however are :data:`point_like` -- not numbers. Therefore, the above remarks do not apply.

------------

.. _ReferenialIntegrity:

Ensuring Consistency of Important Objects in PyMuPDF
------------------------------------------------------------
PyMuPDF is a Python binding for the C library MuPDF. While a lot of effort has been invested by MuPDF's creators to approximate some sort of an object-oriented behavior, they certainly could not overcome basic shortcomings of the C language in that respect.

Python on the other hand implements the OO-model in a very clean way. The interface code between PyMuPDF and MuPDF consists of two basic files: *fitz.py* and *fitz_wrap.c*. They are created by the excellent SWIG tool for each new version.

When you use one of PyMuPDF's objects or methods, this will result in excution of some code in *fitz.py*, which in turn will call some C code compiled with *fitz_wrap.c*.

Because SWIG goes a long way to keep the Python and the C level in sync, everything works fine, if a certain set of rules is being strictly followed. For example: **never access** a :ref:`Page` object, after you have closed (or deleted or set to *None*) the owning :ref:`Document`. Or, less obvious: **never access** a page or any of its children (links or annotations) after you have executed one of the document methods *select()*, *deletePage()*, *insertPage()* ... and more.

But just no longer accessing invalidated objects is actually not enough: They should rather be actively deleted entirely, to also free C-level resources (meaning allocated memory).

The reason for these rules lies in the fact that there is a hierachical 2-level one-to-many relationship between a document and its pages and also between a page and its links / annotations. To maintain a consistent situation, any of the above actions must lead to a complete reset -- in **Python and, synchronously, in C**.

SWIG cannot know about this and consequently does not do it.

The required logic has therefore been built into PyMuPDF itself in the following way.

1. If a page "loses" its owning document or is being deleted itself, all of its currently existing annotations and links will be made unusable in Python, and their C-level counterparts will be deleted and deallocated.

2. If a document is closed (or deleted or set to *None*) or if its structure has changed, then similarly all currently existing pages and their children will be made unusable, and corresponding C-level deletions will take place. "Structure changes" include methods like *select()*, *delePage()*, *insertPage()*, *insertPDF()* and so on: all of these will result in a cascade of object deletions.

The programmer will normally not realize any of this. If he, however, tries to access invalidated objects, exceptions will be raised.

Invalidated objects cannot be directly deleted as with Python statements like *del page* or *page = None*, etc. Instead, their *__del__* method must be invoked.

All pages, links and annotations have the property *parent*, which points to the owning object. This is the property that can be checked on the application level: if *obj.parent == None* then the object's parent is gone, and any reference to its properties or methods will raise an exception informing about this "orphaned" state.

A sample session:

>>> page = doc[n]
>>> annot = page.firstAnnot
>>> annot.type                    # everything works fine
[5, 'Circle']
>>> page = None                   # this turns 'annot' into an orphan
>>> annot.type
<... omitted lines ...>
RuntimeError: orphaned object: parent is None
>>>
>>> # same happens, if you do this:
>>> annot = doc[n].firstAnnot     # deletes the page again immediately!
>>> annot.type                    # so, 'annot' is 'born' orphaned
<... omitted lines ...>
RuntimeError: orphaned object: parent is None

This shows the cascading effect:

>>> doc = fitz.open("some.pdf")
>>> page = doc[n]
>>> annot = page.firstAnnot
>>> page.rect
fitz.Rect(0.0, 0.0, 595.0, 842.0)
>>> annot.type
[5, 'Circle']
>>> del doc                       # or doc = None or doc.close()
>>> page.rect
<... omitted lines ...>
RuntimeError: orphaned object: parent is None
>>> annot.type
<... omitted lines ...>
RuntimeError: orphaned object: parent is None

.. note:: Objects outside the above relationship are not included in this mechanism. If you e.g. created a table of contents by *toc = doc.getToC()*, and later close or change the document, then this cannot and does not change variable *toc* in any way. It is your responsibility to refresh such variables as required.

------------

.. _FormXObject:

Design of Method :meth:`Page.showPDFpage`
--------------------------------------------

Purpose and Capabilities
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The method displays an image of a ("source") page of another PDF document within a specified rectangle of the current ("containing", "target") page.

* **In contrast** to :meth:`Page.insertImage`, this display is vector-based and hence remains accurate across zooming levels.
* **Just like** :meth:`Page.insertImage`, the size of the display is adjusted to the given rectangle.

The following variations of the display are currently supported:

* Bool parameter *keep_proportion* controls whether to maintain the aspect ratio (default) or not.
* Rectangle parameter *clip* restricts the visible part of the source page rectangle. Default is the full page.
* float *rotation* rotates the display by an arbitrary angle (degrees). If the angle is not an integer multiple of 90, only 2 of the 4 corners may be positioned on the target border if also *keep_proportion* is true.
* Bool parameter *overlay* controls whether to put the image on top (foreground, default) of current page content or not (background).

Use cases include (but are not limited to) the following:

1. "Stamp" a series of pages of the current document with the same image, like a company logo or a watermark.
2. Combine arbitrary input pages into one output page to support “booklet” or double-sided printing (known as "4-up", "n-up").
3. Split up (large) input pages into several arbitrary pieces. This is also called “posterization”, because you e.g. can split an A4 page horizontally and vertically, print the 4 pieces enlarged to separate A4 pages, and end up with an A2 version of your original page.

Technical Implementation
~~~~~~~~~~~~~~~~~~~~~~~~~

This is done using PDF **"Form XObjects"**, see section 4.9 on page 355 of :ref:`AdobeManual`. On execution of a *Page.showPDFpage(rect, src, pno, ...)*, the following things happen:

    1. The :data:`resources` and :data:`contents` objects of page *pno* in document *src* are copied over to the current document, jointly creating a new **Form XObject** with the following properties. The PDF :data:`xref` number of this object is returned by the method.

        a. */BBox* equals */Mediabox* of the source page
        b. */Matrix* equals the identity matrix *[1 0 0 1 0 0]*
        c. */Resources* equals that of the source page. This involves a “deep-copy” of hierarchically nested other objects (including fonts, images, etc.). The complexity involved here is covered by MuPDF’s grafting [#f1]_ technique functions.
        d. This is a stream object type, and its stream is an exact copy of the combined data of the source page's */Contents* objects.

        This step is only executed once per shown source page. Subsequent displays of the same page only create pointers (done in next step) to this object.

    2. A second **Form XObject** is then created which the target page uses to invoke the display. This object has the following properties:

        a. */BBox* equals the */CropBox* of the source page (or *clip*).
        b. */Matrix* represents the mapping of */BBox* to the target rectangle.
        c. */XObject* references the previous XObject via the fixed name *fullpage*.
        d. The stream of this object contains exactly one fixed statement: */fullpage Do*.

    3. The :data:`resources` and :data:`contents` objects of the target page are now modified as follows.

        a. Add an entry to the */XObject* dictionary of */Resources* with the name *fzFrm<n>* (with n chosen such that this entry is unique on the page).
        b. Depending on *overlay*, prepend or append a new object to the page's */Contents* array, containing the statement *q /fzFrm<n> Do Q*.


.. _RedirectMessages:

Redirecting Error and Warning Messages
--------------------------------------------
Since MuPDF version 1.16 error and warning messages can be redirected via an official plugin.

PyMuPDF will put error messages to *sys.stderr* prefixed with the string "mupdf:". Warnings are internally stored and can be accessed via *fitz.TOOLS.mupdf_warnings()*. There also is a function to empty this store.


.. rubric:: Footnotes

.. [#f1] MuPDF supports "deep-copying" objects between PDF documents. To avoid duplicate data in the target, it uses so-called "graftmaps", like a form of scratchpad: for each object to be copied, its :data:`xref` number is looked up in the graftmap. If found, copying is skipped. Otherwise, the new :data:`xref` is recorded and the copy takes place. PyMuPDF makes use of this technique in two places so far: :meth:`Document.insertPDF` and :meth:`Page.showPDFpage`. This process is fast and very efficient, because it prevents multiple copies of typically large and frequently referenced data, like images and fonts. However, you may still want to consider using garbage collection (option 4) in any of the following cases:

    1. The target PDF is not new / empty: grafting does not check for resource types that already existed (e.g. images, fonts) in the target document
    2. Using :meth:`Page.showPDFpage` for more than one source document: each grafting occurs **within one source** PDF only, not across multiple.
