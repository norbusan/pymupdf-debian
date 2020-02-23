.. _Page:

================
Page
================

Class representing a document page. A page object is created by :meth:`Document.loadPage` or, equivalently, via indexing the document like *doc[n]* - it has no independent constructor.

There is a parent-child relationship between a document and its pages. If the document is closed or deleted, all page objects (and their respective children, too) in existence will become unusable ("orphaned"): If a page property or method is being used, an exception is raised.

Several page methods have a :ref:`Document` counterpart for convenience. At the end of this chapter you will find a synopsis.

Adding Page Content
-------------------
This is available for PDF documents only. There are basically two groups of methods:

1. **Methods making permanent changes.** This group contains *insertText()*, *insertTextbox()* and all *draw*()* methods. They provide "stand-alone", shortcut versions for the same-named methods of the :ref:`Shape` class. For detailed descriptions have a look in that chapter. Some remarks on the relationship between the :ref:`Page` and :ref:`Shape` methods:

  * In contrast to :ref:`Shape`, the results of page methods are not interconnected: they do not share properties like colors, line width / dashing, morphing, etc.
  * Each page *draw*()* method invokes a :meth:`Shape.finish` and then a :meth:`Shape.commit` and consequently accepts the combined arguments of both these methods.
  * Text insertion methods (*insertText()* and *insertTextbox()*) do not need :meth:`Shape.finish` and therefore only invoke :meth:`Shape.commit`.

2. **Methods adding annotations.** Annotations can be added, modified and deleted without necessarily having full document permissions. Their effect is **not permanent** in the sense, that manipulating them does not require to rebuild the document. **Adding** and **deleting** annotations are page methods. **Changing** existing annotations is possible via methods of the :ref:`Annot` class.

================================ ================================================
**Method / Attribute**            **Short Description**
================================ ================================================
:meth:`Page.addCaretAnnot`       PDF only: add a caret annotation
:meth:`Page.addCircleAnnot`      PDF only: add a circle annotation
:meth:`Page.addFileAnnot`        PDF only: add a file attachment annotation
:meth:`Page.addFreetextAnnot`    PDF only: add a text annotation
:meth:`Page.addHighlightAnnot`   PDF only: add a "highlight" annotation
:meth:`Page.addInkAnnot`         PDF only: add an ink annotation
:meth:`Page.addLineAnnot`        PDF only: add a line annotation
:meth:`Page.addPolygonAnnot`     PDF only: add a polygon annotation
:meth:`Page.addPolylineAnnot`    PDF only: add a multi-line annotation
:meth:`Page.addRectAnnot`        PDF only: add a rectangle annotation
:meth:`Page.addRedactAnnot`      PDF only: add a redation annotation
:meth:`Page.addSquigglyAnnot`    PDF only: add a "squiggly" annotation
:meth:`Page.addStampAnnot`       PDF only: add a "rubber stamp" annotation
:meth:`Page.addStrikeoutAnnot`   PDF only: add a "strike-out" annotation
:meth:`Page.addTextAnnot`        PDF only: add a comment
:meth:`Page.addUnderlineAnnot`   PDF only: add an "underline" annotation
:meth:`Page.addWidget`           PDF only: add a PDF Form field
:meth:`Page.annot_names`         PDF only: a list of annotation and widget names
:meth:`Page.annots`              return a generator over the annots on the page
:meth:`Page.apply_redactions`    PDF olny: process redaction annots on the page
:meth:`Page.bound`               rectangle of the page
:meth:`Page.deleteAnnot`         PDF only: delete an annotation
:meth:`Page.deleteLink`          PDF only: delete a link
:meth:`Page.drawBezier`          PDF only: draw a cubic Bezier curve
:meth:`Page.drawCircle`          PDF only: draw a circle
:meth:`Page.drawCurve`           PDF only: draw a special Bezier curve
:meth:`Page.drawLine`            PDF only: draw a line
:meth:`Page.drawOval`            PDF only: draw an oval / ellipse
:meth:`Page.drawPolyline`        PDF only: connect a point sequence
:meth:`Page.drawRect`            PDF only: draw a rectangle
:meth:`Page.drawSector`          PDF only: draw a circular sector
:meth:`Page.drawSquiggle`        PDF only: draw a squiggly line
:meth:`Page.drawZigzag`          PDF only: draw a zig-zagged line
:meth:`Page.getFontList`         PDF only: get list of used fonts
:meth:`Page.getImageBbox`        PDF only: get bbox of inserted image
:meth:`Page.getImageList`        PDF only: get list of used images
:meth:`Page.getLinks`            get all links
:meth:`Page.getPixmap`           create a :ref:`Pixmap`
:meth:`Page.getSVGimage`         create a page image in SVG format
:meth:`Page.getText`             extract the page's text
:meth:`Page.getTextPage`         create a TextPage for the page
:meth:`Page.insertFont`          PDF only: insert a font for use by the page
:meth:`Page.insertImage`         PDF only: insert an image
:meth:`Page.insertLink`          PDF only: insert a link
:meth:`Page.insertText`          PDF only: insert text
:meth:`Page.insertTextbox`       PDF only: insert a text box
:meth:`Page.links`               return a generator of the links on the page
:meth:`Page.load_annot`          PDF only: load an annotation identified by its name
:meth:`Page.loadLinks`           return the first link on a page
:meth:`Page.newShape`            PDF only: start a new :ref:`Shape`
:meth:`Page.searchFor`           search for a string
:meth:`Page.setCropBox`          PDF only: modify the visible page
:meth:`Page.setRotation`         PDF only: set page rotation
:meth:`Page.showPDFpage`         PDF only: display PDF page image
:meth:`Page.updateLink`          PDF only: modify a link
:meth:`Page.widgets`             return a generator over the fields on the page
:attr:`Page.CropBox`             the page's /CropBox
:attr:`Page.CropBoxPosition`     displacement of the /CropBox
:attr:`Page.firstAnnot`          first :ref:`Annot` on the page
:attr:`Page.firstLink`           first :ref:`Link` on the page
:attr:`Page.firstWidget`         first widget (form field) on the page
:attr:`Page.MediaBox`            the page's /MediaBox
:attr:`Page.MediaBoxSize`        bottom-right point of /MediaBox
:attr:`Page.number`              page number
:attr:`Page.parent`              owning document object
:attr:`Page.rect`                rectangle (mediabox) of the page
:attr:`Page.rotation`            PDF only: page rotation
:attr:`Page.xref`                PDF :data:`xref`
================================ ================================================

**Class API**

.. class:: Page

   .. method:: bound()

      Determine the rectangle (before transformation) of the page. Same as property :attr:`Page.rect` below. For PDF documents this **usually** also coincides with objects */MediaBox* and */CropBox*, but not always. The best description hence is probably "*/CropBox*, transformed such that top-left coordinates are (0, 0)". Also see attributes :attr:`Page.CropBox` and :attr:`Page.MediaBox`.

      :rtype: :ref:`Rect`

   .. method:: addCaretAnnot(point)

      *(New in version 1.16.0)*
      
      PDF only: Add a caret icon. A caret annotation is a visual symbol that indicates the presence of text edits.

      :arg point_like point: the top left point of a 20 x 20 rectangle containing the MuPDF-provided icon.

      :rtype: :ref:`Annot`
      :returns: the created annotation.

      .. image:: images/img-caret-annot.jpg
         :scale: 70

   .. method:: addTextAnnot(point, text, icon="Note")

      PDF only: Add a comment icon ("sticky note") with accompanying text.

      :arg point_like point: the top left point of a 20 x 20 rectangle containing the MuPDF-provided "note" icon.

      :arg str text: the commentary text. This will be shown on double clicking or hovering over the icon. May contain any Latin characters.
      :arg str icon: *(new in version 1.16.0)* choose one of "Note" (default), "Comment", "Help", "Insert", "Key", "NewParagraph", "Paragraph" as the visual symbol for the embodied text [#f4]_.

      :rtype: :ref:`Annot`
      :returns: the created annotation.

   .. index::
      pair: color; addFreetextAnnot
      pair: fontname; addFreetextAnnot
      pair: fontsize; addFreetextAnnot
      pair: rect; addFreetextAnnot
      pair: rotate; addFreetextAnnot

   .. method:: addFreetextAnnot(rect, text, fontsize=12, fontname="helv", text_color=0, fill_color=1, rotate=0)

      PDF only: Add text in a given rectangle.

      :arg rect_like rect: the rectangle into which the text should be inserted. Text is automatically wrapped to a new line at box width. Lines not fitting into the box will be invisible.

      :arg str text: the text. May contain any Latin characters.
      :arg float fontsize: the font size. Default is 12.
      :arg str fontname: the font name. Default is "Helv". Accepted alternatives are "Cour", "TiRo", "ZaDb" and "Symb". The name may be abbreviated to the first two characters, like "Co" for "Cour". Lower case is also accepted.
      :arg sequence,float text_color: *(new in version 1.16.0)* the text color. Default is black.

      :arg sequence,float fill_color: *(new in version 1.16.0)* the fill color. Default is white.


      :arg int rotate: the text orientation. Accepted values are 0, 90, 270, invalid entries are set to zero.

      :rtype: :ref:`Annot`
      :returns: the created annotation. Color properties **can only be changed** using special parameters of :meth:`Annot.update`. There, you can also set a border color different from the text color.

   .. method:: addFileAnnot(pos, buffer, filename, ufilename=None, desc=None, icon="PushPin")

      PDF only: Add a file attachment annotation with a "PushPin" icon at the specified location.

      :arg point_like pos: the top-left point of a 18x18 rectangle containing the MuPDF-provided "PushPin" icon.

      :arg bytes,bytearray,BytesIO buffer: the data to be stored (actual file content, any data, etc.).

         Changed in version 1.14.13 *io.BytesIO* is now also supported.

      :arg str filename: the filename to associate with the data.
      :arg str ufilename: the optional PDF unicode version of filename. Defaults to filename.
      :arg str desc: an optional description of the file. Defaults to filename.
      :arg str icon: *(new in version 1.16.0)* choose one of "PushPin" (default), "Graph", "Paperclip", "Tag" as the visual symbol for the attached data [#f4]_.

      :rtype: :ref:`Annot`
      :returns: the created annotation. Use methods of :ref:`Annot` to make any changes.

   .. method:: addInkAnnot(list)

      PDF only: Add a "freehand" scribble annotation.

      :arg sequence list: a list of one or more lists, each containing :data:`point_like` items. Each item in these sublists is interpreted as a :ref:`Point` through which a connecting line is drawn. Separate sublists thus represent separate drawing lines.

      :rtype: :ref:`Annot`
      :returns: the created annotation in default appearance (black line of width 1). Use annotation methods with a subsequent :meth:`Annot.update` to modify.

   .. method:: addLineAnnot(p1, p2)

      PDF only: Add a line annotation.

      :arg point_like p1: the starting point of the line.

      :arg point_like p2: the end point of the line.

      :rtype: :ref:`Annot`
      :returns: the created annotation. It is drawn with line color black and line width 1. To change, or attach other information (like author, creation date, line properties, colors, line ends, etc.) use methods of :ref:`Annot`. The **rectangle** is automatically created to contain both points, each one surrounded by a circle of radius 3 (= 3 * line width) to make room for any line end symbols. Use methods of :ref:`Annot` to make any changes.

   .. method:: addRectAnnot(rect)

   .. method:: addCircleAnnot(rect)

      PDF only: Add a rectangle, resp. circle annotation.

      :arg rect_like rect: the rectangle in which the circle or rectangle is drawn, must be finite and not empty. If the rectangle is not equal-sided, an ellipse is drawn.

      :rtype: :ref:`Annot`
      :returns: the created annotation. It is drawn with line color black, no fill color and line width 1. Use methods of :ref:`Annot` to make any changes.

   .. method:: addRedactAnnot(quad)

      PDF only: *(new in version 1.16.11)* Add a redaction annotation. A redaction annotation identifies content that is intended to be removed from the document. Adding such an annotation is the first of two steps. It makes visible what will be removed in the subsequent step, :meth:`Page.apply_redactions`.

      :arg quad_like,rect_like quad: specifies the (rectangular) area to be removed which is always equal to the annotation rectangle. This may be a :data:`rect_like` or :data:`quad_like` object. If a quad is specified, then the envelopping rectangle is taken.

      :rtype: :ref:`Annot`
      :returns: the created annotation. The appearance of a redaction annotation cannot be changed (except for the annotation rectangle). A redaction is displayed as a crossed-out transparent rectangle with red lines.

      .. image:: images/img-redact.jpg

   .. method:: addPolylineAnnot(points)

   .. method:: addPolygonAnnot(points)

      PDF only: Add an annotation consisting of lines which connect the given points. A **Polygon's** first and last points are automatically connected, which does not happen for a **PolyLine**. The **rectangle** is automatically created as the smallest rectangle containing the points, each one surrounded by a circle of radius 3 (= 3 * line width). The following shows a 'PolyLine' that has been modified with colors and line ends.

      :arg list points: a list of :data:`point_like` objects.

      :rtype: :ref:`Annot`
      :returns: the created annotation. It is drawn with line color black, no fill color and line width 1. Use methods of :ref:`Annot` to make any changes to achieve something like this:

      .. image:: images/img-polyline.png
         :scale: 70

   .. method:: addUnderlineAnnot(quads)

   .. method:: addStrikeoutAnnot(quads)

   .. method:: addSquigglyAnnot(quads)

   .. method:: addHighlightAnnot(quads)

      PDF only: These annotations are normally used for marking text which has previously been located (for example via :meth:`searchFor`). But the actual presence of text within the specified area(s) is neither checked nor required. So you are free to "mark" anything.

      Standard colors are chosen per annotation type: **yellow** for highlighting, **red** for strike out, **green** for underlining, and **magenta** for wavy underlining.

      The methods convert the argument into a list of :ref:`Quad` objects. The **annotation** rectangle is calculated to envelop these quadrilaterals.

      .. note:: :meth:`searchFor` supports :ref:`Quad` objects as an output option. Hence the following two statements are sufficient to locate and mark every occurrence of string "pymupdf" with **one common** annotation::

           >>> quads = page.searchFor("pymupdf", hit_max=100, quads=True)
           >>> page.addHighlightAnnot(quads)

      :arg rect_like,quad_like,list,tuple quads: Changed in version 1.14.20 the rectangles or quads containing the to-be-marked text (locations). A list or tuple must consist of :data:`rect_like` or :data:`quad_like` items (or even a mixture of either). You should prefer using quads, because this will automatically support non-horizontal text and avoid rectangle-to-quad conversion effort.

      :rtype: :ref:`Annot`
      :returns: the created annotation. To change colors, set the "stroke" color accordingly (:meth:`Annot.setColors`) and then perform an :meth:`Annot.update`.

      .. image:: images/img-markers.jpg
         :scale: 80

   .. method:: addStampAnnot(rect, stamp=0)

      PDF only: Add a "rubber stamp" like annotation to e.g. indicate the document's intended use ("DRAFT", "CONFIDENTIAL", etc.).

      :arg rect_like rect: rectangle where to place the annotation.

      :arg int stamp: id number of the stamp text. For available stamps see :ref:`StampIcons`.

      .. note::

         * The stamp's text (e.g. "APPROVED") and its border line will automatically be sized and put centered in the given rectangle. :attr:`Annot.rect` is automatically calculated to fit and will usually be smaller than this parameter. The appearance can be changed using :meth:`Annot.setOpacity` and by setting the "stroke" color (no "fill" color supported).
         
         * This can conveniently be used to create watermark images: on a temporary PDF page create a stamp annotation with a low opacity value, make a pixmap from it with *alpha=True* (and potentially also rotate it), discard the temporary PDF page and use the pixmap with :meth:`insertImage` for your target PDF.


      .. image :: images/img-stampannot.jpg
         :scale: 80

   .. method:: addWidget(widget)

      PDF only: Add a PDF Form field ("widget") to a page. This also **turns the PDF into a Form PDF**. Because of the large amount of different options available for widgets, we have developed a new class :ref:`Widget`, which contains the possible PDF field attributes. It must be used for both, form field creation and updates.

      :arg widget: a :ref:`Widget` object which must have been created upfront.
      :type widget: :ref:`Widget`

      :returns: a widget annotation.

   .. method:: deleteAnnot(annot)

      PDF only: Delete the specified annotation from the page and return the next one.

      Changed in version 1.16.6 The removal will now include any bound 'Popup' or response annotations and related objects.

      :arg annot: the annotation to be deleted.
      :type annot: :ref:`Annot`

      :rtype: :ref:`Annot`
      :returns: the annotation following the deleted one. Please remember that physical removal will take place only with saving to a new file with a positive garbage collection option.

   .. method:: apply_redactions(mark=False)

      PDF only: *(new in version 1.16.11)* Remove **text content** in areas marked by some redaction annotation. The respective areas are either emptied or filled with black (*mark* set to *True*). This method also deletes all redaction annotations of the page.

      :returns: *True* if at least one redaction annotation has been found / processed, *False* otherwise.

      .. note::
         Text contained in a redaction rectangle will be **physically** removed from the page's :data:`contents` objects (only) and no longer appear in e.g. text extractions. Images, other annotations or content in embedded PDF pages are unaffected.

         Decision to remove text is made on a by-character level. A character is removed if the bottom-left corner of its boundary box is contained in a redaction rectangle. Hence it may happen, that a character is removed even if the better part of it is outside the redaction rect or, vice versa, **not** removed, even if most of it lies inside the rect.

   .. method:: deleteLink(linkdict)

      PDF only: Delete the specified link from the page. The parameter must be an **original item** of :meth:`getLinks()` (see below). The reason for this is the dictionary's *"xref"* key, which identifies the PDF object to be deleted.

      :arg dict linkdict: the link to be deleted.

   .. method:: insertLink(linkdict)

      PDF only: Insert a new link on this page. The parameter must be a dictionary of format as provided by :meth:`getLinks()` (see below).

      :arg dict linkdict: the link to be inserted.

   .. method:: updateLink(linkdict)

      PDF only: Modify the specified link. The parameter must be a (modified) **original item** of :meth:`getLinks()` (see below). The reason for this is the dictionary's *"xref"* key, which identifies the PDF object to be changed.

      :arg dict linkdict: the link to be modified.

   .. method:: getLinks()

      Retrieves **all** links of a page.

      :rtype: list
      :returns: A list of dictionaries. For a description of the dictionary entries see below. Always use this or the :meth:`Page.links` method if you intend to make changes to the links of a page.

   .. method:: links(kinds=None)

      *(New in version 1.16.4)*
      
      Return a generator over the page's links. The results equal the entries of :meth:`Page.getLinks`.

      :arg sequence kinds: a sequence of integers to down-select to one or more link kinds. Default is all links. Example: *kinds=(fitz.LINK_GOTO,)* will only return internal links.

      :rtype: generator
      :returns: an entry of :meth:`Page.getLinks()` for each iteration.

   .. method:: annots(types=None)

      *(New in version 1.16.4)*
      
      Return a generator over the page's annotations.

      :arg sequence types: a sequence of integers to down-select to one or annotation types. Default is all annotations. Example: *types=(fitz.PDF_ANNOT_FREETEXT, fitz.PDF_ANNOT_TEXT)* will only return 'FreeText' and 'Text' annotations.

      :rtype: generator
      :returns: an :ref:`Annot` for each iteration.

   .. method:: widgets(types=None)

      *(New in version 1.16.4)*
      
      Return a generator over the page's form fields.

      :arg sequence types: a sequence of integers to down-select to one or more widget types. Default is all form fields. Example: *types=(fitz.PDF_WIDGET_TYPE_TEXT,)* will only return 'Text' fields.

      :rtype: generator
      :returns: a :ref:`Widget` for each iteration.


   .. index::
      pair: border_width; insertText
      pair: color; insertText
      pair: encoding; insertText
      pair: fill; insertText
      pair: fontfile; insertText
      pair: fontname; insertText
      pair: fontsize; insertText
      pair: morph; insertText
      pair: overlay; insertText
      pair: render_mode; insertText
      pair: rotate; insertText

   .. method:: insertText(point, text, fontsize=11, fontname="helv", fontfile=None, idx=0, color=None, fill=None, render_mode=0, border_width=1, encoding=TEXT_ENCODING_LATIN, rotate=0, morph=None, overlay=True)

      PDF only: Insert text starting at :data:`point_like` *point*. See :meth:`Shape.insertText`.

   .. index::
      pair: align; insertTextbox
      pair: border_width; insertTextbox
      pair: color; insertTextbox
      pair: encoding; insertTextbox
      pair: expandtabs; insertTextbox
      pair: fill; insertTextbox
      pair: fontfile; insertTextbox
      pair: fontname; insertTextbox
      pair: fontsize; insertTextbox
      pair: morph; insertTextbox
      pair: overlay; insertTextbox
      pair: render_mode; insertTextbox
      pair: rotate; insertTextbox

   .. method:: insertTextbox(rect, buffer, fontsize=11, fontname="helv", fontfile=None, idx=0, color=None, fill=None, render_mode=0, border_width=1, encoding=TEXT_ENCODING_LATIN, expandtabs=8, align=TEXT_ALIGN_LEFT, charwidths=None, rotate=0, morph=None, overlay=True)

      PDF only: Insert text into the specified :data:`rect_like` *rect*. See :meth:`Shape.insertTextbox`.

   .. index::
      pair: closePath; drawLine
      pair: color; drawLine
      pair: dashes; drawLine
      pair: fill; drawLine
      pair: lineCap; drawLine
      pair: lineJoin; drawLine
      pair: lineJoin; drawLine
      pair: morph; drawLine
      pair: overlay; drawLine
      pair: width; drawLine

   .. method:: drawLine(p1, p2, color=None, width=1, dashes=None, lineCap=0, lineJoin=0, overlay=True, morph=None)

      PDF only: Draw a line from *p1* to *p2* (:data:`point_like` \s). See :meth:`Shape.drawLine`.

   .. index::
      pair: breadth; drawZigzag
      pair: closePath; drawZigzag
      pair: color; drawZigzag
      pair: dashes; drawZigzag
      pair: fill; drawZigzag
      pair: lineCap; drawZigzag
      pair: lineJoin; drawZigzag
      pair: morph; drawZigzag
      pair: overlay; drawZigzag
      pair: width; drawZigzag

   .. method:: drawZigzag(p1, p2, breadth=2, color=None, width=1, dashes=None, lineCap=0, lineJoin=0, overlay=True, morph=None)

      PDF only: Draw a zigzag line from *p1* to *p2* (:data:`point_like` \s). See :meth:`Shape.drawZigzag`.

   .. index::
      pair: breadth; drawSquiggle
      pair: closePath; drawSquiggle
      pair: color; drawSquiggle
      pair: dashes; drawSquiggle
      pair: fill; drawSquiggle
      pair: lineCap; drawSquiggle
      pair: lineJoin; drawSquiggle
      pair: morph; drawSquiggle
      pair: overlay; drawSquiggle
      pair: width; drawSquiggle

   .. method:: drawSquiggle(p1, p2, breadth=2, color=None, width=1, dashes=None, lineCap=0, lineJoin=0, overlay=True, morph=None)

      PDF only: Draw a squiggly (wavy, undulated) line from *p1* to *p2* (:data:`point_like` \s). See :meth:`Shape.drawSquiggle`.

   .. index::
      pair: closePath; drawCircle
      pair: color; drawCircle
      pair: dashes; drawCircle
      pair: fill; drawCircle
      pair: lineCap; drawCircle
      pair: lineJoin; drawCircle
      pair: morph; drawCircle
      pair: overlay; drawCircle
      pair: width; drawCircle

   .. method:: drawCircle(center, radius, color=None, fill=None, width=1, dashes=None, lineCap=0, lineJoin=0, overlay=True, morph=None)

      PDF only: Draw a circle around *center* (:data:`point_like`) with a radius of *radius*. See :meth:`Shape.drawCircle`.

   .. index::
      pair: closePath; drawOval
      pair: color; drawOval
      pair: dashes; drawOval
      pair: fill; drawOval
      pair: lineCap; drawOval
      pair: lineJoin; drawOval
      pair: morph; drawOval
      pair: overlay; drawOval
      pair: width; drawOval

   .. method:: drawOval(quad, color=None, fill=None, width=1, dashes=None, lineCap=0, lineJoin=0, overlay=True, morph=None)

      PDF only: Draw an oval (ellipse) within the given :data:`rect_like` or :data:`quad_like`. See :meth:`Shape.drawOval`.

   .. index::
      pair: closePath; drawSector
      pair: color; drawSector
      pair: dashes; drawSector
      pair: fill; drawSector
      pair: fullSector; drawSector
      pair: lineCap; drawSector
      pair: lineJoin; drawSector
      pair: morph; drawSector
      pair: overlay; drawSector
      pair: width; drawSector

   .. method:: drawSector(center, point, angle, color=None, fill=None, width=1, dashes=None, lineCap=0, lineJoin=0, fullSector=True, overlay=True, closePath=False, morph=None)

      PDF only: Draw a circular sector, optionally connecting the arc to the circle's center (like a piece of pie). See :meth:`Shape.drawSector`.

   .. index::
      pair: closePath; drawPolyline
      pair: color; drawPolyline
      pair: dashes; drawPolyline
      pair: fill; drawPolyline
      pair: lineCap; drawPolyline
      pair: lineJoin; drawPolyline
      pair: morph; drawPolyline
      pair: overlay; drawPolyline
      pair: width; drawPolyline

   .. method:: drawPolyline(points, color=None, fill=None, width=1, dashes=None, lineCap=0, lineJoin=0, overlay=True, closePath=False, morph=None)

      PDF only: Draw several connected lines defined by a sequence of :data:`point_like` \s. See :meth:`Shape.drawPolyline`.


   .. index::
      pair: closePath; drawBezier
      pair: color; drawBezier
      pair: dashes; drawBezier
      pair: fill; drawBezier
      pair: lineCap; drawBezier
      pair: lineJoin; drawBezier
      pair: morph; drawBezier
      pair: overlay; drawBezier
      pair: width; drawBezier

   .. method:: drawBezier(p1, p2, p3, p4, color=None, fill=None, width=1, dashes=None, lineCap=0, lineJoin=0, overlay=True, closePath=False, morph=None)

      PDF only: Draw a cubic BÃ©zier curve from *p1* to *p4* with the control points *p2* and *p3* (all are :data`point_like` \s). See :meth:`Shape.drawBezier`.

   .. index::
      pair: closePath; drawCurve
      pair: color; drawCurve
      pair: dashes; drawCurve
      pair: fill; drawCurve
      pair: lineCap; drawCurve
      pair: lineJoin; drawCurve
      pair: morph; drawCurve
      pair: overlay; drawCurve
      pair: width; drawCurve

   .. method:: drawCurve(p1, p2, p3, color=None, fill=None, width=1, dashes=None, lineCap=0, lineJoin=0, overlay=True, closePath=False, morph=None)

      PDF only: This is a special case of *drawBezier()*. See :meth:`Shape.drawCurve`.

   .. index::
      pair: closePath; drawRect
      pair: color; drawRect
      pair: dashes; drawRect
      pair: fill; drawRect
      pair: lineCap; drawRect
      pair: lineJoin; drawRect
      pair: morph; drawRect
      pair: overlay; drawRect
      pair: width; drawRect

   .. method:: drawRect(rect, color=None, fill=None, width=1, dashes=None, lineCap=0, lineJoin=0, overlay=True, morph=None)

      PDF only: Draw a rectangle. See :meth:`Shape.drawRect`.

      .. note:: An efficient way to background-color a PDF page with the old Python paper color is

          >>> col = fitz.utils.getColor("py_color")
          >>> page.drawRect(page.rect, color=col, fill=col, overlay=False)

   .. index::
      pair: encoding; insertFont
      pair: fontbuffer; insertFont
      pair: fontfile; insertFont
      pair: fontname; insertFont
      pair: set_simple; insertFont

   .. method:: insertFont(fontname="helv", fontfile=None, fontbuffer=None, set_simple=False, encoding=TEXT_ENCODING_LATIN)

      PDF only: Add a new font to be used by text output methods and return its :data:`xref`. If not already present in the file, the font definition will be added. Supported are the built-in :data:`Base14_Fonts` and the CJK fonts via **"reserved"** fontnames. Fonts can also be provided as a file path or a memory area containing the image of a font file.

      :arg str fontname: The name by which this font shall be referenced when outputting text on this page. In general, you have a "free" choice here (but consult the :ref:`AdobeManual`, page 56, section 3.2.4 for a formal description of building legal PDF names). However, if it matches one of the :data:`Base14_Fonts` or one of the CJK fonts, *fontfile* and *fontbuffer* **are ignored**.

      In other words, you cannot insert a font via *fontfile* / *fontbuffer* and also give it a reserved *fontname*.

      .. note:: A reserved fontname can be specified in any mixture of upper or lower case and still match the right built-in font definition: fontnames "helv", "Helv", "HELV", "Helvetica", etc. all lead to the same font definition "Helvetica". But from a :ref:`Page` perspective, these are **different references**. You can exploit this fact when using different *encoding* variants (Latin, Greek, Cyrillic) of the same font on a page.

      :arg str fontfile: a path to a font file. If used, *fontname* must be **different from all reserved names**.

      :arg bytes/bytearray fontbuffer: the memory image of a font file. If used, *fontname* must be **different from all reserved names**. This parameter would typically be used to transfer fonts between different pages of the same or different PDFs.

      :arg int set_simple: applicable for *fontfile* / *fontbuffer* cases only: enforce treatment as a "simple" font, i.e. one that only uses character codes up to 255.

      :arg int encoding: applicable for the "Helvetica", "Courier" and "Times" sets of :data:`Base14_Fonts` only. Select one of the available encodings Latin (0), Cyrillic (2) or Greek (1). Only use the default (0 = Latin) for "Symbol" and "ZapfDingBats".

      :rytpe: int
      :returns: the :data:`xref` of the installed font.

      .. note:: Built-in fonts will not lead to the inclusion of a font file. So the resulting PDF file will remain small. However, your PDF viewer software is responsible for generating an appropriate appearance -- and there **exist** differences on whether or how each one of them does this. This is especially true for the CJK fonts. But also Symbol and ZapfDingbats are incorrectly handled in some cases. Following are the **Font Names** and their correspondingly installed **Base Font** names:

         **Base-14 Fonts** [#f1]_

         ============= ============================ =========================================
         **Font Name** **Installed Base Font**      **Comments**
         ============= ============================ =========================================
         helv          Helvetica                    normal
         heit          Helvetica-Oblique            italic
         hebo          Helvetica-Bold               bold
         hebi          Helvetica-BoldOblique        bold-italic
         cour          Courier                      normal
         coit          Courier-Oblique              italic
         cobo          Courier-Bold                 bold
         cobi          Courier-BoldOblique          bold-italic
         tiro          Times-Roman                  normal
         tiit          Times-Italic                 italic
         tibo          Times-Bold                   bold
         tibi          Times-BoldItalic             bold-italic
         symb          Symbol                       [#f3]_
         zadb          ZapfDingbats                 [#f3]_
         ============= ============================ =========================================

         **CJK Fonts** [#f2]_ (China, Japan, Korea)

         ============= ============================ =========================================
         **Font Name** **Installed Base Font**      **Comments**
         ============= ============================ =========================================
         china-s       Heiti                        simplified Chinese
         china-ss      Song                         simplified Chinese (serif)
         china-t       Fangti                       traditional Chinese
         china-ts      Ming                         traditional Chinese (serif)
         japan         Gothic                       Japanese
         japan-s       Mincho                       Japanese (serif)
         korea         Dotum                        Korean
         korea-s       Batang                       Korean (serif)
         ============= ============================ =========================================

   .. index::
      pair: filename; insertImage
      pair: keep_proportion; insertImage
      pair: overlay; insertImage
      pair: pixmap; insertImage
      pair: rotate; insertImage
      pair: stream; insertImage

   .. method:: insertImage(rect, filename=None, pixmap=None, stream=None, rotate=0, keep_proportion=True, overlay=True)

      PDF only: Put an image inside the given rectangle. The image can be taken from a pixmap, a file or a memory area - of these parameters **exactly one** must be specified.

         Changed in version 1.14.11 By default, the image keeps its aspect ratio.

      :arg rect_like rect: where to put the image on the page. Only the rectangle part which is inside the page is used. This intersection must be finite and not empty.

         Changed in version 1.14.13 The image is now always placed **centered** in the rectangle, i.e. the center of the image and the rectangle coincide.

      :arg str filename: name of an image file (all formats supported by MuPDF -- see :ref:`ImageFiles`). If the same image is to be inserted multiple times, choose one of the other two options to avoid some overhead.

      :arg bytes,bytearray,io.BytesIO stream: image in memory (all formats supported by MuPDF -- see :ref:`ImageFiles`). This is the most efficient option.
      
         Changed in version 1.14.13 *io.BytesIO* is now also supported.

      :arg pixmap: a pixmap containing the image.
      :type pixmap: :ref:`Pixmap`

      :arg int rotate: *(new in version v1.14.11)* rotate the image. Must be an integer multiple of 90 degrees. If you need a rotation by an arbitrary angle, consider converting the image to a PDF (:meth:`Document.convertToPDF`) first and then use :meth:`Page.showPDFpage` instead.

      :arg bool keep_proportion: *(new in version v1.14.11)* maintain the aspect ratio of the image.

      For a description of *overlay* see :ref:`CommonParms`.

      This example puts the same image on every page of a document::

         >>> doc = fitz.open(...)
         >>> rect = fitz.Rect(0, 0, 50, 50)       # put thumbnail in upper left corner
         >>> img = open("some.jpg", "rb").read()  # an image file
         >>> for page in doc:
               page.insertImage(rect, stream = img)
         >>> doc.save(...)

      .. note::

         1. If that same image had already been present in the PDF, then only a reference to it will be inserted. This of course considerably saves disk space and processing time. But to detect this fact, existing PDF images need to be compared with the new one. This is achieved by storing an MD5 code for each image in a table and only compare the new image's MD5 code against the table entries. Generating this MD5 table, however, is done when the first image is inserted - which therefore may have an extended response time.

         2. You can use this method to provide a background or foreground image for the page, like a copyright, a watermark. Please remember, that watermarks require a transparent image ...

         3. The image may be inserted uncompressed, e.g. if a *Pixmap* is used or if the image has an alpha channel. Therefore, consider using *deflate=True* when saving the file.

         4. The image is stored in the PDF in its original quality. This may be much better than you ever need for your display. In this case consider decreasing the image size before inserting it -- e.g. by using the pixmap option and then shrinking it or scaling it down (see :ref:`Pixmap` chapter). The PIL method *Image.thumbnail()* can also be used for that purpose. The file size savings can be very significant.

         5. The most efficient way to display the same image on multiple pages is another method: :meth:`showPDFpage`. Consult :meth:`Document.convertToPDF` for how to obtain intermediary PDFs usable for that method. Demo script `fitz-logo.py <https://github.com/pymupdf/PyMuPDF/blob/master/demo/fitz-logo.py>`_ implements a fairly complete approach.

   .. index::
      pair: blocks; getText
      pair: dict; getText
      pair: flags; getText
      pair: html; getText
      pair: json; getText
      pair: rawdict; getText
      pair: text; getText
      pair: words; getText
      pair: xhtml; getText
      pair: xml; getText

   .. method:: getText(opt="text", flags=None)

      Retrieves the content of a page in a variety of formats. This is a wrapper for :ref:`TextPage` methods by choosing the output option as follows:

      * "text" -- :meth:`TextPage.extractTEXT`, default
      * "blocks" -- :meth:`TextPage.extractBLOCKS`
      * "words" -- :meth:`TextPage.extractWORDS`
      * "html" -- :meth:`TextPage.extractHTML`
      * "xhtml" -- :meth:`TextPage.extractXHTML`
      * "xml" -- :meth:`TextPage.extractXML`
      * "dict" -- :meth:`TextPage.extractDICT`
      * "json" -- :meth:`TextPage.extractJSON`
      * "rawdict" -- :meth:`TextPage.extractRAWDICT`

      :arg str opt: A string indicating the requested format, one of the above. A mixture of upper and lower case is supported.

         Changed in version 1.16.3 Values "words" and "blocks" are now also accepted.

      :arg int flags: *(new in version 1.16.2)* indicator bits to control whether to include images or how text should be handled with respect to white spaces and ligatures. See :ref:`TextPreserve` for available indicators and :ref:`text_extraction_flags` for default settings.

      :rtype: *str, list, dict*
      :returns: The page's content as a string, list or as a dictionary. Refer to the corresponding :ref:`TextPage` method for details.

      .. note:: You can use this method as a **document conversion tool** from any supported document type (not only PDF!) to one of TEXT, HTML, XHTML or XML documents.

   .. index::
      pair: flags; getTextPage

   .. method:: getTextPage(flags=3)

      *(New in version 1.16.5)*
      
      Create a :ref:`TextPage` for the page. This method avoids using an intermediate :ref:`DisplayList`.

      :arg in flags: indicator bits controlling the content available for subsequent extraction -- see the parameter of :meth:`Page.getText`.

      :returns: :ref:`TextPage`

   .. method:: getFontList(full=False)

      PDF only: Return a list of fonts referenced by the page. Wrapper for :meth:`Document.getPageFontList`.

   .. method:: getImageList(full=False)

      PDF only: Return a list of images referenced by the page. Wrapper for :meth:`Document.getPageImageList`.

   .. method:: getImageBbox(item)

      *(New in version 1.16.0)*
      
      PDF only: Return the boundary box of an image.

      :arg list item: an item of the list :meth:`Page.getImageList` with *full=True* specified.

      :rtype: :ref:`Rect`
      :returns: the boundary box of the image.
         Changed in version 1.16.7 If the page in fact does not display this image, an infinite rectangle is returned now. In previous versions, an exception was raised.

      .. warning:: The method internally cleans the page's */Contents* object(s) using :meth:`Page._cleanContents()`. Please consult its description for implications.

      .. note::

         * Be aware that :meth:`Page.getImageList` may contain "dead" entries, i.e. there may be image references which -- although present in the PDF -- are **not displayed** by this page. In this case an exception is raised.
         * This function is still somewhat **experimental**: it does not yet cover all possibilities of how an image location might have been coded, but instead makes some simplifying assumptions. As a result you occasionally may find the bbox incorrectly calculated. In contrast, image blocks returned by :meth:`Page.getText` ("dict" or "rawdict" options) do contain a correct bbox on the one hand, but on the other hand do **not allow an (easy) identification** of the image as a PDF object. There are however ways to match these information pieces -- please consult the recipes chapter.

   .. index::
      pair: matrix; getSVGimage

   .. method:: getSVGimage(matrix=fitz.Identity)

      Create an SVG image from the page. Only full page images are currently supported.

     :arg matrix_like matrix: a matrix, default is :ref:`Identity`.

     :returns: a UTF-8 encoded string that contains the image. Because SVG has XML syntax it can be saved in a text file with extension *.svg*.

   .. index::
      pair: alpha; getPixmap
      pair: annots; getPixmap
      pair: clip; getPixmap
      pair: colorspace; getPixmap
      pair: matrix; getPixmap

   .. method:: getPixmap(matrix=fitz.Identity, colorspace=fitz.csRGB, clip=None, alpha=False, annots=True)

     Create a pixmap from the page. This is probably the most often used method to create a pixmap.

     :arg matrix_like matrix: default is :ref:`Identity`.
     :arg colorspace: Defines the required colorspace, one of "GRAY", "RGB" or "CMYK" (case insensitive). Or specify a :ref:`Colorspace`, ie. one of the predefined ones: :data:`csGRAY`, :data:`csRGB` or :data:`csCMYK`.
     :type colorspace: str or :ref:`Colorspace`
     :arg irect_like clip: restrict rendering to this area.
     :arg bool alpha: whether to add an alpha channel. Always accept the default *False* if you do not really need transparency. This will save a lot of memory (25% in case of RGB ... and pixmaps are typically **large**!), and also processing time. Also note an **important difference** in how the image will be rendered: with *True* the pixmap's samples area will be pre-cleared with *0x00*. This results in **transparent** areas where the page is empty. With *False* the pixmap's samples will be pre-cleared with *0xff*. This results in **white** where the page has nothing to show.

      Changed in version 1.14.17
         The default alpha value is now *False*.

         * Generated with *alpha=True*

         .. image:: images/img-alpha-1.png


         * Generated with *alpha=False*

         .. image:: images/img-alpha-0.png

     :arg bool annots: *(new in vrsion 1.16.0)* whether to also render any annotations on the page. You can create pixmaps for annotations separately.

     :rtype: :ref:`Pixmap`
     :returns: Pixmap of the page.

   .. method:: annot_names()

      *(New in version 1.16.10)*

      PDF only: return a list of the names of annotations or widgets.

      :rtype: list


   .. method:: load_annot(annot_id)

      *(New in version 1.16.10)*

      PDF only: return the annotation identified by *annot_id* -- its unique name (*/NM*).

      :arg str annot_id: the annotation name.

      :rtype: :ref:`Annot`
      :returns: the annotation or *None*.

   .. method:: loadLinks()

      Return the first link on a page. Synonym of property :attr:`firstLink`.

      :rtype: :ref:`Link`
      :returns: first link on the page (or *None*).

   .. index::
      pair: rotate; setRotation

   .. method:: setRotation(rotate)

      PDF only: Sets the rotation of the page.

      :arg int rotate: An integer specifying the required rotation in degrees. Must be an integer multiple of 90.

   .. index::
      pair: clip; showPDFpage
      pair: keep_proportion; showPDFpage
      pair: overlay; showPDFpage
      pair: rotate; showPDFpage

   .. method:: showPDFpage(rect, docsrc, pno=0, keep_proportion=True, overlay=True, rotate=0, clip=None)

      PDF only: Display a page of another PDF as a **vector image** (otherwise similar to :meth:`Page.insertImage`). This is a multi-purpose method. For example, you can use it to

      * create "n-up" versions of existing PDF files, combining several input pages into **one output page** (see example `4-up.py <https://github.com/pymupdf/PyMuPDF/blob/master/examples/4-up.py>`_),
      * create "posterized" PDF files, i.e. every input page is split up in parts which each create a separate output page (see `posterize.py <https://github.com/pymupdf/PyMuPDF/blob/master/examples/posterize.py>`_),
      * include PDF-based vector images like company logos, watermarks, etc., see `svg-logo.py <https://github.com/pymupdf/PyMuPDF/blob/master/examples/svg-logo.py>`_, which puts an SVG-based logo on each page (requires additional packages to deal with SVG-to-PDF conversions).

      Changed in version 1.14.11
         Parameter *reuse_xref* has been deprecated.

      :arg rect_like rect: where to place the image on current page. Must be finite and its intersection with the page must not be empty.

          Changed in version 1.14.11
             Position the source rectangle centered in this rectangle.

      :arg docsrc: source PDF document containing the page. Must be a different document object, but may be the same file.
      :type docsrc: :ref:`Document`

      :arg int pno: page number (0-based, in *-inf < pno < docsrc.pageCount*) to be shown.

      :arg bool keep_proportion: whether to maintain the width-height-ratio (default). If false, all 4 corners are always positioned on the border of the target rectangle -- whatever the rotation value. In general, this will deliver distorted and /or non-rectangular images.

      :arg bool overlay: put image in foreground (default) or background.

      :arg float rotate: *(new in version 1.14.10)* show the source rectangle rotated by some angle. *Changed in version 1.14.11:* Any angle is now supported.

      :arg rect_like clip: choose which part of the source page to show. Default is the full page, else must be finite and its intersection with the source page must not be empty.

      .. note:: In contrast to method :meth:`Document.insertPDF`, this method does not copy annotations or links, so they are not shown. But all its **other resources (text, images, fonts, etc.)** will be imported into the current PDF. They will therefore appear in text extractions and in :meth:`getFontList` and :meth:`getImageList` lists -- even if they are not contained in the visible area given by *clip*.

      Example: Show the same source page, rotated by 90 and by -90 degrees:

      >>> doc = fitz.open()  # new empty PDF
      >>> page=doc.newPage()  # new page in A4 format
      >>>
      >>> # upper half page
      >>> r1 = fitz.Rect(0, 0, page.rect.width, page.rect.height/2)
      >>>
      >>> # lower half page
      >>> r2 = r1 + (0, page.rect.height/2, 0, page.rect.height/2)
      >>>
      >>> src = fitz.open("PyMuPDF.pdf")  # show page 0 of this
      >>>
      >>> page.showPDFpage(r1, src, 0, rotate=90)
      >>> page.showPDFpage(r2, src, 0, rotate=-90)
      >>> doc.save("show.pdf")

      .. image:: images/img-showpdfpage.jpg
         :scale: 70

   .. method:: newShape()

      PDF only: Create a new :ref:`Shape` object for the page.

      :rtype: :ref:`Shape`
      :returns: a new :ref:`Shape` to use for compound drawings. See description there.

   .. index::
      pair: flags; searchFor
      pair: hit_max; searchFor
      pair: quads; searchFor

   .. method:: searchFor(text, hit_max=16, quads=False, flags=None)

      Searches for *text* on a page. Wrapper for :meth:`TextPage.search`.

      :arg str text: Text to search for. Upper / lower case is ignored. The string may contain spaces.

      :arg int hit_max: Maximum number of occurrences accepted.
      :arg bool quads: Return :ref:`Quad` instead of :ref:`Rect` objects.
      :arg int flags: Control the data extracted by the underlying :ref:`TextPage`. Default is 0 (ligatures are dissolved, white space is replaced with space and excessive spaces are not suppressed).

      :rtype: list

      :returns: A list of :ref:`Rect` \s (resp. :ref:`Quad` \s) each of which  -- **normally!** -- surrounds one occurrence of *text*. **However:** if the search string spreads across more than one line, then a separate item is recorded in the list for each part of the string per line. So, if you are looking for "search string" and the two words happen to be located on separate lines, two entries will be recorded in the list: one for "search" and one for "string".

        .. note:: In this way, the effect supports multi-line text marker annotations.

   .. method:: setCropBox(r)

      PDF only: change the visible part of the page.

      :arg rect_like r: the new visible area of the page.

      After execution, :attr:`Page.rect` will equal this rectangle, shifted to the top-left position (0, 0). Example session:

      >>> page = doc.newPage()
      >>> page.rect
      fitz.Rect(0.0, 0.0, 595.0, 842.0)
      >>>
      >>> page.CropBox                   # CropBox and MediaBox still equal
      fitz.Rect(0.0, 0.0, 595.0, 842.0)
      >>>
      >>> # now set CropBox to a part of the page
      >>> page.setCropBox(fitz.Rect(100, 100, 400, 400))
      >>> # this will also change the "rect" property:
      >>> page.rect
      fitz.Rect(0.0, 0.0, 300.0, 300.0)
      >>>
      >>> # but MediaBox remains unaffected
      >>> page.MediaBox
      fitz.Rect(0.0, 0.0, 595.0, 842.0)
      >>>
      >>> # revert everything we did
      >>> page.setCropBox(page.MediaBox)
      >>> page.rect
      fitz.Rect(0.0, 0.0, 595.0, 842.0)

   .. attribute:: rotation

      PDF only: contains the rotation of the page in degrees and *-1* for other document types.

      :type: int

   .. attribute:: CropBoxPosition

      Contains the displacement of the page's */CropBox* for a PDF, otherwise the top-left coordinates of :attr:`Page.rect`.

      :type: :ref:`Point`

   .. attribute:: CropBox

      The page's */CropBox* for a PDF, else :attr:`Page.rect`.

      :type: :ref:`Rect`

   .. attribute:: MediaBoxSize

      Contains the width and height of the page's */MediaBox* for a PDF, otherwise the bottom-right coordinates of :attr:`Page.rect`.

      :type: :ref:`Point`

   .. attribute:: MediaBox

      The page's */MediaBox* for a PDF, otherwise :attr:`Page.rect`.

      :type: :ref:`Rect`

      .. note:: For most PDF documents and for all other types, *page.rect == page.CropBox == page.MediaBox* is true. However, for some PDFs the visible page is a true subset of */MediaBox*. In this case the above attributes help to correctly locate page elements.

   .. attribute:: firstLink

      Contains the first :ref:`Link` of a page (or *None*).

      :type: :ref:`Link`

   .. attribute:: firstAnnot

      Contains the first :ref:`Annot` of a page (or *None*).

      :type: :ref:`Annot`

   .. attribute:: firstWidget

      Contains the first :ref:`Widget` of a page (or *None*).

      :type: :ref:`Widget`

   .. attribute:: number

      The page number.

      :type: int

   .. attribute:: parent

      The owning document object.

      :type: :ref:`Document`


   .. attribute:: rect

      Contains the rectangle of the page. Same as result of :meth:`Page.bound()`.

      :type: :ref:`Rect`

   .. attribute:: xref

      The page's PDF :data:`xref`. Zero if not a PDF.

      :type: :ref:`Rect`

-----

Description of *getLinks()* Entries
----------------------------------------
Each entry of the *getLinks()* list is a dictionay with the following keys:

* *kind*:  (required) an integer indicating the kind of link. This is one of *LINK_NONE*, *LINK_GOTO*, *LINK_GOTOR*, *LINK_LAUNCH*, or *LINK_URI*. For values and meaning of these names refer to :ref:`linkDest Kinds`.

* *from*:  (required) a :ref:`Rect` describing the "hot spot" location on the page's visible representation (where the cursor changes to a hand image, usually).

* *page*:  a 0-based integer indicating the destination page. Required for *LINK_GOTO* and *LINK_GOTOR*, else ignored.

* *to*:   either a *fitz.Point*, specifying the destination location on the provided page, default is *fitz.Point(0, 0)*, or a symbolic (indirect) name. If an indirect name is specified, *page = -1* is required and the name must be defined in the PDF in order for this to work. Required for *LINK_GOTO* and *LINK_GOTOR*, else ignored.

* *file*: a string specifying the destination file. Required for *LINK_GOTOR* and *LINK_LAUNCH*, else ignored.

* *uri*:  a string specifying the destination internet resource. Required for *LINK_URI*, else ignored.

* *xref*: an integer specifying the PDF :data:`xref` of the link object. Do not change this entry in any way. Required for link deletion and update, otherwise ignored. For non-PDF documents, this entry contains *-1*. It is also *-1* for **all** entries in the *getLinks()* list, if **any** of the links is not supported by MuPDF - see the note below.

Notes on Supporting Links
---------------------------
MuPDF's support for links has changed in **v1.10a**. These changes affect link types :data:`LINK_GOTO` and :data:`LINK_GOTOR`.

Reading (pertains to method *getLinks()* and the *firstLink* property chain)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If MuPDF detects a link to another file, it will supply either a *LINK_GOTOR* or a *LINK_LAUNCH* link kind. In case of *LINK_GOTOR* destination details may either be given as page number (eventually including position information), or as an indirect destination.

If an indirect destination is given, then this is indicated by *page = -1*, and *link.dest.dest* will contain this name. The dictionaries in the *getLinks()* list will contain this information as the *to* value.

**Internal links are always** of kind *LINK_GOTO*. If an internal link specifies an indirect destination, it **will always be resolved** and the resulting direct destination will be returned. Names are **never returned for internal links**, and undefined destinations will cause the link to be ignored.

Writing
~~~~~~~~~

PyMuPDF writes (updates, inserts) links by constructing and writing the appropriate PDF object **source**. This makes it possible to specify indirect destinations for *LINK_GOTOR* **and** *LINK_GOTO* link kinds (pre *PDF 1.2* file formats are **not supported**).

.. warning:: If a *LINK_GOTO* indirect destination specifies an undefined name, this link can later on not be found / read again with MuPDF / PyMuPDF. Other readers however **will** detect it, but flag it as erroneous.

Indirect *LINK_GOTOR* destinations can in general of course not be checked for validity and are therefore **always accepted**.

Homologous Methods of :ref:`Document` and :ref:`Page`
--------------------------------------------------------
This is an overview of homologous methods on the :ref:`Document` and on the :ref:`Page` level.

====================================== =====================================
**Document Level**                     **Page Level**
====================================== =====================================
*Document.getPageFontlist(pno)*        :meth:`Page.getFontList`
*Document.getPageImageList(pno)*       :meth:`Page.getImageList`
*Document.getPagePixmap(pno, ...)*     :meth:`Page.getPixmap`
*Document.getPageText(pno, ...)*       :meth:`Page.getText`
*Document.searchPageFor(pno, ...)*     :meth:`Page.searchFor`
====================================== =====================================

The page number "pno"` is a 0-based integer *-inf < pno < pageCount*.

.. note::

   Most document methods (left column) exist for convenience reasons, and are just wrappers for: *Document[pno].<page method>*. So they **load and discard the page** on each execution.

   However, the first two methods work differently. They only need a page's object definition statement - the page itself will **not** be loaded. So e.g. :meth:`Page.getFontList` is a wrapper the other way round and defined as follows: *page.getFontList == page.parent.getPageFontList(page.number)*.

.. rubric:: Footnotes

.. [#f1] If your existing code already uses the installed base name as a font reference (as it was supported by PyMuPDF versions earlier than 1.14), this will continue to work.

.. [#f2] Not all PDF reader software (including internet browsers and office software) display all of these fonts. And if they do, the difference between the **serifed** and the **non-serifed** version may hardly be noticable. But serifed and non-serifed versions lead to different installed base fonts, thus providing an option to be displayable with your specific PDF viewer.

.. [#f3] Not all PDF readers display these fonts at all. Some others do, but use a wrong character spacing, etc.

.. [#f4] You are generally free to choose any of the :ref:`mupdficons` you consider adequate.
