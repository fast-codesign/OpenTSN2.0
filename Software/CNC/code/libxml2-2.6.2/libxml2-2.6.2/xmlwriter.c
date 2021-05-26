/*
 * xmlwriter.c: XML text writer implementation
 *
 * For license and disclaimer see the license and disclaimer of
 * libxml2.
 *
 * alfred@mickautsch.de
 */

#include <string.h>
#include <stdarg.h>

#include "libxml.h"
#include <libxml/xmlmemory.h>
#include <libxml/parser.h>

#ifdef LIBXML_WRITER_ENABLED

#include <libxml/xmlwriter.h>

#define B64LINELEN 72
#define B64CRLF "\r\n"

/*
 * Types are kept private
 */
typedef enum {
    XML_TEXTWRITER_NONE = 0,
    XML_TEXTWRITER_NAME,
    XML_TEXTWRITER_ATTRIBUTE,
    XML_TEXTWRITER_TEXT,
    XML_TEXTWRITER_PI,
    XML_TEXTWRITER_PI_TEXT,
    XML_TEXTWRITER_CDATA,
    XML_TEXTWRITER_DTD,
    XML_TEXTWRITER_DTD_TEXT,
    XML_TEXTWRITER_DTD_ELEM,
    XML_TEXTWRITER_DTD_ATTL,
    XML_TEXTWRITER_DTD_ENTY
} xmlTextWriterState;

typedef struct _xmlTextWriterStackEntry xmlTextWriterStackEntry;

struct _xmlTextWriterStackEntry {
    xmlChar *name;
    xmlTextWriterState state;
};

typedef struct _xmlTextWriterNsStackEntry xmlTextWriterNsStackEntry;
struct _xmlTextWriterNsStackEntry {
    xmlChar *prefix;
    xmlChar *uri;
    xmlLinkPtr elem;
};

struct _xmlTextWriter {
    xmlOutputBufferPtr out; /* output buffer */
    xmlListPtr nodes;       /* element name stack */
    xmlListPtr nsstack;     /* name spaces stack */
    int level;
    char indent;            /* indent amount */
    char ichar;             /* indent character */
    char qchar;             /* character used for quoting attribute values */
};

static void xmlFreeTextWriterStackEntry(xmlLinkPtr lk);
static int xmlCmpTextWriterStackEntry(const void *data0,
                                      const void *data1);
static void xmlFreeTextWriterNsStackEntry(xmlLinkPtr lk);
static int xmlCmpTextWriterNsStackEntry(const void *data0,
                                        const void *data1);
static int xmlTextWriterWriteMemCallback(void *context,
                                         const xmlChar * str, int len);
static int xmlTextWriterCloseMemCallback(void *context);
static xmlChar *xmlTextWriterVSprintf(const char *format, va_list argptr);
static int xmlOutputBufferWriteBase64(xmlOutputBufferPtr out, int len,
                                      const unsigned char *data);

/**
 * xmlNewTextWriter:
 * @out:  an xmlOutputBufferPtr
 *
 * Create a new xmlNewTextWriter structure using an xmlOutputBufferPtr
 *
 * Returns the new xmlTextWriterPtr or NULL in case of error
 */
xmlTextWriterPtr
xmlNewTextWriter(xmlOutputBufferPtr out)
{
    xmlTextWriterPtr ret;

    ret = (xmlTextWriterPtr) xmlMalloc(sizeof(xmlTextWriter));
    if (ret == NULL) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlNewTextWriter : out of memory!\n");
        return NULL;
    }
    memset(ret, 0, (size_t) sizeof(xmlTextWriter));

    ret->nodes = xmlListCreate((xmlListDeallocator)
                               xmlFreeTextWriterStackEntry,
                               (xmlListDataCompare)
                               xmlCmpTextWriterStackEntry);
    if (ret->nodes == NULL) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlNewTextWriter : out of memory!\n");
        xmlFree(ret);
        return NULL;
    }

    ret->nsstack = xmlListCreate((xmlListDeallocator)
                                 xmlFreeTextWriterNsStackEntry,
                                 (xmlListDataCompare)
                                 xmlCmpTextWriterNsStackEntry);
    if (ret->nsstack == NULL) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlNewTextWriter : out of memory!\n");
        xmlFree(ret->nodes);
        xmlFree(ret);
        return NULL;
    }

    ret->out = out;
    ret->ichar = ' ';
    ret->qchar = '"';

    return ret;
}

/**
 * xmlNewTextWriterFilename:
 * @uri:  the URI of the resource for the output
 * @compression:  compress the output?
 *
 * Create a new xmlNewTextWriter structure with @uri as output
 *
 * Returns the new xmlTextWriterPtr or NULL in case of error
 */
xmlTextWriterPtr
xmlNewTextWriterFilename(const char *uri, int compression)
{
    xmlTextWriterPtr ret;
    xmlOutputBufferPtr out;

    out = xmlOutputBufferCreateFilename(uri, NULL, compression);
    if (out == NULL) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlNewTextWriterFilename : out of memory!\n");
        return NULL;
    }

    ret = xmlNewTextWriter(out);
    if (ret == NULL) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlNewTextWriterFilename : out of memory!\n");
        xmlOutputBufferClose(out);
        return NULL;
    }

    return ret;
}

/**
 * xmlNewTextWriterMemory:
 * @buf:  xmlBufferPtr
 * @compression:  compress the output?
 *
 * Create a new xmlNewTextWriter structure with @buf as output
 * TODO: handle compression
 *
 * Returns the new xmlTextWriterPtr or NULL in case of error
 */
xmlTextWriterPtr
xmlNewTextWriterMemory(xmlBufferPtr buf, int compression ATTRIBUTE_UNUSED)
{
    xmlTextWriterPtr ret;
    xmlOutputBufferPtr out;

/*::todo handle compression */
    out = xmlOutputBufferCreateIO((xmlOutputWriteCallback)
                                  xmlTextWriterWriteMemCallback,
                                  (xmlOutputCloseCallback)
                                  xmlTextWriterCloseMemCallback,
                                  (void *) buf, NULL);
    if (out == NULL) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlNewTextWriterMemory : out of memory!\n");
        return NULL;
    }

    ret = xmlNewTextWriter(out);
    if (ret == NULL) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlNewTextWriterMemory : out of memory!\n");
        xmlOutputBufferClose(out);
        return NULL;
    }

    return ret;
}

/**
 * xmlFreeTextWriter:
 * @writer:  the xmlTextWriterPtr
 *
 * Deallocate all the resources associated to the writer
 */
void
xmlFreeTextWriter(xmlTextWriterPtr writer)
{
    if (writer == NULL)
        return;

    if (writer->out != NULL)
        xmlOutputBufferClose(writer->out);

    if (writer->nodes != NULL)
        xmlListDelete(writer->nodes);

    if (writer->nsstack != NULL)
        xmlListDelete(writer->nsstack);

    xmlFree(writer);
}

/**
 * xmlTextWriterStartDocument:
 * @writer:  the xmlTextWriterPtr
 * @version:  the xml version ("1.0") or NULL for default ("1.0")
 * @encoding:  the encoding or NULL for default
 * @standalone: "yes" or "no" or NULL for default
 *
 * Start a new xml document
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterStartDocument(xmlTextWriterPtr writer, const char *version,
                           const char *encoding, const char *standalone)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlCharEncodingHandlerPtr encoder;

    if ((writer == NULL) || (writer->out == NULL))
        return -1;

    lk = xmlListFront(writer->nodes);
    if ((lk != NULL) && (xmlLinkGetData(lk) != NULL)) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDocument : only one prolog allowed in an XML document!\n");
        return -1;
    }

    encoder = NULL;
    if (encoding != NULL) {
        encoder = xmlFindCharEncodingHandler(encoding);
        if (encoder == NULL) {
            xmlGenericError(xmlGenericErrorContext,
                            "xmlTextWriterStartDocument : out of memory!\n");
            return -1;
        }
    }

    writer->out->encoder = encoder;
    if (encoder != NULL) {
        writer->out->conv = xmlBufferCreateSize(4000);
        xmlCharEncOutFunc(encoder, writer->out->conv, NULL);
    } else
        writer->out->conv = NULL;

    sum = 0;
    count = xmlOutputBufferWriteString(writer->out, "<?xml version=");
    if (count < 0)
        return -1;
    sum += count;
    count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
    if (count < 0)
        return -1;
    sum += count;
    if (version != 0)
        count = xmlOutputBufferWriteString(writer->out, version);
    else
        count = xmlOutputBufferWriteString(writer->out, "1.0");
    if (count < 0)
        return -1;
    sum += count;
    count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
    if (count < 0)
        return -1;
    sum += count;
    if (writer->out->encoder != 0) {
        count = xmlOutputBufferWriteString(writer->out, " encoding=");
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
        count =
            xmlOutputBufferWriteString(writer->out,
                                       writer->out->encoder->name);
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
    }

    if (standalone != 0) {
        count = xmlOutputBufferWriteString(writer->out, " standalone=");
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWriteString(writer->out, standalone);
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
    }

    count = xmlOutputBufferWriteString(writer->out, "?>\n");
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterEndDocument:
 * @writer:  the xmlTextWriterPtr
 *
 * End an xml document. All open elements are closed
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterEndDocument(xmlTextWriterPtr writer)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    sum = 0;
    while ((lk = xmlListFront(writer->nodes)) != NULL) {
        p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
        if (p == 0)
            break;
        switch (p->state) {
            case XML_TEXTWRITER_NAME:
            case XML_TEXTWRITER_ATTRIBUTE:
            case XML_TEXTWRITER_TEXT:
                count = xmlTextWriterEndElement(writer);
                if (count < 0)
                    return -1;
                sum += count;
                break;
            case XML_TEXTWRITER_PI:
            case XML_TEXTWRITER_PI_TEXT:
                count = xmlTextWriterEndPI(writer);
                if (count < 0)
                    return -1;
                sum += count;
                break;
            case XML_TEXTWRITER_CDATA:
                count = xmlTextWriterEndCDATA(writer);
                if (count < 0)
                    return -1;
                sum += count;
                break;
            case XML_TEXTWRITER_DTD:
                count = xmlTextWriterEndDTD(writer);
                if (count < 0)
                    return -1;
                sum += count;
                break;
            default:
		break;
        }
    }

    return sum;
}

/**
 * xmlTextWriterWriteFormatComment:
 * @writer:  the xmlTextWriterPtr
 * @format:  format string (see printf)
 *
 * Write an xml comment.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatComment(xmlTextWriterPtr writer,
                                const char *format, ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatComment(writer, format, ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatComment:
 * @writer:  the xmlTextWriterPtr
 * @format:  format string (see printf)
 * @argptr:  pointer to the first member of the variable argument list.
 *
 * Write an xml comment.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatComment(xmlTextWriterPtr writer,
                                 const char *format, va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteComment(writer, buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWriteComment:
 * @writer:  the xmlTextWriterPtr
 * @content:  comment string
 *
 * Write an xml comment.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteComment(xmlTextWriterPtr writer, const xmlChar * content)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;
    xmlChar *buf;

    if ((writer == NULL) || (writer->out == NULL))
        return -1;

    if (content == NULL)
        return 0;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk != 0) {
        p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
        if (p != 0) {
            switch (p->state) {
                case XML_TEXTWRITER_PI:
                case XML_TEXTWRITER_PI_TEXT:
                    return -1;
                case XML_TEXTWRITER_NONE:
                case XML_TEXTWRITER_TEXT:
                    break;
                case XML_TEXTWRITER_NAME:
                    count = xmlOutputBufferWriteString(writer->out, ">");
                    if (count < 0)
                        return -1;
                    sum += count;
                    p->state = XML_TEXTWRITER_TEXT;
                    break;
		default:
		    break;
            }
        }
    }

    count = xmlOutputBufferWriteString(writer->out, "<!--");
    if (count < 0)
        return -1;
    sum += count;
    buf = xmlEncodeEntitiesReentrant(NULL, content);
    if (buf != 0) {
        count = xmlOutputBufferWriteString(writer->out, (const char *)buf);
        xmlFree(buf);
    } else
        count = xmlOutputBufferWriteString(writer->out, (const char *)content);
    if (count < 0)
        return -1;
    sum += count;
    count = xmlOutputBufferWriteString(writer->out, "-->");
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterStartElement:
 * @writer:  the xmlTextWriterPtr
 * @name:  element name
 *
 * Start an xml element.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterStartElement(xmlTextWriterPtr writer, const xmlChar * name)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if ((writer == NULL) || (name == NULL) || (*name == '\0'))
        return -1;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk != 0) {
        p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
        if (p != 0) {
            switch (p->state) {
                case XML_TEXTWRITER_PI:
                case XML_TEXTWRITER_PI_TEXT:
                    return -1;
                case XML_TEXTWRITER_NONE:
                    break;
                case XML_TEXTWRITER_NAME:
                    count = xmlOutputBufferWriteString(writer->out, ">");
                    if (count < 0)
                        return -1;
                    sum += count;
                    p->state = XML_TEXTWRITER_TEXT;
                    break;
		default:
		    break;
            }
        }
    }

    p = (xmlTextWriterStackEntry *)
        xmlMalloc(sizeof(xmlTextWriterStackEntry));
    if (p == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartElement : out of memory!\n");
        return -1;
    }

    p->name = xmlStrdup(name);
    if (p->name == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartElement : out of memory!\n");
        xmlFree(p);
        return -1;
    }
    p->state = XML_TEXTWRITER_NAME;

    xmlListPushFront(writer->nodes, p);

    count = xmlOutputBufferWriteString(writer->out, "<");
    if (count < 0)
        return -1;
    sum += count;
    count = xmlOutputBufferWriteString(writer->out, (const char *)p->name);
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterStartElementNS:
 * @writer:  the xmlTextWriterPtr
 * @prefix:  namespace prefix or NULL
 * @name:  element local name
 * @namespaceURI:  namespace URI or NULL
 *
 * Start an xml element with namespace support.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterStartElementNS(xmlTextWriterPtr writer,
                            const xmlChar * prefix, const xmlChar * name,
                            const xmlChar * namespaceURI)
{
    int count;
    int sum;
    xmlChar *buf;

    if ((writer == NULL) || (name == NULL) || (*name == '\0'))
        return -1;

    buf = 0;
    if (prefix != 0) {
        buf = xmlStrdup(prefix);
        buf = xmlStrcat(buf, BAD_CAST ":");
    }
    buf = xmlStrcat(buf, name);

    sum = 0;
    count = xmlTextWriterStartElement(writer, buf);
    xmlFree(buf);
    if (count < 0)
        return -1;
    sum += count;

    if (namespaceURI != 0) {
        buf = xmlStrdup(BAD_CAST "xmlns");
        if (prefix != 0) {
            buf = xmlStrcat(buf, BAD_CAST ":");
            buf = xmlStrcat(buf, prefix);
        }

        count = xmlTextWriterWriteAttribute(writer, buf, namespaceURI);
        xmlFree(buf);
        if (count < 0)
            return -1;
        sum += count;
    }

    return sum;
}

/**
 * xmlTextWriterEndElement:
 * @writer:  the xmlTextWriterPtr
 *
 * End the current xml element.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterEndElement(xmlTextWriterPtr writer)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return -1;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    sum = 0;
    switch (p->state) {
        case XML_TEXTWRITER_ATTRIBUTE:
            count = xmlTextWriterEndAttribute(writer);
            if (count < 0)
                return -1;
            sum += count;
            /* fallthrough */
        case XML_TEXTWRITER_NAME:
            count = xmlOutputBufferWriteString(writer->out, "/>");
            if (count < 0)
                return -1;
            sum += count;
            break;
        case XML_TEXTWRITER_TEXT:
            count = xmlOutputBufferWriteString(writer->out, "</");
            if (count < 0)
                return -1;
            sum += count;
            count = xmlOutputBufferWriteString(writer->out,
	                                       (const char *)p->name);
            if (count < 0)
                return -1;
            sum += count;
            count = xmlOutputBufferWriteString(writer->out, ">");
            if (count < 0)
                return -1;
            sum += count;
            break;
        default:
            return -1;
    }

    xmlListPopFront(writer->nodes);
    return sum;
}

/**
 * xmlTextWriterFullEndElement:
 * @writer:  the xmlTextWriterPtr
 *
 * End the current xml element. Writes an end tag even if the element is empty
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterFullEndElement(xmlTextWriterPtr writer)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return -1;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    sum = 0;
    switch (p->state) {
        case XML_TEXTWRITER_ATTRIBUTE:
            count = xmlTextWriterEndAttribute(writer);
            if (count < 0)
                return -1;
            sum += count;
            /* fallthrough */
        case XML_TEXTWRITER_NAME:
            count = xmlOutputBufferWriteString(writer->out, ">");
            if (count < 0)
                return -1;
            sum += count;
            /* fallthrough */
        case XML_TEXTWRITER_TEXT:
            count = xmlOutputBufferWriteString(writer->out, "</");
            if (count < 0)
                return -1;
            sum += count;
            count = xmlOutputBufferWriteString(writer->out,
	                                       (const char *) p->name);
            if (count < 0)
                return -1;
            sum += count;
            count = xmlOutputBufferWriteString(writer->out, ">");
            if (count < 0)
                return -1;
            sum += count;
            break;
        default:
            return -1;
    }

    xmlListPopFront(writer->nodes);
    return sum;
}

/**
 * xmlTextWriterWriteFormatRaw:
 * @writer:  the xmlTextWriterPtr
 * @format:  format string (see printf)
 *
 * Write a formatted raw xml text.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatRaw(xmlTextWriterPtr writer, const char *format,
                            ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatRaw(writer, format, ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatRaw:
 * @writer:  the xmlTextWriterPtr
 * @format:  format string (see printf)
 * @argptr:  pointer to the first member of the variable argument list.
 *
 * Write a formatted raw xml text.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatRaw(xmlTextWriterPtr writer, const char *format,
                             va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteRaw(writer, buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWriteStringLen:
 * @writer:  the xmlTextWriterPtr
 * @content:  text string
 * @len:  length of the text string
 *
 * Write an xml text.
 * TODO: what about entities and special chars??
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteRawLen(xmlTextWriterPtr writer, const xmlChar * content,
                         int len)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return 0;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return 0;

    sum = 0;
    switch (p->state) {
        case XML_TEXTWRITER_NONE:
            return -1;
        case XML_TEXTWRITER_NAME:
            count = xmlOutputBufferWriteString(writer->out, ">");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_TEXT;
            break;
        case XML_TEXTWRITER_PI:
            count = xmlOutputBufferWriteString(writer->out, " ");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_PI_TEXT;
            break;
        case XML_TEXTWRITER_DTD:
            count = xmlOutputBufferWriteString(writer->out, " [");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_DTD_TEXT;
            break;
        default:
            break;
    }

    count = xmlOutputBufferWrite(writer->out, len, (const char *) content);
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterWriteRaw:
 * @writer:  the xmlTextWriterPtr
 * @content:  text string
 *
 * Write a raw xml text.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteRaw(xmlTextWriterPtr writer, const xmlChar * content)
{
    return xmlTextWriterWriteRawLen(writer, content, xmlStrlen(content));
}

/**
 * xmlTextWriterWriteFormatString:
 * @writer:  the xmlTextWriterPtr
 * @format:  format string (see printf)
 *
 * Write a formatted xml text.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatString(xmlTextWriterPtr writer, const char *format,
                               ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatString(writer, format, ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatString:
 * @writer:  the xmlTextWriterPtr
 * @format:  format string (see printf)
 * @argptr:  pointer to the first member of the variable argument list.
 *
 * Write a formatted xml text.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatString(xmlTextWriterPtr writer,
                                const char *format, va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteString(writer, buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWriteString:
 * @writer:  the xmlTextWriterPtr
 * @content:  text string
 *
 * Write an xml text.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteString(xmlTextWriterPtr writer, const xmlChar * content)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;
    xmlChar *buf = NULL;

    if (writer == NULL)
        return -1;

    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return -1;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    sum = 0;
    switch (p->state) {
        case XML_TEXTWRITER_NONE:
            return -1;
        case XML_TEXTWRITER_NAME:
            count = xmlOutputBufferWriteString(writer->out, ">");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_TEXT;
            goto encode;
        case XML_TEXTWRITER_PI:
            count = xmlOutputBufferWriteString(writer->out, " ");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_PI_TEXT;
            /* fallthrough */
        case XML_TEXTWRITER_PI_TEXT:
        case XML_TEXTWRITER_TEXT:
        case XML_TEXTWRITER_ATTRIBUTE:
          encode:
            buf = xmlEncodeEntitiesReentrant(NULL, content);
            break;
        case XML_TEXTWRITER_DTD:
            count = xmlOutputBufferWriteString(writer->out, " [");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_DTD_TEXT;
            /* fallthrough */
        case XML_TEXTWRITER_DTD_TEXT:
        case XML_TEXTWRITER_DTD_ELEM:
        case XML_TEXTWRITER_CDATA:
            buf = xmlStrdup(content);
            break;
	default:
	    break;
    }

    if (buf != 0) {
        count = xmlOutputBufferWriteString(writer->out, (const char *) buf);
        xmlFree(buf);
    } else
        count = -1;
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlOutputBufferWriteBase64:
 * @out: the xmlOutputBufferPtr
 * @data:   binary data
 * @len:  the number of bytes to encode
 *
 * Write base64 encoded data to an xmlOutputBuffer.
 * Adapted from John Walker's base64.c (http://www.fourmilab.ch/).
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
static int
xmlOutputBufferWriteBase64(xmlOutputBufferPtr out, int len,
                           const unsigned char *data)
{
    static unsigned char dtable[64] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    int i;
    int linelen;
    int count;
    int sum;

    linelen = 0;
    sum = 0;

    i = 0;
    while (1) {
        unsigned char igroup[3];
        unsigned char ogroup[4];
        int c;
        int n;

        igroup[0] = igroup[1] = igroup[2] = 0;
        for (n = 0; n < 3 && i < len; n++, i++) {
            c = data[i];
            igroup[n] = (unsigned char) c;
        }

        if (n > 0) {
            ogroup[0] = dtable[igroup[0] >> 2];
            ogroup[1] = dtable[((igroup[0] & 3) << 4) | (igroup[1] >> 4)];
            ogroup[2] =
                dtable[((igroup[1] & 0xF) << 2) | (igroup[2] >> 6)];
            ogroup[3] = dtable[igroup[2] & 0x3F];

            if (n < 3) {
                ogroup[3] = '=';
                if (n < 2) {
                    ogroup[2] = '=';
                }
            }

            if (linelen >= B64LINELEN) {
                count = xmlOutputBufferWrite(out, 2, B64CRLF);
                if (count == -1)
                    return -1;
                sum += count;
                linelen = 0;
            }
            count = xmlOutputBufferWrite(out, 4, (const char *) ogroup);
            if (count == -1)
                return -1;
            sum += count;

            linelen += 4;
        }

        if (i >= len)
            break;
    }

    count = xmlOutputBufferWrite(out, 2, B64CRLF);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterWriteBase64:
 * @writer: the xmlTextWriterPtr
 * @data:   binary data
 * @start:  the position within the data of the first byte to encode
 * @len:  the number of bytes to encode
 *
 * Write an base64 encoded xml text.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteBase64(xmlTextWriterPtr writer, const char * data,
                         int start, int len)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return 0;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return 0;

    sum = 0;
    switch (p->state) {
        case XML_TEXTWRITER_NONE:
            return -1;
        case XML_TEXTWRITER_NAME:
            count = xmlOutputBufferWriteString(writer->out, ">");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_TEXT;
            break;
        case XML_TEXTWRITER_PI:
            count = xmlOutputBufferWriteString(writer->out, " ");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_PI_TEXT;
            break;
        case XML_TEXTWRITER_DTD:
            count = xmlOutputBufferWriteString(writer->out, " [");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_DTD_TEXT;
            break;
        default:
            break;
    }

    count =
        xmlOutputBufferWriteBase64(writer->out, len,
                                   (unsigned char *) data + start);
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlOutputBufferWriteBinHex:
 * @out: the xmlOutputBufferPtr
 * @data:   binary data
 * @len:  the number of bytes to encode
 *
 * Write hqx encoded data to an xmlOutputBuffer.
 * ::todo
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
static int
xmlOutputBufferWriteBinHex(xmlOutputBufferPtr out ATTRIBUTE_UNUSED,
                           int len ATTRIBUTE_UNUSED,
                           const unsigned char *data ATTRIBUTE_UNUSED)
{
    return -1;
}

/**
 * xmlTextWriterWriteBinHex:
 * @writer: the xmlTextWriterPtr
 * @data:   binary data
 * @start:  the position within the data of the first byte to encode
 * @len:  the number of bytes to encode
 *
 * Write a BinHex encoded xml text.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteBinHex(xmlTextWriterPtr writer, const char * data,
                         int start, int len)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return 0;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return 0;

    sum = 0;
    switch (p->state) {
        case XML_TEXTWRITER_NONE:
            return -1;
        case XML_TEXTWRITER_NAME:
            count = xmlOutputBufferWriteString(writer->out, ">");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_TEXT;
            break;
        case XML_TEXTWRITER_PI:
            count = xmlOutputBufferWriteString(writer->out, " ");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_PI_TEXT;
            break;
        case XML_TEXTWRITER_DTD:
            count = xmlOutputBufferWriteString(writer->out, " [");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_DTD_TEXT;
            break;
        default:
            break;
    }

    count =
        xmlOutputBufferWriteBinHex(writer->out, len,
                                   (unsigned char *) data + start);
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterStartAttribute:
 * @writer:  the xmlTextWriterPtr
 * @name:  element name
 *
 * Start an xml attribute.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterStartAttribute(xmlTextWriterPtr writer, const xmlChar * name)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if ((writer == NULL) || (name == NULL) || (*name == '\0'))
        return -1;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return -1;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    switch (p->state) {
        case XML_TEXTWRITER_ATTRIBUTE:
            count = xmlTextWriterEndAttribute(writer);
            if (count < 0)
                return -1;
            sum += count;
            /* fallthrough */
        case XML_TEXTWRITER_NAME:
            count = xmlOutputBufferWriteString(writer->out, " ");
            if (count < 0)
                return -1;
            sum += count;
            count = xmlOutputBufferWriteString(writer->out, (const char *)name);
            if (count < 0)
                return -1;
            sum += count;
            count = xmlOutputBufferWriteString(writer->out, "=");
            if (count < 0)
                return -1;
            sum += count;
            count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_ATTRIBUTE;
            break;
        default:
            return -1;
    }

    return sum;
}

/**
 * xmlTextWriterStartAttributeNS:
 * @writer:  the xmlTextWriterPtr
 * @prefix:  namespace prefix or NULL
 * @name:  element local name
 * @namespaceURI:  namespace URI or NULL
 *
 * Start an xml attribute with namespace support.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterStartAttributeNS(xmlTextWriterPtr writer,
                              const xmlChar * prefix, const xmlChar * name,
                              const xmlChar * namespaceURI)
{
    int count;
    int sum;
    xmlChar *buf;
    xmlTextWriterNsStackEntry *p;

    if ((writer == NULL) || (name == NULL) || (*name == '\0'))
        return -1;

    buf = 0;
    if (prefix != 0) {
        buf = xmlStrdup(prefix);
        buf = xmlStrcat(buf, BAD_CAST ":");
    }
    buf = xmlStrcat(buf, name);

    sum = 0;
    count = xmlTextWriterStartAttribute(writer, buf);
    xmlFree(buf);
    if (count < 0)
        return -1;
    sum += count;

    if (namespaceURI != 0) {
        buf = xmlStrdup(BAD_CAST "xmlns");
        if (prefix != 0) {
            buf = xmlStrcat(buf, BAD_CAST ":");
            buf = xmlStrcat(buf, prefix);
        }

        p = (xmlTextWriterNsStackEntry *)
            xmlMalloc(sizeof(xmlTextWriterNsStackEntry));
        if (p == 0) {
            xmlGenericError(xmlGenericErrorContext,
                            "xmlTextWriterStartAttributeNS : out of memory!\n");
            return -1;
        }

        p->prefix = buf;
        p->uri = xmlStrdup(namespaceURI);
        if (p->uri == 0) {
            xmlGenericError(xmlGenericErrorContext,
                            "xmlTextWriterStartAttributeNS : out of memory!\n");
            xmlFree(p);
            return -1;
        }
        p->elem = xmlListFront(writer->nodes);

        xmlListPushFront(writer->nsstack, p);
    }

    return sum;
}

/**
 * xmlTextWriterEndAttribute:
 * @writer:  the xmlTextWriterPtr
 *
 * End the current xml element.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterEndAttribute(xmlTextWriterPtr writer)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;
    xmlTextWriterNsStackEntry *np;

    if (writer == NULL)
        return -1;

    lk = xmlListFront(writer->nodes);
    if (lk == 0) {
        xmlListDelete(writer->nsstack);
        return -1;
    }

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0) {
        xmlListDelete(writer->nsstack);
        return -1;
    }

    sum = 0;
    switch (p->state) {
        case XML_TEXTWRITER_ATTRIBUTE:
            p->state = XML_TEXTWRITER_NAME;

            count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
            if (count < 0) {
                xmlListDelete(writer->nsstack);
                return -1;
            }
            sum += count;

            while (!xmlListEmpty(writer->nsstack)) {
                lk = xmlListFront(writer->nsstack);
                np = (xmlTextWriterNsStackEntry *) xmlLinkGetData(lk);
                if (np != 0) {
                    count =
                        xmlTextWriterWriteAttribute(writer, np->prefix,
                                                    np->uri);
                    if (count < 0) {
                        xmlListDelete(writer->nsstack);
                        return -1;
                    }
                    sum += count;
                }

                xmlListPopFront(writer->nsstack);
            }
            break;

        default:
            xmlListClear(writer->nsstack);
            return -1;
    }

    return sum;
}

/**
 * xmlTextWriterWriteFormatAttribute:
 * @writer:  the xmlTextWriterPtr
 * @name:  attribute name
 * @format:  format string (see printf)
 *
 * Write a formatted xml attribute.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatAttribute(xmlTextWriterPtr writer,
                                  const xmlChar * name, const char *format,
                                  ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatAttribute(writer, name, format, ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatAttribute:
 * @writer:  the xmlTextWriterPtr
 * @name:  attribute name
 * @format:  format string (see printf)
 * @argptr:  pointer to the first member of the variable argument list.
 *
 * Write a formatted xml attribute.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatAttribute(xmlTextWriterPtr writer,
                                   const xmlChar * name,
                                   const char *format, va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteAttribute(writer, name, buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWriteAttribute:
 * @writer:  the xmlTextWriterPtr
 * @name:  attribute name
 * @content:  attribute content
 *
 * Write an xml attribute.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteAttribute(xmlTextWriterPtr writer, const xmlChar * name,
                            const xmlChar * content)
{
    int count;
    int sum;

    sum = 0;
    count = xmlTextWriterStartAttribute(writer, name);
    if (count < 0)
        return -1;
    sum += count;
    count = xmlTextWriterWriteString(writer, content);
    if (count < 0)
        return -1;
    sum += count;
    count = xmlTextWriterEndAttribute(writer);
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterWriteFormatAttributeNS:
 * @writer:  the xmlTextWriterPtr
 * @prefix:  namespace prefix
 * @name:  attribute local name
 * @namespaceURI:  namespace URI
 * @format:  format string (see printf)
 *
 * Write a formatted xml attribute.with namespace support
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatAttributeNS(xmlTextWriterPtr writer,
                                    const xmlChar * prefix,
                                    const xmlChar * name,
                                    const xmlChar * namespaceURI,
                                    const char *format, ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatAttributeNS(writer, prefix, name,
                                              namespaceURI, format, ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatAttributeNS:
 * @writer:  the xmlTextWriterPtr
 * @prefix:  namespace prefix
 * @name:  attribute local name
 * @namespaceURI:  namespace URI
 * @format:  format string (see printf)
 * @argptr:  pointer to the first member of the variable argument list.
 *
 * Write a formatted xml attribute.with namespace support
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatAttributeNS(xmlTextWriterPtr writer,
                                     const xmlChar * prefix,
                                     const xmlChar * name,
                                     const xmlChar * namespaceURI,
                                     const char *format, va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteAttributeNS(writer, prefix, name, namespaceURI,
                                       buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWriteAttributeNS:
 * @writer:  the xmlTextWriterPtr
 * @prefix:  namespace prefix
 * @name:  attribute local name
 * @namespaceURI:  namespace URI
 * @content:  attribute content
 *
 * Write an xml attribute.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteAttributeNS(xmlTextWriterPtr writer,
                              const xmlChar * prefix, const xmlChar * name,
                              const xmlChar * namespaceURI,
                              const xmlChar * content)
{
    int count;
    int sum;
    xmlChar *buf;

    if ((writer == NULL) || (name == NULL) || (*name == '\0'))
        return -1;

    buf = 0;
    if (prefix != NULL) {
        buf = xmlStrdup(prefix);
        buf = xmlStrcat(buf, BAD_CAST ":");
    }
    buf = xmlStrcat(buf, name);

    sum = 0;
    count = xmlTextWriterWriteAttribute(writer, buf, content);
    xmlFree(buf);
    if (count < 0)
        return -1;
    sum += count;

    if (namespaceURI != NULL) {
        buf = 0;
        buf = xmlStrdup(BAD_CAST "xmlns");
        if (prefix != NULL) {
            buf = xmlStrcat(buf, BAD_CAST ":");
            buf = xmlStrcat(buf, prefix);
        }
        count = xmlTextWriterWriteAttribute(writer, buf, namespaceURI);
        xmlFree(buf);
        if (count < 0)
            return -1;
        sum += count;
    }
    return sum;
}

/**
 * xmlTextWriterWriteFormatElement:
 * @writer:  the xmlTextWriterPtr
 * @name:  element name
 * @format:  format string (see printf)
 *
 * Write a formatted xml element.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatElement(xmlTextWriterPtr writer,
                                const xmlChar * name, const char *format,
                                ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatElement(writer, name, format, ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatElement:
 * @writer:  the xmlTextWriterPtr
 * @name:  element name
 * @format:  format string (see printf)
 * @argptr:  pointer to the first member of the variable argument list.
 *
 * Write a formatted xml element.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatElement(xmlTextWriterPtr writer,
                                 const xmlChar * name, const char *format,
                                 va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteElement(writer, name, buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWriteElement:
 * @writer:  the xmlTextWriterPtr
 * @name:  element name
 * @content:  element content
 *
 * Write an xml element.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteElement(xmlTextWriterPtr writer, const xmlChar * name,
                          const xmlChar * content)
{
    int count;
    int sum;

    sum = 0;
    count = xmlTextWriterStartElement(writer, name);
    if (count == -1)
        return -1;
    sum += count;
    count = xmlTextWriterWriteString(writer, content);
    if (count == -1)
        return -1;
    sum += count;
    count = xmlTextWriterEndElement(writer);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterWriteFormatElementNS:
 * @writer:  the xmlTextWriterPtr
 * @prefix:  namespace prefix
 * @name:  element local name
 * @namespaceURI:  namespace URI
 * @format:  format string (see printf)
 *
 * Write a formatted xml element with namespace support.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatElementNS(xmlTextWriterPtr writer,
                                  const xmlChar * prefix,
                                  const xmlChar * name,
                                  const xmlChar * namespaceURI,
                                  const char *format, ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatElementNS(writer, prefix, name,
                                            namespaceURI, format, ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatElementNS:
 * @writer:  the xmlTextWriterPtr
 * @prefix:  namespace prefix
 * @name:  element local name
 * @namespaceURI:  namespace URI
 * @format:  format string (see printf)
 * @argptr:  pointer to the first member of the variable argument list.
 *
 * Write a formatted xml element with namespace support.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatElementNS(xmlTextWriterPtr writer,
                                   const xmlChar * prefix,
                                   const xmlChar * name,
                                   const xmlChar * namespaceURI,
                                   const char *format, va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteElementNS(writer, prefix, name, namespaceURI,
                                     buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWriteElementNS:
 * @writer:  the xmlTextWriterPtr
 * @prefix:  namespace prefix
 * @name:  element local name
 * @namespaceURI:  namespace URI
 * @content:  element content
 *
 * Write an xml element with namespace support.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteElementNS(xmlTextWriterPtr writer,
                            const xmlChar * prefix, const xmlChar * name,
                            const xmlChar * namespaceURI,
                            const xmlChar * content)
{
    int count;
    int sum;

    if ((writer == NULL) || (name == NULL) || (*name == '\0'))
        return -1;

    sum = 0;
    count =
        xmlTextWriterStartElementNS(writer, prefix, name, namespaceURI);
    if (count < 0)
        return -1;
    sum += count;
    count = xmlTextWriterWriteString(writer, content);
    if (count == -1)
        return -1;
    sum += count;
    count = xmlTextWriterEndElement(writer);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterStartPI:
 * @writer:  the xmlTextWriterPtr
 * @target:  PI target
 *
 * Start an xml PI.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterStartPI(xmlTextWriterPtr writer, const xmlChar * target)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if ((writer == NULL) || (target == NULL) || (*target == '\0'))
        return -1;

    if (xmlStrcasecmp(target, (const xmlChar *) "xml") == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartPI : target name [Xx][Mm][Ll] is reserved for xml standardization!\n");
        return -1;
    }

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk != 0) {
        p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
        if (p != 0) {
            switch (p->state) {
                case XML_TEXTWRITER_ATTRIBUTE:
                    count = xmlTextWriterEndAttribute(writer);
                    if (count < 0)
                        return -1;
                    sum += count;
                    /* fallthrough */
                case XML_TEXTWRITER_NAME:
                    count = xmlOutputBufferWriteString(writer->out, ">");
                    if (count < 0)
                        return -1;
                    sum += count;
                    p->state = XML_TEXTWRITER_TEXT;
                    break;
                case XML_TEXTWRITER_PI:
                case XML_TEXTWRITER_PI_TEXT:
                    xmlGenericError(xmlGenericErrorContext,
                                    "xmlTextWriterStartPI : nested PI!\n");
                    return -1;
                default:
                    return -1;
            }
        }
    }

    p = (xmlTextWriterStackEntry *)
        xmlMalloc(sizeof(xmlTextWriterStackEntry));
    if (p == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartPI : out of memory!\n");
        return -1;
    }

    p->name = xmlStrdup(target);
    if (p->name == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartPI : out of memory!\n");
        xmlFree(p);
        return -1;
    }
    p->state = XML_TEXTWRITER_PI;

    xmlListPushFront(writer->nodes, p);

    count = xmlOutputBufferWriteString(writer->out, "<?");
    if (count < 0)
        return -1;
    sum += count;
    count = xmlOutputBufferWriteString(writer->out, (const char *) p->name);
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterEndPI:
 * @writer:  the xmlTextWriterPtr
 *
 * End the current xml PI.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterEndPI(xmlTextWriterPtr writer)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return 0;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return 0;

    sum = 0;
    switch (p->state) {
        case XML_TEXTWRITER_PI:
        case XML_TEXTWRITER_PI_TEXT:
            count = xmlOutputBufferWriteString(writer->out, "?>");
            if (count < 0)
                return -1;
            sum += count;
            break;
        default:
            return -1;
    }

    xmlListPopFront(writer->nodes);
    return sum;
}

/**
 * xmlTextWriterWriteFormatPI:
 * @writer:  the xmlTextWriterPtr
 * @target:  PI target
 * @format:  format string (see printf)
 *
 * Write a formatted PI.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatPI(xmlTextWriterPtr writer, const xmlChar * target,
                           const char *format, ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatPI(writer, target, format, ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatPI:
 * @writer:  the xmlTextWriterPtr
 * @target:  PI target
 * @format:  format string (see printf)
 *
 * Write a formatted xml PI.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatPI(xmlTextWriterPtr writer,
                            const xmlChar * target, const char *format,
                            va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWritePI(writer, target, buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWritePI:
 * @writer:  the xmlTextWriterPtr
 * @target:  PI target
 * @content:  PI content
 *
 * Write an xml PI.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWritePI(xmlTextWriterPtr writer, const xmlChar * target,
                     const xmlChar * content)
{
    int count;
    int sum;

    sum = 0;
    count = xmlTextWriterStartPI(writer, target);
    if (count == -1)
        return -1;
    sum += count;
    if (content != 0) {
        count = xmlTextWriterWriteString(writer, content);
        if (count == -1)
            return -1;
        sum += count;
    }
    count = xmlTextWriterEndPI(writer);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterStartCDATA:
 * @writer:  the xmlTextWriterPtr
 *
 * Start an xml CDATA section.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterStartCDATA(xmlTextWriterPtr writer)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk != 0) {
        p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
        if (p != 0) {
            switch (p->state) {
                case XML_TEXTWRITER_NONE:
                case XML_TEXTWRITER_PI:
                case XML_TEXTWRITER_PI_TEXT:
                    break;
                case XML_TEXTWRITER_ATTRIBUTE:
                    count = xmlTextWriterEndAttribute(writer);
                    if (count < 0)
                        return -1;
                    sum += count;
                    /* fallthrough */
                case XML_TEXTWRITER_NAME:
                    count = xmlOutputBufferWriteString(writer->out, ">");
                    if (count < 0)
                        return -1;
                    sum += count;
                    p->state = XML_TEXTWRITER_TEXT;
                    break;
                case XML_TEXTWRITER_CDATA:
                    xmlGenericError(xmlGenericErrorContext,
                                    "xmlTextWriterStartCDATA : CDATA not allowed in this context!\n");
                    return -1;
                default:
                    return -1;
            }
        }
    }

    p = (xmlTextWriterStackEntry *)
        xmlMalloc(sizeof(xmlTextWriterStackEntry));
    if (p == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartCDATA : out of memory!\n");
        return -1;
    }

    p->name = 0;
    p->state = XML_TEXTWRITER_CDATA;

    xmlListPushFront(writer->nodes, p);

    count = xmlOutputBufferWriteString(writer->out, "<![CDATA[");
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterEndCDATA:
 * @writer:  the xmlTextWriterPtr
 *
 * End an xml CDATA section.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterEndCDATA(xmlTextWriterPtr writer)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return -1;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    sum = 0;
    switch (p->state) {
        case XML_TEXTWRITER_CDATA:
            count = xmlOutputBufferWriteString(writer->out, "]]>");
            if (count < 0)
                return -1;
            sum += count;
            break;
        default:
            return -1;
    }

    xmlListPopFront(writer->nodes);
    return sum;
}

/**
 * xmlTextWriterWriteFormatCDATA:
 * @writer:  the xmlTextWriterPtr
 * @format:  format string (see printf)
 *
 * Write a formatted xml CDATA.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatCDATA(xmlTextWriterPtr writer, const char *format,
                              ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatCDATA(writer, format, ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatCDATA:
 * @writer:  the xmlTextWriterPtr
 * @format:  format string (see printf)
 *
 * Write a formatted xml CDATA.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatCDATA(xmlTextWriterPtr writer, const char *format,
                               va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteCDATA(writer, buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWriteCDATA:
 * @writer:  the xmlTextWriterPtr
 * @content:  CDATA content
 *
 * Write an xml CDATA.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteCDATA(xmlTextWriterPtr writer, const xmlChar * content)
{
    int count;
    int sum;

    sum = 0;
    count = xmlTextWriterStartCDATA(writer);
    if (count == -1)
        return -1;
    sum += count;
    if (content != 0) {
        count = xmlTextWriterWriteString(writer, content);
        if (count == -1)
            return -1;
        sum += count;
    }
    count = xmlTextWriterEndCDATA(writer);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterStartDTD:
 * @writer:  the xmlTextWriterPtr
 * @name:  the name of the DTD
 * @pubid:  the public identifier, which is an alternative to the system identifier
 * @sysid:  the system identifier, which is the URI of the DTD
 *
 * Start an xml DTD.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterStartDTD(xmlTextWriterPtr writer,
                      const xmlChar * name,
                      const xmlChar * pubid, const xmlChar * sysid)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL || name == NULL || *name == '\0')
        return -1;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk != 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDTD : DTD allowed only in prolog!\n");
        return -1;
    }

    p = (xmlTextWriterStackEntry *)
        xmlMalloc(sizeof(xmlTextWriterStackEntry));
    if (p == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDTD : out of memory!\n");
        return -1;
    }

    p->name = xmlStrdup(name);
    if (p->name == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDTD : out of memory!\n");
        xmlFree(p);
        return -1;
    }
    p->state = XML_TEXTWRITER_DTD;

    xmlListPushFront(writer->nodes, p);

    count = xmlOutputBufferWriteString(writer->out, "<!DOCTYPE ");
    if (count < 0)
        return -1;
    sum += count;
    count = xmlOutputBufferWriteString(writer->out, (const char *) name);
    if (count < 0)
        return -1;
    sum += count;

    if (pubid != 0) {
        if (sysid == 0) {
            xmlGenericError(xmlGenericErrorContext,
                            "xmlTextWriterStartDTD : system identifier needed!\n");
            return -1;
        }

        count = xmlOutputBufferWriteString(writer->out, " PUBLIC \"");
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWriteString(writer->out, (const char *) pubid);
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWriteString(writer->out, "\"");
        if (count < 0)
            return -1;
        sum += count;
    }

    if (sysid != 0) {
        if (pubid == 0) {
            count = xmlOutputBufferWriteString(writer->out, " SYSTEM");
            if (count < 0)
                return -1;
            sum += count;
        }

        count = xmlOutputBufferWriteString(writer->out, " \"");
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWriteString(writer->out, (const char *) sysid);
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWriteString(writer->out, "\"");
        if (count < 0)
            return -1;
        sum += count;
    }

    return sum;
}

/**
 * xmlTextWriterEndDTD:
 * @writer:  the xmlTextWriterPtr
 *
 * End an xml DTD.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterEndDTD(xmlTextWriterPtr writer)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL)
        return -1;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk == 0)
        return -1;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    switch (p->state) {
        case XML_TEXTWRITER_DTD_TEXT:
            count = xmlOutputBufferWriteString(writer->out, "]");
            if (count < 0)
                return -1;
            sum += count;
            /* fallthrough */
        case XML_TEXTWRITER_DTD:
        case XML_TEXTWRITER_DTD_ELEM:
        case XML_TEXTWRITER_DTD_ATTL:
            count = xmlOutputBufferWriteString(writer->out, ">");
            if (count < 0)
                return -1;
            sum += count;
            break;
        default:
            return -1;
    }

    xmlListPopFront(writer->nodes);
    return sum;
}

/**
 * xmlTextWriterWriteFormatDTD:
 * @writer:  the xmlTextWriterPtr
 * @name:  the name of the DTD
 * @pubid:  the public identifier, which is an alternative to the system identifier
 * @sysid:  the system identifier, which is the URI of the DTD
 * @format:  format string (see printf)
 *
 * Write a DTD with a formatted markup declarations part.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteFormatDTD(xmlTextWriterPtr writer,
                            const xmlChar * name,
                            const xmlChar * pubid,
                            const xmlChar * sysid, const char *format, ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatDTD(writer, name, pubid, sysid, format,
                                      ap);

    va_end(ap);
    return rc;
}

/**
 * xmlTextWriterWriteVFormatDTD:
 * @writer:  the xmlTextWriterPtr
 * @name:  the name of the DTD
 * @pubid:  the public identifier, which is an alternative to the system identifier
 * @sysid:  the system identifier, which is the URI of the DTD
 * @format:  format string (see printf)
 *
 * Write a DTD with a formatted markup declarations part.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteVFormatDTD(xmlTextWriterPtr writer,
                             const xmlChar * name,
                             const xmlChar * pubid,
                             const xmlChar * sysid,
                             const char *format, va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteDTD(writer, name, pubid, sysid, buf);

    xmlFree(buf);
    return rc;
}

/**
 * xmlTextWriterWriteDTD:
 * @writer:  the xmlTextWriterPtr
 * @name:  the name of the DTD
 * @pubid:  the public identifier, which is an alternative to the system identifier
 * @sysid:  the system identifier, which is the URI of the DTD
 * @format:  format string (see printf)
 *
 * Write a DTD.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterWriteDTD(xmlTextWriterPtr writer,
                      const xmlChar * name,
                      const xmlChar * pubid,
                      const xmlChar * sysid, const xmlChar * subset)
{
    int count;
    int sum;

    sum = 0;
    count = xmlTextWriterStartDTD(writer, name, pubid, sysid);
    if (count == -1)
        return -1;
    sum += count;
    if (subset != 0) {
        count = xmlTextWriterWriteString(writer, subset);
        if (count == -1)
            return -1;
        sum += count;
    }
    count = xmlTextWriterEndDTD(writer);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

int
xmlTextWriterStartDTDElement(xmlTextWriterPtr writer, const xmlChar * name)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL || name == NULL || *name == '\0')
        return -1;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk == 0) {
        return -1;
    }

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    switch (p->state) {
        case XML_TEXTWRITER_DTD:
            count = xmlOutputBufferWriteString(writer->out, " [");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_DTD_TEXT;
            /* fallthrough */
        case XML_TEXTWRITER_DTD_TEXT:
            break;
        case XML_TEXTWRITER_DTD_ELEM:
            count = xmlTextWriterEndDTDElement(writer);
            if (count < 0)
                return -1;
            sum += count;
            break;
        default:
            return -1;
    }

    p = (xmlTextWriterStackEntry *)
        xmlMalloc(sizeof(xmlTextWriterStackEntry));
    if (p == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDTDElement : out of memory!\n");
        return -1;
    }

    p->name = xmlStrdup(name);
    if (p->name == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDTDElement : out of memory!\n");
        xmlFree(p);
        return -1;
    }
    p->state = XML_TEXTWRITER_DTD_ELEM;

    xmlListPushFront(writer->nodes, p);

    count = xmlOutputBufferWriteString(writer->out, "<!ELEMENT ");
    if (count < 0)
        return -1;
    sum += count;
    count = xmlOutputBufferWriteString(writer->out, (const char *) name);
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

int
xmlTextWriterWriteFormatDTDElement(xmlTextWriterPtr writer,
                                   const xmlChar * name,
                                   const char *format, ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatDTDElement(writer, name, format, ap);

    va_end(ap);
    return rc;
}

int
xmlTextWriterWriteVFormatDTDElement(xmlTextWriterPtr writer,
                                    const xmlChar * name,
                                    const char *format, va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteDTDElement(writer, name, buf);

    xmlFree(buf);
    return rc;
}

int
xmlTextWriterWriteDTDElement(xmlTextWriterPtr writer,
                             const xmlChar * name, const xmlChar * content)
{
    int count;
    int sum;

    if (content == NULL)
        return -1;

    sum = 0;
    count = xmlTextWriterStartDTDElement(writer, name);
    if (count == -1)
        return -1;
    sum += count;

    count = xmlTextWriterWriteString(writer, BAD_CAST " ");
    if (count == -1)
        return -1;
    sum += count;
    count = xmlTextWriterWriteString(writer, content);
    if (count == -1)
        return -1;
    sum += count;

    count = xmlTextWriterEndDTDElement(writer);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

int
xmlTextWriterStartDTDAttlist(xmlTextWriterPtr writer, const xmlChar * name)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL || name == NULL || *name == '\0')
        return -1;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk == 0) {
        return -1;
    }

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    switch (p->state) {
        case XML_TEXTWRITER_DTD:
            count = xmlOutputBufferWriteString(writer->out, " [");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_DTD_TEXT;
            /* fallthrough */
        case XML_TEXTWRITER_DTD_TEXT:
            break;
        case XML_TEXTWRITER_DTD_ELEM:
        case XML_TEXTWRITER_DTD_ATTL:
        case XML_TEXTWRITER_DTD_ENTY:
            count = xmlTextWriterEndDTD(writer);
            if (count < 0)
                return -1;
            sum += count;
            break;
        default:
            return -1;
    }

    p = (xmlTextWriterStackEntry *)
        xmlMalloc(sizeof(xmlTextWriterStackEntry));
    if (p == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDTDAttlist : out of memory!\n");
        return -1;
    }

    p->name = xmlStrdup(name);
    if (p->name == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDTDAttlist : out of memory!\n");
        xmlFree(p);
        return -1;
    }
    p->state = XML_TEXTWRITER_DTD_ATTL;

    xmlListPushFront(writer->nodes, p);

    count = xmlOutputBufferWriteString(writer->out, "<!ATTLIST ");
    if (count < 0)
        return -1;
    sum += count;
    count = xmlOutputBufferWriteString(writer->out, (const char *)name);
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

int
xmlTextWriterWriteFormatDTDAttlist(xmlTextWriterPtr writer,
                                   const xmlChar * name,
                                   const char *format, ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatDTDAttlist(writer, name, format, ap);

    va_end(ap);
    return rc;
}

int
xmlTextWriterWriteVFormatDTDAttlist(xmlTextWriterPtr writer,
                                    const xmlChar * name,
                                    const char *format, va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteDTDAttlist(writer, name, buf);

    xmlFree(buf);
    return rc;
}

int
xmlTextWriterWriteDTDAttlist(xmlTextWriterPtr writer,
                             const xmlChar * name, const xmlChar * content)
{
    int count;
    int sum;

    if (content == NULL)
        return -1;

    sum = 0;
    count = xmlTextWriterStartDTDAttlist(writer, name);
    if (count == -1)
        return -1;
    sum += count;

    count = xmlTextWriterWriteString(writer, BAD_CAST " ");
    if (count == -1)
        return -1;
    sum += count;
    count = xmlTextWriterWriteString(writer, content);
    if (count == -1)
        return -1;
    sum += count;

    count = xmlTextWriterEndDTDAttlist(writer);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

int
xmlTextWriterStartDTDEntity(xmlTextWriterPtr writer,
                            int pe, const xmlChar * name)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL || name == NULL || *name == '\0')
        return -1;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk == 0) {
        return -1;
    }

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    switch (p->state) {
        case XML_TEXTWRITER_DTD:
            count = xmlOutputBufferWriteString(writer->out, " [");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_DTD_TEXT;
            /* fallthrough */
        case XML_TEXTWRITER_DTD_TEXT:
            break;
        case XML_TEXTWRITER_DTD_ELEM:
        case XML_TEXTWRITER_DTD_ATTL:
        case XML_TEXTWRITER_DTD_ENTY:
            count = xmlTextWriterEndDTD(writer);
            if (count < 0)
                return -1;
            sum += count;
            break;
        default:
            return -1;
    }

    p = (xmlTextWriterStackEntry *)
        xmlMalloc(sizeof(xmlTextWriterStackEntry));
    if (p == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDTDElement : out of memory!\n");
        return -1;
    }

    p->name = xmlStrdup(name);
    if (p->name == 0) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterStartDTDElement : out of memory!\n");
        xmlFree(p);
        return -1;
    }
    p->state = XML_TEXTWRITER_DTD_ENTY;

    xmlListPushFront(writer->nodes, p);

    count = xmlOutputBufferWriteString(writer->out, "<!ENTITY ");
    if (count < 0)
        return -1;
    sum += count;

    if (pe != 0) {
        count = xmlOutputBufferWriteString(writer->out, " % ");
        if (count < 0)
            return -1;
        sum += count;
    }

    count = xmlOutputBufferWriteString(writer->out, (const char *)name);
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

int
xmlTextWriterWriteFormatDTDInternalEntity(xmlTextWriterPtr writer,
                                          int pe,
                                          const xmlChar * name,
                                          const char *format, ...)
{
    int rc;
    va_list ap;

    va_start(ap, format);

    rc = xmlTextWriterWriteVFormatDTDInternalEntity(writer, pe, name,
                                                    format, ap);

    va_end(ap);
    return rc;
}

int
xmlTextWriterWriteVFormatDTDInternalEntity(xmlTextWriterPtr writer,
                                           int pe,
                                           const xmlChar * name,
                                           const char *format,
                                           va_list argptr)
{
    int rc;
    xmlChar *buf;

    if (writer == NULL)
        return -1;

    buf = xmlTextWriterVSprintf(format, argptr);
    if (buf == 0)
        return 0;

    rc = xmlTextWriterWriteDTDInternalEntity(writer, pe, name, buf);

    xmlFree(buf);
    return rc;
}

int
xmlTextWriterWriteDTDEntity(xmlTextWriterPtr writer,
                            int pe,
                            const xmlChar * name,
                            const xmlChar * pubid,
                            const xmlChar * sysid,
                            const xmlChar * ndataid,
                            const xmlChar * content)
{
    if (((content == NULL) && (pubid == NULL) && (sysid == NULL))
        || ((content != NULL) && ((pubid != NULL) || (sysid != NULL))))
        return -1;
    if ((pe != 0) && (ndataid != NULL))
        return -1;

    if (content != 0)
        return xmlTextWriterWriteDTDInternalEntity(writer, pe, name,
                                                   content);

    return xmlTextWriterWriteDTDExternalEntity(writer, pe, name, pubid,
                                               sysid, ndataid);
}

int
xmlTextWriterWriteDTDInternalEntity(xmlTextWriterPtr writer,
                                    int pe,
                                    const xmlChar * name,
                                    const xmlChar * content)
{
    int count;
    int sum;

    if ((name == NULL) || (*name == '\0') || (content == NULL))
        return -1;

    sum = 0;
    count = xmlTextWriterStartDTDEntity(writer, pe, name);
    if (count == -1)
        return -1;
    sum += count;

    count = xmlTextWriterWriteString(writer, BAD_CAST " ");
    if (count == -1)
        return -1;
    sum += count;
    count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
    if (count < 0)
        return -1;
    sum += count;
    count = xmlTextWriterWriteString(writer, content);
    if (count == -1)
        return -1;
    sum += count;
    count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
    if (count < 0)
        return -1;
    sum += count;

    count = xmlTextWriterEndDTDEntity(writer);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

int
xmlTextWriterWriteDTDExternalEntity(xmlTextWriterPtr writer,
                                    int pe,
                                    const xmlChar * name,
                                    const xmlChar * pubid,
                                    const xmlChar * sysid,
                                    const xmlChar * ndataid)
{
    int count;
    int sum;

    if ((name == NULL) || (*name == '\0')
        || ((pubid == NULL) && (sysid == NULL)))
        return -1;
    if ((pe != 0) && (ndataid != NULL))
        return -1;

    sum = 0;
    count = xmlTextWriterStartDTDEntity(writer, pe, name);
    if (count == -1)
        return -1;
    sum += count;

    if (pubid != 0) {
        if (sysid == 0) {
            xmlGenericError(xmlGenericErrorContext,
                            "xmlTextWriterWriteDTDEntity : system identifier needed!\n");
            return -1;
        }

        count = xmlOutputBufferWriteString(writer->out, " PUBLIC ");
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWriteString(writer->out, (const char *) pubid);
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
    }

    if (sysid != 0) {
        if (pubid == 0) {
            count = xmlOutputBufferWriteString(writer->out, " SYSTEM");
            if (count < 0)
                return -1;
            sum += count;
        }

        count = xmlOutputBufferWriteString(writer->out, " ");
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWriteString(writer->out, (const char *) sysid);
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
    }

    if (ndataid != NULL) {
        count = xmlOutputBufferWriteString(writer->out, " NDATA ");
        if (count < 0)
            return -1;
        sum += count;

        count = xmlOutputBufferWriteString(writer->out, (const char *) ndataid);
        if (count < 0)
            return -1;
        sum += count;
    }

    count = xmlTextWriterEndDTDEntity(writer);
    if (count == -1)
        return -1;
    sum += count;

    return sum;
}

int
xmlTextWriterWriteDTDNotation(xmlTextWriterPtr writer,
                              const xmlChar * name,
                              const xmlChar * pubid, const xmlChar * sysid)
{
    int count;
    int sum;
    xmlLinkPtr lk;
    xmlTextWriterStackEntry *p;

    if (writer == NULL || name == NULL || *name == '\0')
        return -1;

    sum = 0;
    lk = xmlListFront(writer->nodes);
    if (lk == 0) {
        return -1;
    }

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return -1;

    switch (p->state) {
        case XML_TEXTWRITER_DTD:
            count = xmlOutputBufferWriteString(writer->out, " [");
            if (count < 0)
                return -1;
            sum += count;
            p->state = XML_TEXTWRITER_DTD_TEXT;
            /* fallthrough */
        case XML_TEXTWRITER_DTD_TEXT:
            break;
        case XML_TEXTWRITER_DTD_ELEM:
        case XML_TEXTWRITER_DTD_ATTL:
        case XML_TEXTWRITER_DTD_ENTY:
            count = xmlTextWriterEndDTD(writer);
            if (count < 0)
                return -1;
            sum += count;
            break;
        default:
            return -1;
    }

    count = xmlOutputBufferWriteString(writer->out, "<!NOTATION ");
    if (count < 0)
        return -1;
    sum += count;
    count = xmlOutputBufferWriteString(writer->out, (const char *) name);
    if (count < 0)
        return -1;
    sum += count;

    if (pubid != 0) {
        count = xmlOutputBufferWriteString(writer->out, " PUBLIC ");
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWriteString(writer->out, (const char *) pubid);
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
    }

    if (sysid != 0) {
        if (pubid == 0) {
            count = xmlOutputBufferWriteString(writer->out, " SYSTEM");
            if (count < 0)
                return -1;
            sum += count;
        }
        count = xmlOutputBufferWriteString(writer->out, " ");
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWriteString(writer->out, (const char *) sysid);
        if (count < 0)
            return -1;
        sum += count;
        count = xmlOutputBufferWrite(writer->out, 1, &writer->qchar);
        if (count < 0)
            return -1;
        sum += count;
    }

    count = xmlOutputBufferWriteString(writer->out, ">");
    if (count < 0)
        return -1;
    sum += count;

    return sum;
}

/**
 * xmlTextWriterFlush:
 * @writer:  the xmlTextWriterPtr
 *
 * Flush the output buffer.
 *
 * Returns the bytes written (may be 0 because of buffering) or -1 in case of error
 */
int
xmlTextWriterFlush(xmlTextWriterPtr writer)
{
    int count;

    if (writer == NULL)
        return -1;

    if (writer->out == NULL)
        count = 0;
    else
        count = xmlOutputBufferFlush(writer->out);

    return count;
}

/**
 * misc
 */

/**
 * xmlFreeTextWriterStackEntry:
 * @lk:  the xmlLinkPtr
 *
 * Free callback for the xmlList.
 */
static void
xmlFreeTextWriterStackEntry(xmlLinkPtr lk)
{
    xmlTextWriterStackEntry *p;

    p = (xmlTextWriterStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return;

    if (p->name != 0)
        xmlFree(p->name);
    xmlFree(p);
}

/**
 * xmlCmpTextWriterStackEntry:
 * @data0:  the first data
 * @data1:  the second data
 *
 * Compare callback for the xmlList.
 *
 * Returns -1, 0, 1
 */
static int
xmlCmpTextWriterStackEntry(const void *data0, const void *data1)
{
    xmlTextWriterStackEntry *p0;
    xmlTextWriterStackEntry *p1;

    if (data0 == data1)
        return 0;

    if (data0 == 0)
        return -1;

    if (data1 == 0)
        return 1;

    p0 = (xmlTextWriterStackEntry *) data0;
    p1 = (xmlTextWriterStackEntry *) data1;

    return xmlStrcmp(p0->name, p1->name);
}

/**
 * misc
 */

/**
 * xmlFreeTextWriterNsStackEntry:
 * @lk:  the xmlLinkPtr
 *
 * Free callback for the xmlList.
 */
static void
xmlFreeTextWriterNsStackEntry(xmlLinkPtr lk)
{
    xmlTextWriterNsStackEntry *p;

    p = (xmlTextWriterNsStackEntry *) xmlLinkGetData(lk);
    if (p == 0)
        return;

    if (p->prefix != 0)
        xmlFree(p->prefix);
    if (p->uri != 0)
        xmlFree(p->uri);

    xmlFree(p);
}

/**
 * xmlCmpTextWriterNsStackEntry:
 * @data0:  the first data
 * @data1:  the second data
 *
 * Compare callback for the xmlList.
 *
 * Returns -1, 0, 1
 */
static int
xmlCmpTextWriterNsStackEntry(const void *data0, const void *data1)
{
    xmlTextWriterNsStackEntry *p0;
    xmlTextWriterNsStackEntry *p1;
    int rc;

    if (data0 == data1)
        return 0;

    if (data0 == 0)
        return -1;

    if (data1 == 0)
        return 1;

    p0 = (xmlTextWriterNsStackEntry *) data0;
    p1 = (xmlTextWriterNsStackEntry *) data1;

    rc = xmlStrcmp(p0->prefix, p1->prefix);

    if (rc == 0)
        rc = p0->elem == p1->elem;

    return rc;
}

/**
 * xmlTextWriterWriteMemCallback:
 * @context:  the xmlBufferPtr
 * @str:  the data to write
 * @len:  the length of the data
 *
 * Write callback for the xmlOutputBuffer with target xmlBuffer
 *
 * Returns -1, 0, 1
 */
static int
xmlTextWriterWriteMemCallback(void *context, const xmlChar * str, int len)
{
    xmlBufferPtr buf = (xmlBufferPtr) context;

    xmlBufferAdd(buf, str, len);

    return len;
}

/**
 * xmlTextWriterCloseMemCallback:
 * @context:  the xmlBufferPtr
 *
 * Close callback for the xmlOutputBuffer with target xmlBuffer
 *
 * Returns -1, 0, 1
 */
static int
xmlTextWriterCloseMemCallback(void *context ATTRIBUTE_UNUSED)
{
    return 0;
}

/**
 * xmlTextWriterVSprintf:
 * @format:  see printf
 * @argptr:  pointer to the first member of the variable argument list.
 *
 * Utility function for formatted output
 *
 * Returns a new xmlChar buffer with the data or NULL on error. This buffer must be freed.
 */
static xmlChar *
xmlTextWriterVSprintf(const char *format, va_list argptr)
{
    int size;
    int count;
    xmlChar *buf;

    size = BUFSIZ;
    buf = (xmlChar *) xmlMalloc(size);
    if (buf == NULL) {
        xmlGenericError(xmlGenericErrorContext,
                        "xmlTextWriterVSprintf : out of memory!\n");
        return NULL;
    }

    while (((count = vsnprintf((char *) buf, size, format, argptr)) < 0)
           || (count == size - 1) || (count == size) || (count > size)) {
        xmlFree(buf);
        size += BUFSIZ;
        buf = (xmlChar *) xmlMalloc(size);
        if (buf == NULL) {
            xmlGenericError(xmlGenericErrorContext,
                            "xmlTextWriterVSprintf : out of memory!\n");
            return NULL;
        }
    }

    return buf;
}

#endif
