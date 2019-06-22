%{
//-----------------------------------------------------------------------------
// Make an XObject from a PDF page
// For a positive xref assume that that object can be used instead
//-----------------------------------------------------------------------------
pdf_obj *JM_xobject_from_page(fz_context *ctx, pdf_document *pdfout, fz_page *fsrcpage, int xref, pdf_graft_map *gmap)
{
    fz_buffer *nres = NULL, *res = NULL;
    pdf_obj *xobj1, *contents = NULL, *resources = NULL, *o, *spageref;
    fz_rect mediabox;
    int i;
    fz_try(ctx)
    {
        pdf_page *srcpage = pdf_page_from_fz_page(ctx, fsrcpage);
        spageref = srcpage->obj;
        mediabox = pdf_to_rect(ctx, pdf_dict_get_inheritable(ctx, spageref, PDF_NAME(MediaBox)));

        if (xref > 0)        // we can reuse an XObject!
        {
            xobj1 = pdf_new_indirect(ctx, pdfout, xref, 0);
        }
        else                 // need to create new XObject
        {
            // Deep-copy resources object of source page
            o = pdf_dict_get(ctx, spageref, PDF_NAME(Resources));
            if (gmap)        // use graftmap when possible
                resources = pdf_graft_mapped_object(ctx, gmap, o);
            else
                resources = pdf_graft_object(ctx, pdfout, o);
            
            // get spgage contents source; combine when several
            contents = pdf_dict_get(ctx, spageref, PDF_NAME(Contents));
            if (pdf_is_array(ctx, contents))     // more than one!
            {
                res = fz_new_buffer(ctx, 1024);
                for (i=0; i < pdf_array_len(ctx, contents); i++)
                {
                    nres = pdf_load_stream(ctx, pdf_array_get(ctx, contents, i));
                    fz_append_buffer(ctx, res, nres);
                    fz_drop_buffer(ctx, nres);
                }
            }
            else
            {
                res = pdf_load_stream(ctx, contents);
            }

            //-------------------------------------------------------------
            // create XObject representing the source page
            //-------------------------------------------------------------
            xobj1 = pdf_new_xobject(ctx, pdfout, mediabox, fz_identity, NULL, res);
            // store spage contents
            JM_update_stream(ctx, pdfout, xobj1, res);
            fz_drop_buffer(ctx, res);

            // store spage resources
            pdf_dict_put_drop(ctx, xobj1, PDF_NAME(Resources), resources);
        }
    }
    fz_catch(ctx) fz_rethrow(ctx);
    return xobj1;
}

//-----------------------------------------------------------------------------
// Insert a buffer as a new separate /Contents object of a page.
// 1. Create a new stream object from buffer 'newcont'
// 2. If /Contents already is an array, then just prepend or append this object
// 3. Else, create new array and put old content obj and this object into it.
//    If the page had no /Contents before, just create a 1-item array.
//-----------------------------------------------------------------------------
int JM_insert_contents(fz_context *ctx, pdf_document *pdf,
                        pdf_obj *pageref, fz_buffer *newcont, int overlay)
{
    int xref = 0;
    fz_try(ctx)
    {
        pdf_obj *contents = pdf_dict_get(ctx, pageref, PDF_NAME(Contents));
        pdf_obj *newconts = pdf_add_stream(ctx, pdf, newcont, NULL, 0);
        xref = pdf_to_num(ctx, newconts);
        if (pdf_is_array(ctx, contents))
        {
            if (overlay)               // append new object
                pdf_array_push_drop(ctx, contents, newconts);
            else                       // prepend new object
                pdf_array_insert_drop(ctx, contents, newconts, 0);
        }
        else                           // make new array
        {
            pdf_obj *carr = pdf_new_array(ctx, pdf, 5);
            if (overlay)
            {
                if (contents) pdf_array_push(ctx, carr, contents);
                pdf_array_push_drop(ctx, carr, newconts);
            }
            else 
            {
                pdf_array_push_drop(ctx, carr, newconts);
                if (contents) pdf_array_push(ctx, carr, contents);
            }
            pdf_dict_put_drop(ctx, pageref, PDF_NAME(Contents), carr);
        }
    }
    fz_catch(ctx) fz_rethrow(ctx);
    return xref;
}
/*------------------ currently not used ---------------------------------------
//-----------------------------------------------------------------------------
// Append / prepend a buffer to the /Contents of a page.
//-----------------------------------------------------------------------------
void JM_extend_contents(fz_context *ctx, pdf_document *pdfout,
                        pdf_obj *pageref, fz_buffer *newcont, int overlay)
{
    int i;
    fz_buffer *oldcont = NULL, *endcont = NULL;
    pdf_obj *contents = pdf_dict_get(ctx, pageref, PDF_NAME(Contents));
    fz_try(ctx)
    {
        if (pdf_is_array(ctx, contents))     // multiple contents objects!
        {   // choose the correct one (first / last)
            if (overlay == 1) i = pdf_array_len(ctx, contents) - 1;
            else  i = 0;
            contents = pdf_array_get(ctx, contents, i);
        }
        oldcont = pdf_load_stream(ctx, contents);     // old contents buffer

        // allocate result buffer
        endcont = fz_new_buffer(ctx, fz_buffer_storage(ctx, oldcont, NULL) +
                                     fz_buffer_storage(ctx, newcont, NULL));

        if (overlay == 1)                             // append new buffer
        {
            fz_append_buffer(ctx, endcont, oldcont);
            fz_append_buffer(ctx, endcont, newcont);
        }
        else                                          // prepend new buffer
        {
            fz_append_buffer(ctx, endcont, newcont);
            fz_append_buffer(ctx, endcont, oldcont);
        }
        fz_terminate_buffer(ctx, endcont);            // finalize result buffer
    
        // now update the content stream
        JM_update_stream(ctx, pdfout, contents, endcont);
    }
    fz_always(ctx)
    {
        fz_drop_buffer(ctx, endcont);
        fz_drop_buffer(ctx, oldcont);
    }
    fz_catch(ctx) fz_rethrow(ctx);
    return;
}
-----------------------------------------------------------------------------*/

%}