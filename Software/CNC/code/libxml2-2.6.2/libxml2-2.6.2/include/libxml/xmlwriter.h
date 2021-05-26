
/*
 * xmlwriter.h : Interfaces,
					 constants and types of the
 * text writing API.for XML
 *
 * For license and disclaimer see the license and disclaimer of
 * libxml2.
 *
 * alfred@mickautsch.de
 */

#ifndef __XML_XMLWRITER_H__
#define __XML_XMLWRITER_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <libxml/xmlIO.h>
#include <libxml/list.h>

typedef struct _xmlTextWriter xmlTextWriter;
typedef xmlTextWriter *xmlTextWriterPtr;

/*
 * Constructors & Destructor
 */
XMLPUBFUN xmlTextWriterPtr XMLCALL
	xmlNewTextWriter		(xmlOutputBufferPtr out);
XMLPUBFUN xmlTextWriterPtr XMLCALL
	xmlNewTextWriterFilename	(const char *uri,
					 int compression);
XMLPUBFUN xmlTextWriterPtr XMLCALL
	xmlNewTextWriterMemory		(xmlBufferPtr buf,
					 int compression);
XMLPUBFUN void XMLCALL
	xmlFreeTextWriter		(xmlTextWriterPtr writer);

/*
 * Functions
 */


/*
 * Document
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterStartDocument	(xmlTextWriterPtr writer,
					 const char *version,
					 const char *encoding,
					 const char *standalone);
XMLPUBFUN int XMLCALL
	xmlTextWriterEndDocument	(xmlTextWriterPtr writer);

/*
 * Comments
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatComment	(xmlTextWriterPtr writer,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatComment(xmlTextWriterPtr writer,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteComment	(xmlTextWriterPtr writer,
					 const xmlChar * content);

/*
 * Elements
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterStartElement	(xmlTextWriterPtr writer,
					 const xmlChar * name);
XMLPUBFUN int XMLCALL
	xmlTextWriterStartElementNS	(xmlTextWriterPtr writer,
					 const xmlChar * prefix,
					 const xmlChar * name,
					 const xmlChar * namespaceURI);
XMLPUBFUN int XMLCALL
	xmlTextWriterEndElement		(xmlTextWriterPtr writer);
XMLPUBFUN int XMLCALL
	xmlTextWriterFullEndElement	(xmlTextWriterPtr writer);

/*
 * Elements conveniency functions
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatElement	(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatElement(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteElement	(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const xmlChar * content);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatElementNS(xmlTextWriterPtr writer,
					 const xmlChar * prefix,
					 const xmlChar * name,
					 const xmlChar * namespaceURI,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatElementNS(xmlTextWriterPtr writer,
					 const xmlChar * prefix,
					 const xmlChar * name,
					 const xmlChar * namespaceURI,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteElementNS	(xmlTextWriterPtr writer,
					 const xmlChar * prefix,
					 const xmlChar * name,
					 const xmlChar * namespaceURI,
					 const xmlChar * content);

/*
 * Text
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatRaw	(xmlTextWriterPtr writer,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatRaw	(xmlTextWriterPtr writer,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteRawLen	(xmlTextWriterPtr writer,
					 const xmlChar * content,
					 int len);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteRaw		(xmlTextWriterPtr writer,
					 const xmlChar * content);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatString	(xmlTextWriterPtr writer,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatString	(xmlTextWriterPtr writer,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteString	(xmlTextWriterPtr writer,
					 const xmlChar * content);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteBase64	(xmlTextWriterPtr writer,
					 const char *data,
					 int start,
					 int len);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteBinHex	(xmlTextWriterPtr writer,
					 const char *data,
					 int start,
					 int len);

/*
 * Attributes
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterStartAttribute	(xmlTextWriterPtr writer,
					 const xmlChar * name);
XMLPUBFUN int XMLCALL
	xmlTextWriterStartAttributeNS	(xmlTextWriterPtr writer,
					 const xmlChar * prefix,
					 const xmlChar * name,
					 const xmlChar * namespaceURI);
XMLPUBFUN int XMLCALL
	xmlTextWriterEndAttribute	(xmlTextWriterPtr writer);

/*
 * Attributes conveniency functions
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatAttribute(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatAttribute(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteAttribute	(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const xmlChar * content);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatAttributeNS(xmlTextWriterPtr writer,
					 const xmlChar * prefix,
					 const xmlChar * name,
					 const xmlChar * namespaceURI,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatAttributeNS(xmlTextWriterPtr writer,
					 const xmlChar * prefix,
					 const xmlChar * name,
					 const xmlChar * namespaceURI,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteAttributeNS	(xmlTextWriterPtr writer,
					 const xmlChar * prefix,
					 const xmlChar * name,
					 const xmlChar * namespaceURI,
					 const xmlChar * content);

/*
 * PI's
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterStartPI		(xmlTextWriterPtr writer,
					 const xmlChar * target);
XMLPUBFUN int XMLCALL
	xmlTextWriterEndPI		(xmlTextWriterPtr writer);

/*
 * PI conveniency functions
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatPI	(xmlTextWriterPtr writer,
					 const xmlChar * target,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatPI	(xmlTextWriterPtr writer,
					 const xmlChar * target,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWritePI		(xmlTextWriterPtr writer,
					 const xmlChar * target,
					 const xmlChar * content);
#define xmlTextWriterWriteProcessingInstruction xmlTextWriterWritePI

/*
 * CDATA
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterStartCDATA		(xmlTextWriterPtr writer);
XMLPUBFUN int XMLCALL
	xmlTextWriterEndCDATA		(xmlTextWriterPtr writer);

/*
 * CDATA conveniency functions
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatCDATA	(xmlTextWriterPtr writer,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatCDATA	(xmlTextWriterPtr writer,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteCDATA		(xmlTextWriterPtr writer,
					 const xmlChar * content);

/*
 * DTD
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterStartDTD		(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const xmlChar * pubid,
					 const xmlChar * sysid);
XMLPUBFUN int XMLCALL
	xmlTextWriterEndDTD		(xmlTextWriterPtr writer);

/*
 * DTD conveniency functions
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatDTD	(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const xmlChar * pubid,
					 const xmlChar * sysid,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatDTD	(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const xmlChar * pubid,
					 const xmlChar * sysid,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteDTD		(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const xmlChar * pubid,
					 const xmlChar * sysid,
					 const xmlChar * subset);
#define xmlTextWriterWriteDocType xmlTextWriterWriteDTD

/*
 * DTD element definition
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterStartDTDElement	(xmlTextWriterPtr writer,
					 const xmlChar * name);
#define xmlTextWriterEndDTDElement xmlTextWriterEndDTD

/*
 * DTD element definition conveniency functions
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatDTDElement(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatDTDElement(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteDTDElement	(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const xmlChar * content);

/*
 * DTD attribute list definition
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterStartDTDAttlist	(xmlTextWriterPtr writer,
					 const xmlChar * name);
#define xmlTextWriterEndDTDAttlist xmlTextWriterEndDTD

/*
 * DTD attribute list definition conveniency functions
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatDTDAttlist(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatDTDAttlist(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteDTDAttlist	(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const xmlChar * content);

/*
 * DTD entity definition
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterStartDTDEntity	(xmlTextWriterPtr writer,
					 int pe,
					 const xmlChar * name);
#define xmlTextWriterEndDTDEntity xmlTextWriterEndDTD

/*
 * DTD entity definition conveniency functions
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteFormatDTDInternalEntity(xmlTextWriterPtr writer,
					 int pe,
					 const xmlChar * name,
					 const char *format, ...);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteVFormatDTDInternalEntity(xmlTextWriterPtr writer,
					 int pe,
					 const xmlChar * name,
					 const char *format,
					 va_list argptr);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteDTDInternalEntity(xmlTextWriterPtr writer,
					 int pe,
					 const xmlChar * name,
					 const xmlChar * content);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteDTDExternalEntity(xmlTextWriterPtr writer,
					 int pe,
					 const xmlChar * name,
					 const xmlChar * pubid,
					 const xmlChar * sysid,
					 const xmlChar * ndataid);
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteDTDEntity	(xmlTextWriterPtr writer,
					 int pe,
					 const xmlChar * name,
					 const xmlChar * pubid,
					 const xmlChar * sysid,
					 const xmlChar * ndataid,
					 const xmlChar * content);

/*
 * DTD notation definition
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterWriteDTDNotation	(xmlTextWriterPtr writer,
					 const xmlChar * name,
					 const xmlChar * pubid,
					 const xmlChar * sysid);

/*
 * misc
 */
XMLPUBFUN int XMLCALL
	xmlTextWriterFlush		(xmlTextWriterPtr writer);

#ifdef __cplusplus
}
#endif
#endif                          /* __XML_XMLWRITER_H__ */
