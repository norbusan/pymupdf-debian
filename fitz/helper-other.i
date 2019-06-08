%{
// a simple tracer
void JM_TRACE(const char *id)
{
    PySys_WriteStdout("%s\n", id);
}

// put warnings on Python-stdout
void JM_Warning(const char *id)
{
    PySys_WriteStdout("warning: %s\n", id);
}

#if JM_MEMORY == 1
//-----------------------------------------------------------------------------
// The following 3 functions replace MuPDF standard memory allocation.
// This will ensure, that MuPDF memory handling becomes part of Python's
// memory management.
//-----------------------------------------------------------------------------
static void *JM_Py_Malloc(void *opaque, size_t size)
{
    return PyMem_Malloc(size);
}

static void *JM_Py_Realloc(void *opaque, void *old, size_t size)
{
    return PyMem_Realloc(old, size);
}

static void JM_PY_Free(void *opaque, void *ptr)
{
    PyMem_Free(ptr);
}

const fz_alloc_context JM_Alloc_Context =
{
	NULL,
	JM_Py_Malloc,
	JM_Py_Realloc,
	JM_PY_Free
};
#endif

// return Python bools for a given integer
PyObject *JM_BOOL(int v)
{
    if (v == 0)
        Py_RETURN_FALSE;
    Py_RETURN_TRUE;
}

PyObject *JM_fitz_config()
{
#if defined(TOFU)
#define have_TOFU JM_BOOL(0)
#else
#define have_TOFU JM_BOOL(1)
#endif
#if defined(TOFU_CJK)
#define have_TOFU_CJK JM_BOOL(0)
#else
#define have_TOFU_CJK JM_BOOL(1)
#endif
#if defined(TOFU_CJK_EXT)
#define have_TOFU_CJK_EXT JM_BOOL(0)
#else
#define have_TOFU_CJK_EXT JM_BOOL(1)
#endif
#if defined(TOFU_CJK_LANG)
#define have_TOFU_CJK_LANG JM_BOOL(0)
#else
#define have_TOFU_CJK_LANG JM_BOOL(1)
#endif
#if defined(TOFU_EMOJI)
#define have_TOFU_EMOJI JM_BOOL(0)
#else
#define have_TOFU_EMOJI JM_BOOL(1)
#endif
#if defined(TOFU_HISTORIC)
#define have_TOFU_HISTORIC JM_BOOL(0)
#else
#define have_TOFU_HISTORIC JM_BOOL(1)
#endif
#if defined(TOFU_SYMBOL)
#define have_TOFU_SYMBOL JM_BOOL(0)
#else
#define have_TOFU_SYMBOL JM_BOOL(1)
#endif
#if defined(TOFU_SIL)
#define have_TOFU_SIL JM_BOOL(0)
#else
#define have_TOFU_SIL JM_BOOL(1)
#endif
#if defined(NO_ICC)
#define have_NO_ICC JM_BOOL(0)
#else
#define have_NO_ICC JM_BOOL(1)
#endif
#if defined(TOFU_BASE14)
#define have_TOFU_BASE14 JM_BOOL(0)
#else
#define have_TOFU_BASE14 JM_BOOL(1)
#endif
    PyObject *dict = PyDict_New();
    PyDict_SetItemString(dict, "plotter-g", JM_BOOL(FZ_PLOTTERS_G));
    PyDict_SetItemString(dict, "plotter-rgb", JM_BOOL(FZ_PLOTTERS_RGB));
    PyDict_SetItemString(dict, "plotter-cmyk", JM_BOOL(FZ_PLOTTERS_CMYK));
    PyDict_SetItemString(dict, "plotter-n", JM_BOOL(FZ_PLOTTERS_N));
    PyDict_SetItemString(dict, "pdf", JM_BOOL(FZ_ENABLE_PDF));
    PyDict_SetItemString(dict, "xps", JM_BOOL(FZ_ENABLE_XPS));
    PyDict_SetItemString(dict, "svg", JM_BOOL(FZ_ENABLE_SVG));
    PyDict_SetItemString(dict, "cbz", JM_BOOL(FZ_ENABLE_CBZ));
    PyDict_SetItemString(dict, "img", JM_BOOL(FZ_ENABLE_IMG));
    PyDict_SetItemString(dict, "html", JM_BOOL(FZ_ENABLE_HTML));
    PyDict_SetItemString(dict, "epub", JM_BOOL(FZ_ENABLE_EPUB));
    PyDict_SetItemString(dict, "gprf", JM_BOOL(FZ_ENABLE_GPRF));
    PyDict_SetItemString(dict, "jpx", JM_BOOL(FZ_ENABLE_JPX));
    PyDict_SetItemString(dict, "js", JM_BOOL(FZ_ENABLE_JS));
    PyDict_SetItemString(dict, "tofu", have_TOFU);
    PyDict_SetItemString(dict, "tofu-cjk", have_TOFU_CJK);
    PyDict_SetItemString(dict, "tofu-cjk-ext", have_TOFU_CJK_EXT);
    PyDict_SetItemString(dict, "tofu-cjk-lang", have_TOFU_CJK_LANG);
    PyDict_SetItemString(dict, "tofu-emoji", have_TOFU_EMOJI);
    PyDict_SetItemString(dict, "tofu-historic", have_TOFU_HISTORIC);
    PyDict_SetItemString(dict, "tofu-symbol", have_TOFU_SYMBOL);
    PyDict_SetItemString(dict, "tofu-sil", have_TOFU_SIL);
    PyDict_SetItemString(dict, "icc", have_NO_ICC);
    PyDict_SetItemString(dict, "base14", have_TOFU_BASE14);
    PyDict_SetItemString(dict, "py-memory", JM_BOOL(JM_MEMORY));
    return dict;
}

//----------------------------------------------------------------------------
// Update a color float array with values from a Python sequence.
// Any error condition is treated as a no-op.
//----------------------------------------------------------------------------
void JM_color_FromSequence(PyObject *color, int *n, float col[4])
{
    if (!color) return;
    if (PyFloat_Check(color)) // maybe just a single float
    {
        float c = (float) PyFloat_AsDouble(color);
        if (!INRANGE(c, 0.0f, 1.0f)) return;
        col[0] = c;
        *n = 1;
        return;
    }
    if (!PySequence_Check(color)) return;
    int len = PySequence_Size(color), i;
    if (!INRANGE(len, 1, 4) || len == 2) return;

    float mcol[4] = {0,0,0,0}; // local color storage
    for (i = 0; i < len; i++)
    {
        mcol[i] = (float) PyFloat_AsDouble(PySequence_ITEM(color, i));
        if (PyErr_Occurred())
        {
            PyErr_Clear(); // reset Py error indicator
            return;
        }
        if (!INRANGE(mcol[i], 0.0f, 1.0f)) return;
    }

    *n = len;
    for (i = 0; i < len; i++)
        col[i] = mcol[i];
    return;
}

// return extension for fitz image type
const char *JM_image_extension(int type)
{
    switch (type)
    {
        case(FZ_IMAGE_RAW): return "raw";
        case(FZ_IMAGE_FLATE): return "flate";
        case(FZ_IMAGE_LZW): return "lzw";
        case(FZ_IMAGE_RLD): return "rld";
        case(FZ_IMAGE_BMP): return "bmp";
        case(FZ_IMAGE_GIF): return "gif";
        case(FZ_IMAGE_JBIG2): return "jbig2";
        case(FZ_IMAGE_JPEG): return "jpeg";
        case(FZ_IMAGE_JPX): return "jpx";
        case(FZ_IMAGE_JXR): return "jxr";
        case(FZ_IMAGE_PNG): return "png";
        case(FZ_IMAGE_PNM): return "pnm";
        case(FZ_IMAGE_TIFF): return "tiff";
        default: return "n/a";
    }
}

//----------------------------------------------------------------------------
// Turn fz_buffer into a Python bytes object
//----------------------------------------------------------------------------
PyObject *JM_BinFromBuffer(fz_context *ctx, fz_buffer *buffer)
{
    PyObject *bytes = PyBytes_FromString("");
    if (buffer)
    {
        char *c = NULL;
        size_t len = fz_buffer_storage(gctx, buffer, &c);
        bytes = PyBytes_FromStringAndSize(c, (Py_ssize_t) len);
    }
    return bytes;
}

//----------------------------------------------------------------------------
// Turn fz_buffer into a Python bytearray object
//----------------------------------------------------------------------------
PyObject *JM_BArrayFromBuffer(fz_context *ctx, fz_buffer *buffer)
{
    PyObject *bytes = PyByteArray_FromObject(Py_BuildValue("s", ""));
    char *c = NULL;
    if (buffer)
    {
        size_t len = fz_buffer_storage(ctx, buffer, &c);
        bytes = PyByteArray_FromStringAndSize(c, (Py_ssize_t) len);
    }
    return bytes;
}

//----------------------------------------------------------------------------
// Turn fz_buffer to a base64 encoded bytes object
//----------------------------------------------------------------------------
PyObject *JM_B64FromBuffer(fz_context *ctx, fz_buffer *buffer)
{
    PyObject *bytes = PyBytes_FromString("");
    char *c = NULL;
    char *b64 = NULL;
    if (buffer)
    {
        size_t len = fz_buffer_storage(ctx, buffer, &c);
        fz_buffer *res = fz_new_buffer(ctx, len);
        fz_output *out = fz_new_output_with_buffer(ctx, res);
        fz_write_base64(ctx, out, (const unsigned char *) c, (int) len, 0);
        size_t nlen = fz_buffer_storage(ctx, res, &b64);
        bytes = PyBytes_FromStringAndSize(b64, (Py_ssize_t) nlen);
        fz_drop_buffer(ctx, res);
        fz_drop_output(ctx, out);
    }
    return bytes;
}

//----------------------------------------------------------------------------
// deflate char* into a buffer
// this is a copy of function "deflatebuf" of pdf_write.c
//----------------------------------------------------------------------------
fz_buffer *JM_deflatebuf(fz_context *ctx, unsigned char *p, size_t n)
{
    fz_buffer *buf = NULL;
    uLongf csize;
    int t;
    uLong longN = (uLong) n;
    unsigned char *data = NULL;
    size_t cap;
    fz_try(ctx)
    {
        if (n != (size_t)longN) THROWMSG("buffer too large to deflate");
        cap = compressBound(longN);
        data = fz_malloc(ctx, cap);
        buf = fz_new_buffer_from_data(ctx, data, cap);
        csize = (uLongf)cap;
        t = compress(data, &csize, p, longN);
        if (t != Z_OK) THROWMSG("cannot deflate buffer");
    }
    fz_catch(ctx)
    {
        fz_drop_buffer(ctx, buf);
        fz_rethrow(ctx);
    }
    fz_resize_buffer(ctx, buf, csize);
    return buf;
}

//----------------------------------------------------------------------------
// update a stream object
// compress stream when beneficial
//----------------------------------------------------------------------------
void JM_update_stream(fz_context *ctx, pdf_document *doc, pdf_obj *obj, fz_buffer *buffer)
{
    size_t len, nlen;
    unsigned char *data = NULL;
    fz_buffer *nres = NULL;
    len = fz_buffer_storage(ctx, buffer, &data);
    nlen = len;
    if (len > 20)       // ignore small stuff
    {
        nres = JM_deflatebuf(ctx, data, len);
        nlen = fz_buffer_storage(ctx, nres, NULL);
    }
    if (nlen < len)     // was it worth the effort?
    {
        pdf_dict_put(ctx, obj, PDF_NAME(Filter), PDF_NAME(FlateDecode));
        pdf_update_stream(ctx, doc, obj, nres, 1);
    }
    else
    {
        pdf_update_stream(ctx, doc, obj, buffer, 0);
    }
    fz_drop_buffer(ctx, nres);
}

//-----------------------------------------------------------------------------
// Version of fz_new_pixmap_from_display_list (util.c) to support rendering
// of only the 'clip' part of the displaylist rectangle
//-----------------------------------------------------------------------------
fz_pixmap *
JM_pixmap_from_display_list(fz_context *ctx, fz_display_list *list, PyObject *ctm, fz_colorspace *cs, int alpha, PyObject *clip)
{
    fz_rect rect = fz_bound_display_list(ctx, list);
    fz_matrix matrix = JM_matrix_from_py(ctm);
    fz_pixmap *pix = NULL;
    fz_var(pix);
    fz_device *dev = NULL;
    fz_var(dev);
    fz_separations *seps = NULL;
    fz_rect rclip = JM_rect_from_py(clip);
    rect = fz_intersect_rect(rect, rclip);  // no-op if clip is not given

    rect = fz_transform_rect(rect, matrix);
    fz_irect irect = fz_round_rect(rect);

    pix = fz_new_pixmap_with_bbox(ctx, cs, irect, seps, alpha);
    if (alpha)
        fz_clear_pixmap(ctx, pix);
    else
        fz_clear_pixmap_with_value(ctx, pix, 0xFF);

    fz_try(ctx)
    {
        if (!fz_is_infinite_rect(rclip))
        {
            dev = fz_new_draw_device_with_bbox(ctx, matrix, pix, &irect);
            fz_run_display_list(ctx, list, dev, fz_identity, rclip, NULL);
        }
        else
        {
            dev = fz_new_draw_device(ctx, matrix, pix);
            fz_run_display_list(ctx, list, dev, fz_identity, fz_infinite_rect, NULL);
        }

        fz_close_device(ctx, dev);
    }
    fz_always(ctx)
    {
        fz_drop_device(ctx, dev);
    }
    fz_catch(ctx)
    {
        fz_drop_pixmap(ctx, pix);
        fz_rethrow(ctx);
    }
    return pix;
}

//-----------------------------------------------------------------------------
// return hex characters for n characters in input 'in'
//-----------------------------------------------------------------------------
void hexlify(int n, unsigned char *in, unsigned char *out)
{
    const unsigned char hdigit[17] = "0123456789abcedf";
    int i, i1, i2;
    for (i = 0; i < n; i++)
    {
        i1 = in[i]>>4;
        i2 = in[i] - i1*16;
        out[2*i] = hdigit[i1];
        out[2*i + 1] = hdigit[i2];
    }
    out[2*n] = 0;
}

//----------------------------------------------------------------------------
// Make fz_buffer from a PyBytes, PyByteArray, io.BytesIO object
//----------------------------------------------------------------------------
fz_buffer *JM_BufferFromBytes(fz_context *ctx, PyObject *stream)
{
    if (!stream) return NULL;
    if (stream == NONE) return NULL;
    char *c = NULL;
    PyObject *mybytes = NULL;
    size_t len = 0;
    fz_buffer *res = NULL;
    fz_var(res);
    fz_try(ctx)
    {
        if (PyBytes_Check(stream))
        {
            c = PyBytes_AS_STRING(stream);
            len = (size_t) PyBytes_GET_SIZE(stream);
        }
        else if (PyByteArray_Check(stream))
        {
            c = PyByteArray_AS_STRING(stream);
            len = (size_t) PyByteArray_GET_SIZE(stream);
        }
        else if (PyObject_HasAttrString(stream, "getvalue"))
        {   // we assume here that this delivers what we expect
            mybytes = PyObject_CallMethod(stream, "getvalue", NULL);
            c = PyBytes_AS_STRING(mybytes);
            len = (size_t) PyBytes_GET_SIZE(mybytes);
        }
        // all the above leave c as NULL pointer if unsuccessful
        if (c) res = fz_new_buffer_from_copied_data(ctx, c, len);
    }
    fz_always(ctx)
    {
        Py_CLEAR(mybytes);
        PyErr_Clear();
    }
    fz_catch(ctx)
    {
        fz_drop_buffer(ctx, res);
        fz_rethrow(ctx);
    }
    return res;
}

//----------------------------------------------------------------------------
// Modified copy of SWIG_Python_str_AsChar
// If Py3, the SWIG original v3.0.12 does *not* deliver NULL for a
// non-string input, as does PyString_AsString in Py2.
//----------------------------------------------------------------------------
char *JM_Python_str_AsChar(PyObject *str)
{
    if (!str) return NULL;
#if PY_VERSION_HEX >= 0x03000000
  char *newstr = NULL;
  PyObject *xstr = PyUnicode_AsUTF8String(str);
  if (xstr)
  {
    char *cstr;
    Py_ssize_t len;
    PyBytes_AsStringAndSize(xstr, &cstr, &len);
    size_t l = len + 1;
    newstr = JM_Alloc(char, l);
    memcpy(newstr, cstr, l);
    Py_XDECREF(xstr);
  }
  return newstr;
#else
  return PyString_AsString(str);
#endif
}

#if PY_VERSION_HEX >= 0x03000000
#  define JM_Python_str_DelForPy3(x) JM_Free(x)
#else
#  define JM_Python_str_DelForPy3(x) 
#endif

//----------------------------------------------------------------------------
// Deep-copies a specified source page to the target location.
// Modified copy of function of pdfmerge.c: we also copy annotations, but
// we skip **link** annotations. In addition we rotate output.
//----------------------------------------------------------------------------
void page_merge(fz_context *ctx, pdf_document *doc_des, pdf_document *doc_src, int page_from, int page_to, int rotate, pdf_graft_map *graft_map)
{
    pdf_obj *pageref = NULL;
    pdf_obj *page_dict;
    pdf_obj *obj = NULL, *ref = NULL, *subt = NULL;

    // list of object types (per page) we want to copy
    pdf_obj *known_page_objs[] = {PDF_NAME(Contents), PDF_NAME(Resources),
        PDF_NAME(MediaBox), PDF_NAME(CropBox), PDF_NAME(BleedBox), PDF_NAME(Annots),
        PDF_NAME(TrimBox), PDF_NAME(ArtBox), PDF_NAME(Rotate), PDF_NAME(UserUnit)};
    int n = nelem(known_page_objs);                   // number of list elements
    int i;
    int num, j;
    fz_var(obj);
    fz_var(ref);

    fz_try(ctx)
    {
        pageref = pdf_lookup_page_obj(ctx, doc_src, page_from);
        pdf_flatten_inheritable_page_items(ctx, pageref);
        // make a new page
        page_dict = pdf_new_dict(ctx, doc_des, 4);
        pdf_dict_put_drop(ctx, page_dict, PDF_NAME(Type), PDF_NAME(Page));

        // copy objects of source page into it
        for (i = 0; i < n; i++)
            {
            obj = pdf_dict_get(ctx, pageref, known_page_objs[i]);
            if (obj != NULL)
                pdf_dict_put_drop(ctx, page_dict, known_page_objs[i], pdf_graft_mapped_object(ctx, graft_map, obj));
            }
        // remove any links from annots array
        pdf_obj *annots = pdf_dict_get(ctx, page_dict, PDF_NAME(Annots));
        int len = pdf_array_len(ctx, annots);
        for (j = 0; j < len; j++)
        {
            pdf_obj *o = pdf_array_get(ctx, annots, j);
            if (!pdf_name_eq(ctx, pdf_dict_get(ctx, o, PDF_NAME(Subtype)), PDF_NAME(Link)))
                continue;
            // remove the link annotation
            pdf_array_delete(ctx, annots, j);
            len--;
            j--;
        }
        // rotate the page as requested
        if (rotate != -1)
            {
            pdf_obj *rotateobj = pdf_new_int(ctx, (int64_t) rotate);
            pdf_dict_put_drop(ctx, page_dict, PDF_NAME(Rotate), rotateobj);
            }
        // Now add the page dictionary to dest PDF
        obj = pdf_add_object_drop(ctx, doc_des, page_dict);

        // Get indirect ref of the page
        num = pdf_to_num(ctx, obj);
        ref = pdf_new_indirect(ctx, doc_des, num, 0);

        // Insert new page at specified location
        pdf_insert_page(ctx, doc_des, page_to, ref);

    }
    fz_always(ctx)
    {
        pdf_drop_obj(ctx, obj);
        pdf_drop_obj(ctx, ref);
    }
    fz_catch(ctx)
    {
        fz_rethrow(ctx);
    }
}

//-----------------------------------------------------------------------------
// Copy a range of pages (spage, epage) from a source PDF to a specified
// location (apage) of the target PDF.
// If spage > epage, the sequence of source pages is reversed.
//-----------------------------------------------------------------------------
void merge_range(fz_context *ctx, pdf_document *doc_des, pdf_document *doc_src, int spage, int epage, int apage, int rotate)
{
    int page, afterpage, count;
    pdf_graft_map *graft_map;
    afterpage = apage;
    count = pdf_count_pages(ctx, doc_src);
    graft_map = pdf_new_graft_map(ctx, doc_des);

    fz_try(ctx)
    {
        if (spage < epage)
            for (page = spage; page <= epage; page++, afterpage++)
                page_merge(ctx, doc_des, doc_src, page, afterpage, rotate, graft_map);
        else
            for (page = spage; page >= epage; page--, afterpage++)
                page_merge(ctx, doc_des, doc_src, page, afterpage, rotate, graft_map);
    }

    fz_always(ctx)
    {
        pdf_drop_graft_map(ctx, graft_map);
    }
    fz_catch(ctx)
    {
        fz_rethrow(ctx);
    }
}

//----------------------------------------------------------------------------
// Return list of outline xref numbers. Recursive function. Arguments:
// 'obj' first OL item
// 'xrefs' empty Python list
//----------------------------------------------------------------------------
PyObject *JM_outline_xrefs(fz_context *ctx, pdf_obj *obj, PyObject *xrefs)
{
    pdf_obj *first, *parent, *thisobj;
    if (!obj) return xrefs;
    thisobj = obj;
    while (thisobj)
    {
        PyList_Append(xrefs, Py_BuildValue("i", pdf_to_num(ctx, thisobj)));
        first = pdf_dict_get(ctx, thisobj, PDF_NAME(First));   // try go down
        if (first) xrefs = JM_outline_xrefs(ctx, first, xrefs);
        thisobj = pdf_dict_get(ctx, thisobj, PDF_NAME(Next));  // try go next
        parent = pdf_dict_get(ctx, thisobj, PDF_NAME(Parent)); // get parent
        if (!thisobj) thisobj = parent;      /* goto parent if no next exists */
    }
    return xrefs;
}

//-----------------------------------------------------------------------------
// Return the contents of a font file
//-----------------------------------------------------------------------------
fz_buffer *fontbuffer(fz_context *ctx, pdf_document *doc, int xref)
{
    if (xref < 1) return NULL;
    pdf_obj *o, *obj = NULL, *desft, *stream = NULL;
    char *ext = "";
    o = pdf_load_object(ctx, doc, xref);
    desft = pdf_dict_get(ctx, o, PDF_NAME(DescendantFonts));
    if (desft)
    {
        obj = pdf_resolve_indirect(ctx, pdf_array_get(ctx, desft, 0));
        obj = pdf_dict_get(ctx, obj, PDF_NAME(FontDescriptor));
    }
    else
        obj = pdf_dict_get(ctx, o, PDF_NAME(FontDescriptor));

    if (!obj)
    {
        pdf_drop_obj(ctx, o);
        PySys_WriteStdout("invalid font - FontDescriptor missing");
        return NULL;
    }
    pdf_drop_obj(ctx, o);
    o = obj;

    obj = pdf_dict_get(ctx, o, PDF_NAME(FontFile));
    if (obj) stream = obj;             // ext = "pfa"

    obj = pdf_dict_get(ctx, o, PDF_NAME(FontFile2));
    if (obj) stream = obj;             // ext = "ttf"

    obj = pdf_dict_get(ctx, o, PDF_NAME(FontFile3));
    if (obj)
    {
        stream = obj;

        obj = pdf_dict_get(ctx, obj, PDF_NAME(Subtype));
        if (obj && !pdf_is_name(ctx, obj))
        {
            PySys_WriteStdout("invalid font descriptor subtype");
            return NULL;
        }

        if (pdf_name_eq(ctx, obj, PDF_NAME(Type1C)))
            ext = "cff";
        else if (pdf_name_eq(ctx, obj, PDF_NAME(CIDFontType0C)))
            ext = "cid";
        else if (pdf_name_eq(ctx, obj, PDF_NAME(OpenType)))
            ext = "otf";
        else
            PySys_WriteStdout("warning: unhandled font type '%s'", pdf_to_name(ctx, obj));
    }

    if (!stream)
    {
        PySys_WriteStdout("warning: unhandled font type");
        return NULL;
    }

    return pdf_load_stream(ctx, stream);
}

//-----------------------------------------------------------------------------
// Return the file extension of an embedded font file
//-----------------------------------------------------------------------------
char *fontextension(fz_context *ctx, pdf_document *doc, int xref)
{
    if (xref < 1) return "n/a";
    pdf_obj *o, *obj = NULL, *desft;
    o = pdf_load_object(ctx, doc, xref);
    desft = pdf_dict_get(ctx, o, PDF_NAME(DescendantFonts));
    if (desft)
    {
        obj = pdf_resolve_indirect(ctx, pdf_array_get(ctx, desft, 0));
        obj = pdf_dict_get(ctx, obj, PDF_NAME(FontDescriptor));
    }
    else
        obj = pdf_dict_get(ctx, o, PDF_NAME(FontDescriptor));

    pdf_drop_obj(ctx, o);
    if (!obj) return "n/a";           // this is a base-14 font

    o = obj;                           // we have the FontDescriptor

    obj = pdf_dict_get(ctx, o, PDF_NAME(FontFile));
    if (obj) return "pfa";

    obj = pdf_dict_get(ctx, o, PDF_NAME(FontFile2));
    if (obj) return "ttf";

    obj = pdf_dict_get(ctx, o, PDF_NAME(FontFile3));
    if (obj)
    {
        obj = pdf_dict_get(ctx, obj, PDF_NAME(Subtype));
        if (obj && !pdf_is_name(ctx, obj))
        {
            PySys_WriteStdout("invalid font descriptor subtype");
            return "n/a";
        }
        if (pdf_name_eq(ctx, obj, PDF_NAME(Type1C)))
            return "cff";
        else if (pdf_name_eq(ctx, obj, PDF_NAME(CIDFontType0C)))
            return "cid";
        else if (pdf_name_eq(ctx, obj, PDF_NAME(OpenType)))
            return "otf";
        else
            PySys_WriteStdout("unhandled font type '%s'", pdf_to_name(ctx, obj));
    }

    return "n/a";
}

//-----------------------------------------------------------------------------
// create PDF object from given string (new in v1.14.0: MuPDF dropped it)
//-----------------------------------------------------------------------------
pdf_obj *JM_pdf_obj_from_str(fz_context *ctx, pdf_document *doc, char *src)
{
    pdf_obj *result = NULL;
    pdf_lexbuf lexbuf;
    fz_stream *stream = fz_open_memory(ctx, (unsigned char *)src, strlen(src));

    pdf_lexbuf_init(ctx, &lexbuf, PDF_LEXBUF_SMALL);

    fz_try(ctx)
        result = pdf_parse_stm_obj(ctx, doc, stream, &lexbuf);

    fz_always(ctx)
    {
        pdf_lexbuf_fin(ctx, &lexbuf);
        fz_drop_stream(ctx, stream);
    }

    fz_catch(ctx)
        fz_rethrow(ctx);

    return result;

}

//-----------------------------------------------------------------------------
// dummy structure for various tools and utilities
//-----------------------------------------------------------------------------
struct Tools {int index;};

typedef struct fz_item_s fz_item;

struct fz_item_s
{
	void *key;
	fz_storable *val;
	size_t size;
	fz_item *next;
	fz_item *prev;
	fz_store *store;
	const fz_store_type *type;
};

struct fz_store_s
{
	int refs;

	/* Every item in the store is kept in a doubly linked list, ordered
	 * by usage (so LRU entries are at the end). */
	fz_item *head;
	fz_item *tail;

	/* We have a hash table that allows to quickly find a subset of the
	 * entries (those whose keys are indirect objects). */
	fz_hash_table *hash;

	/* We keep track of the size of the store, and keep it below max. */
	size_t max;
	size_t size;

	int defer_reap_count;
	int needs_reaping;
};

%}