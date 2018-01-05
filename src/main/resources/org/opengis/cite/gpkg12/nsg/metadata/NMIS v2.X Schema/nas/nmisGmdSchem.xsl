<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gss="http://www.isotc211.org/2005/gss" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ism="urn:us:gov:ic:ism" xmlns:nas="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" version="1.0">
	<!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
	<xsl:param name="archiveDirParameter"/>
	<xsl:param name="archiveNameParameter"/>
	<xsl:param name="fileNameParameter"/>
	<xsl:param name="fileDirParameter"/>
	<xsl:variable name="document-uri">
		<xsl:value-of select="document-uri(/)"/>
	</xsl:variable>
	<!--PHASES-->
	<!--PROLOG-->
	<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml" omit-xml-declaration="no" standalone="yes" indent="yes"/>
	<!--XSD TYPES FOR XSLT2-->
	<!--KEYS AND FUNCTIONS-->
	<!--DEFAULT RULES-->
	<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
	<!--This mode can be used to generate an ugly though full XPath for locators-->
	<xsl:template match="*" mode="schematron-select-full-path">
		<xsl:apply-templates select="." mode="schematron-get-full-path"/>
	</xsl:template>
	<!--MODE: SCHEMATRON-FULL-PATH-->
	<!--This mode can be used to generate an ugly though full XPath for locators-->
	<xsl:template match="*" mode="schematron-get-full-path">
		<xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
		<xsl:text>/</xsl:text>
		<xsl:choose>
			<xsl:when test="namespace-uri()=''">
				<xsl:value-of select="name()"/>
				<xsl:variable name="p_1" select="1+    count(preceding-sibling::*[name()=name(current())])"/>
				<xsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<xsl:value-of select="$p_1"/>]</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>*[local-name()='</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>']</xsl:text>
				<xsl:variable name="p_2" select="1+   count(preceding-sibling::*[local-name()=local-name(current())])"/>
				<xsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<xsl:value-of select="$p_2"/>]</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="@*" mode="schematron-get-full-path">
		<xsl:text>/</xsl:text>
		<xsl:choose>
			<xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>@*[local-name()='</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>' and namespace-uri()='</xsl:text>
				<xsl:value-of select="namespace-uri()"/>
				<xsl:text>']</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--MODE: SCHEMATRON-FULL-PATH-2-->
	<!--This mode can be used to generate prefixed XPath for humans-->
	<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
		<xsl:for-each select="ancestor-or-self::*">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="name(.)"/>
			<xsl:if test="preceding-sibling::*[name(.)=name(current())]">
				<xsl:text>[</xsl:text>
				<xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="not(self::*)">
			<xsl:text/>/@<xsl:value-of select="name(.)"/>
		</xsl:if>
	</xsl:template>
	<!--MODE: SCHEMATRON-FULL-PATH-3-->
	<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
	<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
		<xsl:for-each select="ancestor-or-self::*">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="name(.)"/>
			<xsl:if test="parent::*">
				<xsl:text>[</xsl:text>
				<xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="not(self::*)">
			<xsl:text/>/@<xsl:value-of select="name(.)"/>
		</xsl:if>
	</xsl:template>
	<!--MODE: GENERATE-ID-FROM-PATH -->
	<xsl:template match="/" mode="generate-id-from-path"/>
	<xsl:template match="text()" mode="generate-id-from-path">
		<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
		<xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
	</xsl:template>
	<xsl:template match="comment()" mode="generate-id-from-path">
		<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
		<xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
	</xsl:template>
	<xsl:template match="processing-instruction()" mode="generate-id-from-path">
		<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
		<xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
	</xsl:template>
	<xsl:template match="@*" mode="generate-id-from-path">
		<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
		<xsl:value-of select="concat('.@', name())"/>
	</xsl:template>
	<xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
		<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
	</xsl:template>
	<!--MODE: GENERATE-ID-2 -->
	<xsl:template match="/" mode="generate-id-2">U</xsl:template>
	<xsl:template match="*" mode="generate-id-2" priority="2">
		<xsl:text>U</xsl:text>
		<xsl:number level="multiple" count="*"/>
	</xsl:template>
	<xsl:template match="node()" mode="generate-id-2">
		<xsl:text>U.</xsl:text>
		<xsl:number level="multiple" count="*"/>
		<xsl:text>n</xsl:text>
		<xsl:number count="node()"/>
	</xsl:template>
	<xsl:template match="@*" mode="generate-id-2">
		<xsl:text>U.</xsl:text>
		<xsl:number level="multiple" count="*"/>
		<xsl:text>_</xsl:text>
		<xsl:value-of select="string-length(local-name(.))"/>
		<xsl:text>_</xsl:text>
		<xsl:value-of select="translate(name(),':','.')"/>
	</xsl:template>
	<!--Strip characters-->
	<xsl:template match="text()" priority="-1"/>
	<!--SCHEMA SETUP-->
	<xsl:template match="/">
		<svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="NMIS ISO/TS 19139 Schematron validation" schemaVersion="">
			<xsl:comment>
				<xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
			</xsl:comment>
			<svrl:ns-prefix-in-attribute-values uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gss" prefix="gss"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml/3.2" prefix="gml"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
			<svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
			<svrl:ns-prefix-in-attribute-values uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" prefix="nas"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Locale_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Locale_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M9"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Resolution_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Resolution_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M10"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">AggregateInformation_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">AggregateInformation_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M11"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Keywords_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Keywords_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M12"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">SecurityConstraints_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">SecurityConstraints_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M13"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">LegalConstraints_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">LegalConstraints_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M14"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Scope_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Scope_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M15"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DataQuality_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">DataQuality_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M16"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Lineage_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Lineage_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M17"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Source_description_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Source_description_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M18"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">LI_Source_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">LI_Source_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M19"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DQ_Element_evaluationMethodDescription_must_have_String_Content</xsl:attribute>
				<xsl:attribute name="name">DQ_Element_evaluationMethodDescription_must_have_String_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M20"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MD_Georectified_must_have_Consistent_check_point_values</xsl:attribute>
				<xsl:attribute name="name">MD_Georectified_must_have_Consistent_check_point_values</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M21"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ReferenceSystem_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">ReferenceSystem_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M22"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MdIdentifier_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">MdIdentifier_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M23"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">RsIdentifier_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">RsIdentifier_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M24"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Distribution_must_have_content</xsl:attribute>
				<xsl:attribute name="name">Distribution_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M25"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Format_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Format_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M26"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Distributor_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Distributor_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M27"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Distribution_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">Distribution_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M28"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">NAS_DigitalTransferOptions_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">NAS_DigitalTransferOptions_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M29"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ApplicationSchemaInformation_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">ApplicationSchemaInformation_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M30"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">GeographicBoundingBox_must_have_ValidContent</xsl:attribute>
				<xsl:attribute name="name">GeographicBoundingBox_must_have_ValidContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M31"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">BoundingPolygon_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">BoundingPolygon_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M32"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Polygon_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">Polygon_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M33"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">GeographicDescription_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">GeographicDescription_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M34"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TemporalElement_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">TemporalElement_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M35"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">VerticalElement_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">VerticalElement_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M36"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">VerticalExtent_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">VerticalExtent_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M37"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Citation_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Citation_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M38"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Citation_alternateTitle_must_have_String_Content</xsl:attribute>
				<xsl:attribute name="name">Citation_alternateTitle_must_have_String_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M39"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ResponsibleParty_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">ResponsibleParty_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M40"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Date_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Date_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M41"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Series_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Series_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M42"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Contact_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Contact_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M43"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">OnlineResource_must_have_Valid_Content</xsl:attribute>
				<xsl:attribute name="name">OnlineResource_must_have_Valid_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M44"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Address_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Address_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M45"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Band_units_must_be_present_if_min_and_max_values_present</xsl:attribute>
				<xsl:attribute name="name">Band_units_must_be_present_if_min_and_max_values_present</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M46"/>
		</svrl:schematron-output>
	</xsl:template>
	<!--SCHEMATRON PATTERNS-->
	<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">NMIS ISO/TS 19139 Schematron validation</svrl:text>
	<!--PATTERN Locale_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:PT_Locale" priority="1000" mode="M9">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:PT_Locale"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:languageCode/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:languageCode/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The language code must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:country/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:country/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The country must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:characterEncoding/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:characterEncoding/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The character encoding must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M9"/>
	<xsl:template match="@*|node()" priority="-2" mode="M9">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
	</xsl:template>
	<!--PATTERN Resolution_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Resolution" priority="1000" mode="M10">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Resolution"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:distance) or ((gmd:distance/gco:Distance) and (gmd:distance/gco:Distance &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:distance) or ((gmd:distance/gco:Distance) and (gmd:distance/gco:Distance &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
          The resolution distance, if present, must be a positive and non-zero numeric value.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:equivalentScale) or ((gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/*) and (gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:equivalentScale) or ((gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/*) and (gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
          The resolution quivalent scale, if present, has a denominator of a representative fraction that is a positive and non-zero integer value.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M10"/>
	<xsl:template match="@*|node()" priority="-2" mode="M10">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
	</xsl:template>
	<!--PATTERN AggregateInformation_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_AggregateInformation" priority="1000" mode="M11">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_AggregateInformation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:aggregateDataSetName/* or gmd:aggregateDataSetIdentifier/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:aggregateDataSetName/* or gmd:aggregateDataSetIdentifier/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        An aggregate information must be identified by either an aggregate data set name or identifier, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:associationType/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:associationType/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        An aggregate information must have an association type, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M11"/>
	<xsl:template match="@*|node()" priority="-2" mode="M11">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
	</xsl:template>
	<!--PATTERN Keywords_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Keywords" priority="1000" mode="M12">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Keywords"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:keyword/gco:CharacterString and (string-length(normalize-space(gmd:keyword/gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:keyword/gco:CharacterString and (string-length(normalize-space(gmd:keyword/gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The keyword must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:type) or (gmd:type/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:type) or (gmd:type/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The keyword type, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:thesaurusName/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:thesaurusName/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The keyword thesaurusName name must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M12"/>
	<xsl:template match="@*|node()" priority="-2" mode="M12">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
	</xsl:template>
	<!--PATTERN SecurityConstraints_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_SecurityConstraints" priority="1000" mode="M13">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_SecurityConstraints"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:classification/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:classification/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The security constraints security classification must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:classificationSystem) or (gmd:classificationSystem/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:classificationSystem) or (gmd:classificationSystem/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The security constraints classification system, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M13"/>
	<xsl:template match="@*|node()" priority="-2" mode="M13">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
	</xsl:template>
	<!--PATTERN LegalConstraints_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_LegalConstraints" priority="1000" mode="M14">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_LegalConstraints"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:accessConstraints) or (gmd:accessConstraints/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:accessConstraints) or (gmd:accessConstraints/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The legal constraints access constraints, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:useConstraints) or (gmd:useConstraints/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:useConstraints) or (gmd:useConstraints/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The legal constraints use constraints, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M14"/>
	<xsl:template match="@*|node()" priority="-2" mode="M14">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
	</xsl:template>
	<!--PATTERN Scope_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:DQ_Scope" priority="1000" mode="M15">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:DQ_Scope"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:level/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:level/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The scope level must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:levelDescription) or (gmd:levelDescription/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:levelDescription) or (gmd:levelDescription/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The scope level description, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M15"/>
	<xsl:template match="@*|node()" priority="-2" mode="M15">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
	</xsl:template>
	<!--PATTERN DataQuality_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:DQ_DataQuality" priority="1000" mode="M16">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:DQ_DataQuality"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:scope/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:scope/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data quality scope must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:lineage) or (gmd:lineage/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:lineage) or (gmd:lineage/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data quality lineage association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:report) or (gmd:report/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:report) or (gmd:report/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
		The data quality report association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M16"/>
	<xsl:template match="@*|node()" priority="-2" mode="M16">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
	</xsl:template>
	<!--PATTERN Lineage_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:LI_Lineage" priority="1000" mode="M17">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:LI_Lineage"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:statement) or ((gmd:statement/gco:CharacterString) and ((string-length(normalize-space(gmd:statement/gco:CharacterString)) &gt; 0)))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:statement) or ((gmd:statement/gco:CharacterString) and ((string-length(normalize-space(gmd:statement/gco:CharacterString)) &gt; 0)))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The lineage statement, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M17"/>
	<xsl:template match="@*|node()" priority="-2" mode="M17">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
	</xsl:template>
	<!--PATTERN Source_description_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:LI_Lineage/gmd:source" priority="1000" mode="M18">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:LI_Lineage/gmd:source"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(*/gmd:description)  or ((*/gmd:description/gco:CharacterString) and ((string-length(normalize-space(*/gmd:description/gco:CharacterString)) &gt; 0)))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(*/gmd:description) or ((*/gmd:description/gco:CharacterString) and ((string-length(normalize-space(*/gmd:description/gco:CharacterString)) &gt; 0)))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
				The source description, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M18"/>
	<xsl:template match="@*|node()" priority="-2" mode="M18">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
	</xsl:template>
	<!--PATTERN LI_Source_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmd:LI_Lineage/gmd:source" priority="1000" mode="M19">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:LI_Lineage/gmd:source"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*/gmd:description/* or */gmd:sourceExtent/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*/gmd:description/* or */gmd:sourceExtent/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
				Either a description or sourceExtent must be specified for LI_Source/LE_Source.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M19"/>
	<xsl:template match="@*|node()" priority="-2" mode="M19">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<!--PATTERN DQ_Element_evaluationMethodDescription_must_have_String_Content-->
	<!--RULE -->
	<xsl:template match="gmd:DQ_DataQuality/gmd:report/*/gmd:evaluationMethodDescription" priority="1000" mode="M20">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:DQ_DataQuality/gmd:report/*/gmd:evaluationMethodDescription"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gco:CharacterString and (string-length(normalize-space(gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gco:CharacterString and (string-length(normalize-space(gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
				gmd:DQ_Element/gmd:evaluationMethodDescription, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M20"/>
	<xsl:template match="@*|node()" priority="-2" mode="M20">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<!--PATTERN MD_Georectified_must_have_Consistent_check_point_values-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Georectified" priority="1000" mode="M21">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Georectified"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:checkPointAvailability/gco:Boolean='false' or (gmd:checkPointAvailability/gco:Boolean='true' and gmd:checkPointDescription/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:checkPointAvailability/gco:Boolean='false' or (gmd:checkPointAvailability/gco:Boolean='true' and gmd:checkPointDescription/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
		  The Boolean value check point availability is true and the check point description is either missing or has no content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M21"/>
	<xsl:template match="@*|node()" priority="-2" mode="M21">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<!--PATTERN ReferenceSystem_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ReferenceSystem" priority="1000" mode="M22">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ReferenceSystem"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:referenceSystemIdentifier/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:referenceSystemIdentifier/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The reference system identifier must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M22"/>
	<xsl:template match="@*|node()" priority="-2" mode="M22">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<!--PATTERN MdIdentifier_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Identifier" priority="1000" mode="M23">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Identifier"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:code/gco:CharacterString and (string-length(normalize-space(gmd:code/gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:code/gco:CharacterString and (string-length(normalize-space(gmd:code/gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata identifier must have a code, with non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M23"/>
	<xsl:template match="@*|node()" priority="-2" mode="M23">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<!--PATTERN RsIdentifier_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:RS_Identifier" priority="1000" mode="M24">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:RS_Identifier"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:code/gco:CharacterString and (string-length(normalize-space(gmd:code/gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:code/gco:CharacterString and (string-length(normalize-space(gmd:code/gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The reference system identifier must have a code with non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:codeSpace) or ((gmd:codeSpace/gco:CharacterString) and (string-length(normalize-space(gmd:codeSpace/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:codeSpace) or ((gmd:codeSpace/gco:CharacterString) and (string-length(normalize-space(gmd:codeSpace/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The reference system identifier code space, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M24"/>
	<xsl:template match="@*|node()" priority="-2" mode="M24">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<!--PATTERN Distribution_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Distribution" priority="1000" mode="M25">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Distribution"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Distribution must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M25"/>
	<xsl:template match="@*|node()" priority="-2" mode="M25">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<!--PATTERN Format_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Format" priority="1000" mode="M26">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Format"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:name/gco:CharacterString and (string-length(normalize-space(gmd:name/gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:name/gco:CharacterString and (string-length(normalize-space(gmd:name/gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The format name must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:version/gco:CharacterString and (string-length(normalize-space(gmd:version/gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:version/gco:CharacterString and (string-length(normalize-space(gmd:version/gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The format version must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:formatDistributor) or (gmd:formatDistributor/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:formatDistributor) or (gmd:formatDistributor/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The format distributor association/element, if it exists, must have content, e.g., a contact.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M26"/>
	<xsl:template match="@*|node()" priority="-2" mode="M26">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<!--PATTERN Distributor_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Distributor" priority="1000" mode="M27">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Distributor"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:distributorContact/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:distributorContact/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The distributor must have a contact, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:distributorTransferOptions) or (gmd:distributorTransferOptions/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:distributorTransferOptions) or (gmd:distributorTransferOptions/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The distributor transfer options association/element, if it exists, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M27"/>
	<xsl:template match="@*|node()" priority="-2" mode="M27">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<!--PATTERN Distribution_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Distribution" priority="1000" mode="M28">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Distribution"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(not(gmd:distributor/@xlink:href) and gmd:distributor/gmd:MD_distributor/gmd:distributorFormat) or                                  (gmd:distributor/@xlink:href and not(starts-with(gmd:distributor/@xlink:href, '#')) or (starts-with(gmd:distributor/@xlink:href, '#') and (//gmd:MD_Distributor[@id=(substring-after(current()/gmd:distributor/@xlink:href,'#'))]/gmd:distributorFormat))) or                                  (not(gmd:distributionFormat/@xlink:href) and gmd:distributionFormat) or                                  (gmd:distributionFormat/@xlink:href and not(starts-with(gmd:distributionFormat/@xlink:href, '#')) or (starts-with(gmd:distributionFormat/@xlink:href,'#') and (//gmd:MD_Format[@id=(substring-after(current()/gmd:distributionFormat/@xlink:href,'#'))])))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(not(gmd:distributor/@xlink:href) and gmd:distributor/gmd:MD_distributor/gmd:distributorFormat) or (gmd:distributor/@xlink:href and not(starts-with(gmd:distributor/@xlink:href, '#')) or (starts-with(gmd:distributor/@xlink:href, '#') and (//gmd:MD_Distributor[@id=(substring-after(current()/gmd:distributor/@xlink:href,'#'))]/gmd:distributorFormat))) or (not(gmd:distributionFormat/@xlink:href) and gmd:distributionFormat) or (gmd:distributionFormat/@xlink:href and not(starts-with(gmd:distributionFormat/@xlink:href, '#')) or (starts-with(gmd:distributionFormat/@xlink:href,'#') and (//gmd:MD_Format[@id=(substring-after(current()/gmd:distributionFormat/@xlink:href,'#'))])))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The distributionFormat element must be present if MD_Distribution/distributor/MD_Distributor/distributorFormat is not documented.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M28"/>
	<xsl:template match="@*|node()" priority="-2" mode="M28">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<!--PATTERN NAS_DigitalTransferOptions_must_have_Content-->
	<!--RULE -->
	<xsl:template match="nas:NMF_DigitalTransferOptions" priority="1000" mode="M29">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:NMF_DigitalTransferOptions"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:transferSize) or ((gmd:transferSize/gco:Real) and (gmd:transferSize/gco:Real &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:transferSize) or ((gmd:transferSize/gco:Real) and (gmd:transferSize/gco:Real &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The digital transfer options transfer size, if present, must have real value that is greater than zero.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:onLine) or (gmd:onLine/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:onLine) or (gmd:onLine/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The digital transfer options on-line, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M29"/>
	<xsl:template match="@*|node()" priority="-2" mode="M29">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<!--PATTERN ApplicationSchemaInformation_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ApplicationSchemaInformation" priority="1000" mode="M30">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ApplicationSchemaInformation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:name/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:name/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The application schema information name must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:schemaLanguage/gco:CharacterString and (string-length(normalize-space(gmd:schemaLanguage/gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:schemaLanguage/gco:CharacterString and (string-length(normalize-space(gmd:schemaLanguage/gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The application schema information schema language must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:constraintLanguage/gco:CharacterString and (string-length(normalize-space(gmd:constraintLanguage/gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:constraintLanguage/gco:CharacterString and (string-length(normalize-space(gmd:constraintLanguage/gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The application schema information constraint language must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M30"/>
	<xsl:template match="@*|node()" priority="-2" mode="M30">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<!--PATTERN GeographicBoundingBox_must_have_ValidContent-->
	<!--RULE -->
	<xsl:template match="gmd:EX_GeographicBoundingBox" priority="1000" mode="M31">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_GeographicBoundingBox"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(-180.0 &lt;= gmd:westBoundLongitude) and (gmd:westBoundLongitude &lt;= 180.0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-180.0 &lt;= gmd:westBoundLongitude) and (gmd:westBoundLongitude &lt;= 180.0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
          The western bounding longitude must fall between -180 and 180 arc degrees, inclusive.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(-180.0 &lt;= gmd:eastBoundLongitude) and (gmd:eastBoundLongitude &lt;= 180.0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-180.0 &lt;= gmd:eastBoundLongitude) and (gmd:eastBoundLongitude &lt;= 180.0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
          The eastern bounding longitude must fall between -180 and 180 arc degrees, inclusive.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(-90.0 &lt;= gmd:southBoundLatitude) and (gmd:southBoundLatitude &lt;= 90.0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-90.0 &lt;= gmd:southBoundLatitude) and (gmd:southBoundLatitude &lt;= 90.0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
          The southern bounding latitude must fall between -90 and 90 arc degrees, inclusive.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(-90.0 &lt;= gmd:northBoundLatitude) and (gmd:northBoundLatitude &lt;= 90.0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-90.0 &lt;= gmd:northBoundLatitude) and (gmd:northBoundLatitude &lt;= 90.0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
          The northern bounding latitude must fall between -90 and 90 arc degrees, inclusive.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:southBoundLatitude &lt;= gmd:northBoundLatitude"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:southBoundLatitude &lt;= gmd:northBoundLatitude">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
          The southern bounding latitude must be less than or equal to the northern bounding latitude.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M31"/>
	<xsl:template match="@*|node()" priority="-2" mode="M31">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
	<!--PATTERN BoundingPolygon_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:EX_BoundingPolygon" priority="1000" mode="M32">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_BoundingPolygon"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:polygon/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:polygon/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The bounding polygon must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M32"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M32"/>
	<xsl:template match="@*|node()" priority="-2" mode="M32">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M32"/>
	</xsl:template>
	<!--PATTERN Polygon_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gml:Polygon" priority="1000" mode="M33">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gml:Polygon"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@srsName and gml:exterior"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@srsName and gml:exterior">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The GML Polygon must have a specified CRS and content in the form of an exterior ring.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M33"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M33"/>
	<xsl:template match="@*|node()" priority="-2" mode="M33">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M33"/>
	</xsl:template>
	<!--PATTERN GeographicDescription_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:EX_GeographicDescription" priority="1000" mode="M34">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_GeographicDescription"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:geographicIdentifier/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:geographicIdentifier/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The geographic description geographic identifier must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M34"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M34"/>
	<xsl:template match="@*|node()" priority="-2" mode="M34">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M34"/>
	</xsl:template>
	<!--PATTERN TemporalElement_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:temporalElement" priority="1000" mode="M35">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:temporalElement"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The temporal element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M35"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M35"/>
	<xsl:template match="@*|node()" priority="-2" mode="M35">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M35"/>
	</xsl:template>
	<!--PATTERN VerticalElement_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:verticalElement" priority="1000" mode="M36">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:verticalElement"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The vertical element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M36"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M36"/>
	<xsl:template match="@*|node()" priority="-2" mode="M36">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M36"/>
	</xsl:template>
	<!--PATTERN VerticalExtent_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:EX_VerticalExtent" priority="1000" mode="M37">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_VerticalExtent"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:minimumValue/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:minimumValue/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The vertical extent minimum value must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:maximumValue/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:maximumValue/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The vertical extent maximum value must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(string-length(normalize-space(gmd:verticalCRS/@xlink:href)) &gt; 0) or (gmd:verticalCRS/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(string-length(normalize-space(gmd:verticalCRS/@xlink:href)) &gt; 0) or (gmd:verticalCRS/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The vertical extent vertical CRS association/element must be either a non-empty xlink:href or have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M37"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M37"/>
	<xsl:template match="@*|node()" priority="-2" mode="M37">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M37"/>
	</xsl:template>
	<!--PATTERN Citation_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Citation" priority="1000" mode="M38">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Citation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:title/gco:CharacterString and (string-length(normalize-space(gmd:title/gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:title/gco:CharacterString and (string-length(normalize-space(gmd:title/gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation title must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:date/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:date/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation date(s) must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:identifier) or (gmd:identifier/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:identifier) or (gmd:identifier/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation identifier(s), if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:citedResponsibleParty) or (gmd:citedResponsibleParty/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:citedResponsibleParty) or (gmd:citedResponsibleParty/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation cited responsible party(ies), if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:series) or (gmd:series/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:series) or (gmd:series/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation series, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M38"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M38"/>
	<xsl:template match="@*|node()" priority="-2" mode="M38">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M38"/>
	</xsl:template>
	<!--PATTERN Citation_alternateTitle_must_have_String_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Citation" priority="1000" mode="M39">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Citation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:alternateTitle) or ((gmd:alternateTitle/gco:CharacterString) and (string-length(normalize-space(gmd:alternateTitle/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:alternateTitle) or ((gmd:alternateTitle/gco:CharacterString) and (string-length(normalize-space(gmd:alternateTitle/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
				gmd:CI_Citation/gmd:alternateTitle, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M39"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M39"/>
	<xsl:template match="@*|node()" priority="-2" mode="M39">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M39"/>
	</xsl:template>
	<!--PATTERN ResponsibleParty_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_ResponsibleParty" priority="1000" mode="M40">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_ResponsibleParty"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(gmd:individualName and (string-length(normalize-space(gmd:individualName/gco:CharacterString)) &gt; 0)) or (gmd:organisationName and (string-length(normalize-space(gmd:organisationName/gco:CharacterString)) &gt; 0)) or (gmd:positionName and (string-length(normalize-space(gmd:positionName/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(gmd:individualName and (string-length(normalize-space(gmd:individualName/gco:CharacterString)) &gt; 0)) or (gmd:organisationName and (string-length(normalize-space(gmd:organisationName/gco:CharacterString)) &gt; 0)) or (gmd:positionName and (string-length(normalize-space(gmd:positionName/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        A responsible party must be identified by either the name of the individual, organisation or position, with non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:contactInfo) or (gmd:contactInfo/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:contactInfo) or (gmd:contactInfo/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The responsible party contact information, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:role/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:role/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The responsible party role must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M40"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M40"/>
	<xsl:template match="@*|node()" priority="-2" mode="M40">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M40"/>
	</xsl:template>
	<!--PATTERN Date_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Date" priority="1000" mode="M41">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Date"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:date/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:date/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The date must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:dateType/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:dateType/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The date type must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M41"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M41"/>
	<xsl:template match="@*|node()" priority="-2" mode="M41">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M41"/>
	</xsl:template>
	<!--PATTERN Series_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Series" priority="1000" mode="M42">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Series"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:name) or ((gmd:name/gco:CharacterString) and (string-length(normalize-space(gmd:name/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:name) or ((gmd:name/gco:CharacterString) and (string-length(normalize-space(gmd:name/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The series name, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M42"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M42"/>
	<xsl:template match="@*|node()" priority="-2" mode="M42">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M42"/>
	</xsl:template>
	<!--PATTERN Contact_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Contact" priority="1000" mode="M43">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Contact"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Contact must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:phone) or (gmd:phone/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:phone) or (gmd:phone/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The contact phone, if present, must have ontent.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:address) or (gmd:address/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:address) or (gmd:address/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The contact address, if present, must have ontent.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:onlineResource) or (gmd:onlineResource/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:onlineResource) or (gmd:onlineResource/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The contact online resource, if present, must have ontent.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:hoursOfService) or ((gmd:hoursOfService/gco:CharacterString) and (string-length(normalize-space(gmd:hoursOfService/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:hoursOfService) or ((gmd:hoursOfService/gco:CharacterString) and (string-length(normalize-space(gmd:hoursOfService/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The contact hours of service, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:contactInstructions) or ((gmd:contactInstructions/gco:CharacterString) and (string-length(normalize-space(gmd:contactInstructions/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:contactInstructions) or ((gmd:contactInstructions/gco:CharacterString) and (string-length(normalize-space(gmd:contactInstructions/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The contact instructions, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M43"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M43"/>
	<xsl:template match="@*|node()" priority="-2" mode="M43">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M43"/>
	</xsl:template>
	<!--PATTERN OnlineResource_must_have_Valid_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_OnlineResource" priority="1000" mode="M44">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_OnlineResource"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:linkage/gmd:URL and (string-length(normalize-space(gmd:linkage/gmd:URL)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:linkage/gmd:URL and (string-length(normalize-space(gmd:linkage/gmd:URL)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The online resource linkage must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:protocol) or ((gmd:protocol/gco:CharacterString) and (string-length(normalize-space(gmd:protocol/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:protocol) or ((gmd:protocol/gco:CharacterString) and (string-length(normalize-space(gmd:protocol/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The online resource protocol, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:name) or ((gmd:name/gco:CharacterString) and (string-length(normalize-space(gmd:name/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:name) or ((gmd:name/gco:CharacterString) and (string-length(normalize-space(gmd:name/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The online resource name, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M44"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M44"/>
	<xsl:template match="@*|node()" priority="-2" mode="M44">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M44"/>
	</xsl:template>
	<!--PATTERN Address_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Address" priority="1000" mode="M45">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Address"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
	    Address must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:deliveryPoint) or ((gmd:deliveryPoint/gco:CharacterString) and (string-length(normalize-space(gmd:deliveryPoint/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:deliveryPoint) or ((gmd:deliveryPoint/gco:CharacterString) and (string-length(normalize-space(gmd:deliveryPoint/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The address delivery point(s), if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:city) or ((gmd:city/gco:CharacterString) and (string-length(normalize-space(gmd:city/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:city) or ((gmd:city/gco:CharacterString) and (string-length(normalize-space(gmd:city/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The address city, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:administrativeArea) or ((gmd:administrativeArea/gco:CharacterString) and (string-length(normalize-space(gmd:administrativeArea/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:administrativeArea) or ((gmd:administrativeArea/gco:CharacterString) and (string-length(normalize-space(gmd:administrativeArea/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The address administrative area, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:postalCode) or ((gmd:postalCode/gco:CharacterString) and (string-length(normalize-space(gmd:postalCode/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:postalCode) or ((gmd:postalCode/gco:CharacterString) and (string-length(normalize-space(gmd:postalCode/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The address postal code, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:country) or ((gmd:country/gco:CharacterString) and (string-length(normalize-space(gmd:country/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:country) or ((gmd:country/gco:CharacterString) and (string-length(normalize-space(gmd:country/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The address country, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:electronicMailAddress) or ((gmd:electronicMailAddress/gco:CharacterString) and (string-length(normalize-space(gmd:electronicMailAddress/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:electronicMailAddress) or ((gmd:electronicMailAddress/gco:CharacterString) and (string-length(normalize-space(gmd:electronicMailAddress/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The address electronic mail address(es), if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M45"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M45"/>
	<xsl:template match="@*|node()" priority="-2" mode="M45">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M45"/>
	</xsl:template>
	<!--PATTERN Band_units_must_be_present_if_min_and_max_values_present-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Band" priority="1000" mode="M46">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Band"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:maxValue or gmd:minValue or gmd:peakResponse) or ((gmd:maxValue or gmd:minValue or gmd:peakResponse) and gmd:units/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:maxValue or gmd:minValue or gmd:peakResponse) or ((gmd:maxValue or gmd:minValue or gmd:peakResponse) and gmd:units/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			  Units are mandatory if maxValue, minValue, or peakResponse is provided.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M46"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M46"/>
	<xsl:template match="@*|node()" priority="-2" mode="M46">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M46"/>
	</xsl:template>
</xsl:stylesheet>
