/*
 * SAX.h : Default SAX2 handler interfaces to build a tree.
 *
 * See Copyright for the status of this software.
 *
 * Daniel Veillard <daniel@veillard.com>
 */


#ifndef __XML_SAX2_H__
#define __XML_SAX2_H__

#include <stdio.h>
#include <stdlib.h>
#include <libxml/xmlversion.h>
#include <libxml/parser.h>
#include <libxml/xlink.h>

#ifdef __cplusplus
extern "C" {
#endif
XMLPUBFUN const xmlChar * XMLCALL
		xmlSAX2GetPublicId		(void *ctx);
XMLPUBFUN const xmlChar * XMLCALL	
		xmlSAX2GetSystemId		(void *ctx);
XMLPUBFUN void XMLCALL		
		xmlSAX2SetDocumentLocator	(void *ctx,
						 xmlSAXLocatorPtr loc);
    
XMLPUBFUN int XMLCALL		
		xmlSAX2GetLineNumber		(void *ctx);
XMLPUBFUN int XMLCALL		
		xmlSAX2GetColumnNumber		(void *ctx);

XMLPUBFUN int XMLCALL		
		xmlSAX2IsStandalone		(void *ctx);
XMLPUBFUN int XMLCALL		
		xmlSAX2HasInternalSubset	(void *ctx);
XMLPUBFUN int XMLCALL		
		xmlSAX2HasExternalSubset	(void *ctx);

XMLPUBFUN void XMLCALL		
		xmlSAX2InternalSubset		(void *ctx,
						 const xmlChar *name,
						 const xmlChar *ExternalID,
						 const xmlChar *SystemID);
XMLPUBFUN void XMLCALL		
		xmlSAX2ExternalSubset		(void *ctx,
						 const xmlChar *name,
						 const xmlChar *ExternalID,
						 const xmlChar *SystemID);
XMLPUBFUN xmlEntityPtr XMLCALL	
		xmlSAX2GetEntity		(void *ctx,
						 const xmlChar *name);
XMLPUBFUN xmlEntityPtr XMLCALL	
		xmlSAX2GetParameterEntity	(void *ctx,
						 const xmlChar *name);
XMLPUBFUN xmlParserInputPtr XMLCALL 
		xmlSAX2ResolveEntity		(void *ctx,
						 const xmlChar *publicId,
						 const xmlChar *systemId);

XMLPUBFUN void XMLCALL		
		xmlSAX2EntityDecl		(void *ctx,
						 const xmlChar *name,
						 int type,
						 const xmlChar *publicId,
						 const xmlChar *systemId,
						 xmlChar *content);
XMLPUBFUN void XMLCALL		
		xmlSAX2AttributeDecl		(void *ctx,
						 const xmlChar *elem,
						 const xmlChar *fullname,
						 int type,
						 int def,
						 const xmlChar *defaultValue,
						 xmlEnumerationPtr tree);
XMLPUBFUN void XMLCALL		
		xmlSAX2ElementDecl		(void *ctx,
						 const xmlChar *name,
						 int type,
						 xmlElementContentPtr content);
XMLPUBFUN void XMLCALL		
		xmlSAX2NotationDecl		(void *ctx,
						 const xmlChar *name,
						 const xmlChar *publicId,
						 const xmlChar *systemId);
XMLPUBFUN void XMLCALL		
		xmlSAX2UnparsedEntityDecl	(void *ctx,
						 const xmlChar *name,
						 const xmlChar *publicId,
						 const xmlChar *systemId,
						 const xmlChar *notationName);

XMLPUBFUN void XMLCALL		
		xmlSAX2StartDocument		(void *ctx);
XMLPUBFUN void XMLCALL		
		xmlSAX2EndDocument		(void *ctx);
XMLPUBFUN void XMLCALL		
		xmlSAX2StartElement		(void *ctx,
						 const xmlChar *fullname,
						 const xmlChar **atts);
XMLPUBFUN void XMLCALL		
		xmlSAX2EndElement		(void *ctx,
						 const xmlChar *name);
XMLPUBFUN void XMLCALL
		xmlSAX2StartElementNs		(void *ctx,
						 const xmlChar *localname,
						 const xmlChar *prefix,
						 const xmlChar *URI,
						 int nb_namespaces,
						 const xmlChar **namespaces,
						 int nb_attributes,
						 int nb_defaulted,
						 const xmlChar **attributes);
XMLPUBFUN void XMLCALL
		xmlSAX2EndElementNs		(void *ctx,
						 const xmlChar *localname,
						 const xmlChar *prefix,
						 const xmlChar *URI);
XMLPUBFUN void XMLCALL		
		xmlSAX2Reference		(void *ctx,
						 const xmlChar *name);
XMLPUBFUN void XMLCALL		
		xmlSAX2Characters		(void *ctx,
						 const xmlChar *ch,
						 int len);
XMLPUBFUN void XMLCALL		
		xmlSAX2IgnorableWhitespace	(void *ctx,
						 const xmlChar *ch,
						 int len);
XMLPUBFUN void XMLCALL		
		xmlSAX2ProcessingInstruction	(void *ctx,
						 const xmlChar *target,
						 const xmlChar *data);
XMLPUBFUN void XMLCALL		
		xmlSAX2GlobalNamespace		(void *ctx,
						 const xmlChar *href,
						 const xmlChar *prefix);
XMLPUBFUN void XMLCALL		
		xmlSAX2SetNamespace		(void *ctx,
						 const xmlChar *name);
XMLPUBFUN xmlNsPtr XMLCALL	
		xmlSAX2GetNamespace		(void *ctx);
XMLPUBFUN int XMLCALL		
		xmlSAX2CheckNamespace		(void *ctx,
						 xmlChar *nameSpace);
XMLPUBFUN void XMLCALL		
		xmlSAX2NamespaceDecl		(void *ctx,
						 const xmlChar *href,
						 const xmlChar *prefix);
XMLPUBFUN void XMLCALL		
		xmlSAX2Comment			(void *ctx,
						 const xmlChar *value);
XMLPUBFUN void XMLCALL		
		xmlSAX2CDataBlock		(void *ctx,
						 const xmlChar *value,
						 int len);

XMLPUBFUN int XMLCALL
		xmlSAXDefaultVersion		(int version);

XMLPUBFUN int XMLCALL
		xmlSAXVersion			(xmlSAXHandler *hdlr,
						 int version);
XMLPUBFUN void XMLCALL		
		xmlSAX2InitDefaultSAXHandler    (xmlSAXHandler *hdlr,
						 int warning);
#ifdef LIBXML_HTML_ENABLED
XMLPUBFUN void XMLCALL		
		xmlSAX2InitHtmlDefaultSAXHandler(xmlSAXHandler *hdlr);
#endif
#ifdef LIBXML_DOCB_ENABLED
XMLPUBFUN void XMLCALL		
		xmlSAX2InitDocbDefaultSAXHandler(xmlSAXHandler *hdlr);
#endif
XMLPUBFUN void XMLCALL		
		xmlDefaultSAXHandlerInit	(void);
XMLPUBFUN void XMLCALL		
		htmlDefaultSAXHandlerInit	(void);
XMLPUBFUN void XMLCALL		
		docbDefaultSAXHandlerInit	(void);
#ifdef __cplusplus
}
#endif
#endif /* __XML_SAX2_H__ */
