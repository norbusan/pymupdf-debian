from __future__ import absolute_import, print_function
import sys
from fitz.fitz import *

# define the supported colorspaces for convenience
fitz.csRGB = fitz.Colorspace(fitz.CS_RGB)
fitz.csGRAY = fitz.Colorspace(fitz.CS_GRAY)
fitz.csCMYK = fitz.Colorspace(fitz.CS_CMYK)
csRGB = fitz.csRGB
csGRAY = fitz.csGRAY
csCMYK = fitz.csCMYK

# create the TOOLS object
TOOLS = fitz.Tools()
fitz.TOOLS = TOOLS

if fitz.VersionFitz != fitz.TOOLS.mupdf_version():
    v1 = fitz.VersionFitz.split(".")
    v2 = fitz.TOOLS.mupdf_version().split(".")
    if v1[:-1] != v2[:-1]:
        raise ValueError(
            "MuPDF library mismatch %s <> %s"
            % (fitz.VersionFitz, fitz.TOOLS.mupdf_version())
        )


# copy functions to their respective fitz classes
import fitz.utils

# ------------------------------------------------------------------------------
# Document
# ------------------------------------------------------------------------------
fitz.open = fitz.Document
fitz.Document.getToC = fitz.utils.getToC
fitz.Document._do_links = fitz.utils.do_links
fitz.Document.getPagePixmap = fitz.utils.getPagePixmap
fitz.Document.getPageText = fitz.utils.getPageText
fitz.Document.setMetadata = fitz.utils.setMetadata
fitz.Document.setToC = fitz.utils.setToC
fitz.Document.searchPageFor = fitz.utils.searchPageFor
fitz.Document.newPage = fitz.utils.newPage
fitz.Document.insertPage = fitz.utils.insertPage
fitz.Document.getCharWidths = fitz.utils.getCharWidths

# ------------------------------------------------------------------------------
# Page
# ------------------------------------------------------------------------------
fitz.Page.drawBezier = fitz.utils.drawBezier
fitz.Page.drawCircle = fitz.utils.drawCircle
fitz.Page.drawCurve = fitz.utils.drawCurve
fitz.Page.drawLine = fitz.utils.drawLine
fitz.Page.drawOval = fitz.utils.drawOval
fitz.Page.drawPolyline = fitz.utils.drawPolyline
fitz.Page.drawRect = fitz.utils.drawRect
fitz.Page.drawQuad = fitz.utils.drawQuad
fitz.Page.drawSector = fitz.utils.drawSector
fitz.Page.drawSquiggle = fitz.utils.drawSquiggle
fitz.Page.drawZigzag = fitz.utils.drawZigzag
fitz.Page.getImageBbox = fitz.utils.getImageBbox
fitz.Page.getTextBlocks = fitz.utils.getTextBlocks
fitz.Page.getTextWords = fitz.utils.getTextWords
fitz.Page.getLinks = fitz.utils.getLinks
fitz.Page.getPixmap = fitz.utils.getPixmap
fitz.Page.getText = fitz.utils.getText
fitz.Page.insertLink = fitz.utils.insertLink
fitz.Page.insertTextbox = fitz.utils.insertTextbox
fitz.Page.insertText = fitz.utils.insertText
fitz.Page.searchFor = fitz.utils.searchFor
fitz.Page.showPDFpage = fitz.utils.showPDFpage
fitz.Page.insertImage = fitz.utils.insertImage
fitz.Page.updateLink = fitz.utils.updateLink
fitz.Page.newShape = lambda x: fitz.utils.Shape(x)

# ------------------------------------------------------------------------------
# Rect
# ------------------------------------------------------------------------------
fitz.Rect.getRectArea = fitz.utils.getRectArea
fitz.Rect.getArea = fitz.utils.getRectArea

# ------------------------------------------------------------------------------
# IRect
# ------------------------------------------------------------------------------
fitz.IRect.getRectArea = fitz.utils.getRectArea
fitz.IRect.getArea = fitz.utils.getRectArea

fitz.__doc__ = """
PyMuPDF %s: Python bindings for the MuPDF %s library.
Version date: %s.
Built for Python %i.%i on %s (%i-bit).
""" % (
    fitz.VersionBind,
    fitz.VersionFitz,
    fitz.VersionDate,
    sys.version_info[0],
    sys.version_info[1],
    sys.platform,
    64 if sys.maxsize > 2 ** 32 else 32,
)
