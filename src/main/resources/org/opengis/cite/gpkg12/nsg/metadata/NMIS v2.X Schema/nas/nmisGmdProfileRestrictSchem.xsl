<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gss="http://www.isotc211.org/2005/gss" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:genc="http://api.nsgreg.nga.mil/schema/genc/2.0" xmlns:genc-cmn="http://api.nsgreg.nga.mil/schema/genc/2.0/genc-cmn" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ism="urn:us:gov:ic:ism" xmlns:nas="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" xmlns:reg="http://api.nsgreg.nga.mil/schema/register/1.0" version="1.0">
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
		<svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="NMIS GMD Profile Restriction Schematron validation" schemaVersion="">
			<xsl:comment>
				<xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
			</xsl:comment>
			<svrl:ns-prefix-in-attribute-values uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmi" prefix="gmi"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gss" prefix="gss"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml/3.2" prefix="gml"/>
			<svrl:ns-prefix-in-attribute-values uri="http://api.nsgreg.nga.mil/schema/genc/2.0" prefix="genc"/>
			<svrl:ns-prefix-in-attribute-values uri="http://api.nsgreg.nga.mil/schema/genc/2.0/genc-cmn" prefix="genc-cmn"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
			<svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
			<svrl:ns-prefix-in-attribute-values uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" prefix="nas"/>
			<svrl:ns-prefix-in-attribute-values uri="http://api.nsgreg.nga.mil/schema/register/1.0" prefix="reg"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Metadata_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Metadata_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M19"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Locale_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Locale_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M20"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Keywords_includes_Content</xsl:attribute>
				<xsl:attribute name="name">Keywords_includes_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M21"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Indentification_includes_Content</xsl:attribute>
				<xsl:attribute name="name">Indentification_includes_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M22"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">SecurityConstraints_include_ClassificationSystem</xsl:attribute>
				<xsl:attribute name="name">SecurityConstraints_include_ClassificationSystem</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M23"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">LegalConstraints_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">LegalConstraints_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M24"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Scope_limited_to_One</xsl:attribute>
				<xsl:attribute name="name">Scope_limited_to_One</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M25"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Lineage_must_have_content</xsl:attribute>
				<xsl:attribute name="name">Lineage_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M26"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Temporal_extent_must_have_content_type_gmlTimePeriod_or_gmlTimeInstant</xsl:attribute>
				<xsl:attribute name="name">Temporal_extent_must_have_content_type_gmlTimePeriod_or_gmlTimeInstant</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M27"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">GridSpatialRepresentation_axisDimensionProperties_must_be_present</xsl:attribute>
				<xsl:attribute name="name">GridSpatialRepresentation_axisDimensionProperties_must_be_present</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M28"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">GMD_Georectified_cornerPoints_must_be_present</xsl:attribute>
				<xsl:attribute name="name">GMD_Georectified_cornerPoints_must_be_present</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M29"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">VectorSpatialRepresentation_must_have_content</xsl:attribute>
				<xsl:attribute name="name">VectorSpatialRepresentation_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M30"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MdIdentifier_must_have_Authority</xsl:attribute>
				<xsl:attribute name="name">MdIdentifier_must_have_Authority</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M31"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MdIdentifierAuthority_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">MdIdentifierAuthority_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M32"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">AuthorityLocalHref_must_be_Valid</xsl:attribute>
				<xsl:attribute name="name">AuthorityLocalHref_must_be_Valid</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M33"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">RsIdentifierAuthority_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">RsIdentifierAuthority_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M34"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ReferenceSystem_must_have_content</xsl:attribute>
				<xsl:attribute name="name">ReferenceSystem_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M35"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Identifier_includes_Content</xsl:attribute>
				<xsl:attribute name="name">Identifier_includes_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M36"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ImageDescription_must_have_content</xsl:attribute>
				<xsl:attribute name="name">ImageDescription_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M37"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">RangeDimension_must_have_content</xsl:attribute>
				<xsl:attribute name="name">RangeDimension_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M38"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Band_must_have_content</xsl:attribute>
				<xsl:attribute name="name">Band_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M39"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">NMF_DigitalTransferOptions_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">NMF_DigitalTransferOptions_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M40"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TimePosition_must_not_have_InconsistentContent</xsl:attribute>
				<xsl:attribute name="name">TimePosition_must_not_have_InconsistentContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M41"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TimeInstantIsolated_must_not_have_InconsistentContent</xsl:attribute>
				<xsl:attribute name="name">TimeInstantIsolated_must_not_have_InconsistentContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M42"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">BoundingPolygon_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">BoundingPolygon_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M43"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TemporalExtent_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">TemporalExtent_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M44"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TimePosition_must_have_ValidContent</xsl:attribute>
				<xsl:attribute name="name">TimePosition_must_have_ValidContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M45"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TimePeriod_must_not_have_InconsistentEnds</xsl:attribute>
				<xsl:attribute name="name">TimePeriod_must_not_have_InconsistentEnds</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M46"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TimePeriod_must_have_PositiveDuration</xsl:attribute>
				<xsl:attribute name="name">TimePeriod_must_have_PositiveDuration</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M47"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">VerticalExtent_Valid</xsl:attribute>
				<xsl:attribute name="name">VerticalExtent_Valid</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M48"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Contact_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">Contact_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M49"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ContactLocalHref_must_be_Valid</xsl:attribute>
				<xsl:attribute name="name">ContactLocalHref_must_be_Valid</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M50"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Series_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Series_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M51"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">CellGeometryCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">CellGeometryCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M52"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">CharacterSetCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">CharacterSetCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M53"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ClassificationCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">ClassificationCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M54"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Country_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">Country_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M55"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">CoverageContentTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">CoverageContentTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M56"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DateTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">DateTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M57"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DimensionNameTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">DimensionNameTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M58"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">KeywordTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">KeywordTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M59"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ImagingConditionCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">ImagingConditionCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M60"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">LanguageCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">LanguageCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M61"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MaintenanceFrequencyCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">MaintenanceFrequencyCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M62"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ProgressCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">ProgressCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M63"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ResourceAssociationTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">ResourceAssociationTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M64"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">RestrictionCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">RestrictionCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M65"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">RoleCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">RoleCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M66"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ScopeCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">ScopeCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M67"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">SpatialRepresentationTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">SpatialRepresentationTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M68"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TopologyLevelCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">TopologyLevelCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M69"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">PolygonSrsName_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">PolygonSrsName_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M70"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">VerticalCRS_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">VerticalCRS_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M71"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">RsIdentifier_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">RsIdentifier_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M72"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">gco-Record_contains_proper_derived_class</xsl:attribute>
				<xsl:attribute name="name">gco-Record_contains_proper_derived_class</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M73"/>
		</svrl:schematron-output>
	</xsl:template>
	<!--SCHEMATRON PATTERNS-->
	<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">NMIS GMD Profile Restriction Schematron validation</svrl:text>
	<xsl:param name="GPAS" select="'http://metadata.ces.mil/mdr/ns/GPAS'"/>
	<xsl:param name="GSIP" select="'http://metadata.ces.mil/mdr/ns/GSIP'"/>
	<xsl:param name="NSGREG" select="'http://api.nsgreg.nga.mil'"/>
	<xsl:param name="NMF_part2_profile" select="(//gmd:DQ_DataQuality/gmd:report) or (//gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep) or (//gmd:DQ_DataQuality/gmd:lineage/LI_Lineage/gmd:source)"/>
	<xsl:param name="NMF_part3_profile" select="(//gmi:MI_Georectified) or (//gmi:MI_Georeferenceable) or (//gmd:MD_CoverageDescription) or (//gmi:MI_ImageDescription) or (//gmi:MI_AcquisitionInformation)"/>
	<xsl:param name="Record_AbstractDataComponent_Subclasses" select="'swe:Quantityswe:QuantityRangeswe:Categoryswe:Booleanswe:Categoryswe:CategoryRangeswe:Countswe:CountRangeswe:Textswe:Timeswe:TimeRangeswe:DataArrayswe:Matrixswe:DataChoiceswe:DataRecordswe:Vector'"/>
	<!--PATTERN Metadata_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Metadata" priority="1000" mode="M19">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:hierarchLevel/* and (count(gmd:hierarchLevel) = 1)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:hierarchLevel/* and (count(gmd:hierarchLevel) = 1)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata must include exactly one hierarchal level, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:hierarchLevelName/* and (count(gmd:hierarchLevelName) = 1)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:hierarchLevelName/* and (count(gmd:hierarchLevelName) = 1)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata must include exactly one hierarchal level name with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:metadataStandardName/* and (count(gmd:metadataStandardName) = 1)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:metadataStandardName/* and (count(gmd:metadataStandardName) = 1)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata must include exactly one meta data Standard Name with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:metadataStandardVersion/* and (count(gmd:metadataStandardVersion) = 1)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:metadataStandardVersion/* and (count(gmd:metadataStandardVersion) = 1)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata must include exactly one meta data Standard Version with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:metadataConstraints/* and (count(gmd:metadataConstraints) &lt;= 2)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:metadataConstraints/* and (count(gmd:metadataConstraints) &lt;= 2)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata must include at least one but no more than two meta data contraints, with content..</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M19"/>
	<xsl:template match="@*|node()" priority="-2" mode="M19">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<!--PATTERN Locale_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:PT_Locale" priority="1000" mode="M20">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:PT_Locale"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:country/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:country/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata must include at least one country, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M20"/>
	<xsl:template match="@*|node()" priority="-2" mode="M20">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<!--PATTERN Keywords_includes_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Keywords" priority="1000" mode="M21">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Keywords"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:thesaurusName/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:thesaurusName/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata keywords must include at least 1 thesaurus name, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M21"/>
	<xsl:template match="@*|node()" priority="-2" mode="M21">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<!--PATTERN Indentification_includes_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Indentification" priority="1000" mode="M22">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Indentification"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:pointOfContact/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:pointOfContact/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Identification must include at least 1 point of contact name, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:descriptiveKeywords/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:descriptiveKeywords/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Identification must include at least 1 descriptive keyword, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:resourceConstraints/* and (count(gmd:resourceConstraints) &lt;= 2)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:resourceConstraints/* and (count(gmd:resourceConstraints) &lt;= 2)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata must include at least one but no more than two resource contraints, with content..</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M22"/>
	<xsl:template match="@*|node()" priority="-2" mode="M22">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<!--PATTERN SecurityConstraints_include_ClassificationSystem-->
	<!--RULE -->
	<xsl:template match="*[*/gmd:classificationSystem]" priority="1000" mode="M23">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[*/gmd:classificationSystem]"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(nas:MD_SecurityConstraints or gmd:MD_SecurityConstraints) or */gmd:classificationSystem/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(nas:MD_SecurityConstraints or gmd:MD_SecurityConstraints) or */gmd:classificationSystem/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The security constraints must include at least 1 classification system, with content(test).</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M23"/>
	<xsl:template match="@*|node()" priority="-2" mode="M23">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<!--PATTERN LegalConstraints_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_LegalConstraints" priority="1000" mode="M24">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_LegalConstraints"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:accessConstraints or gmd:useConstraints"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:accessConstraints or gmd:useConstraints">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The legal constraints constraints must have either access or use constraints.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M24"/>
	<xsl:template match="@*|node()" priority="-2" mode="M24">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<!--PATTERN Scope_limited_to_One-->
	<!--RULE -->
	<xsl:template match="gmd:DQ_Scope" priority="1000" mode="M25">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:DQ_Scope"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:levelDescription/* and (count(gmd:levelDescription) = 1)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:levelDescription/* and (count(gmd:levelDescription) = 1)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The scope must include exactly one level description, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M25"/>
	<xsl:template match="@*|node()" priority="-2" mode="M25">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<!--PATTERN Lineage_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmd:LI_Lineage" priority="1000" mode="M26">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:LI_Lineage"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="($NMF_part2_profile and *) or (not($NMF_part2_profile) and gmd:statement/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($NMF_part2_profile and *) or (not($NMF_part2_profile) and gmd:statement/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Lineage must have content.  If only using entities of NMF Part 1 Core, statement must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M26"/>
	<xsl:template match="@*|node()" priority="-2" mode="M26">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<!--PATTERN Temporal_extent_must_have_content_type_gmlTimePeriod_or_gmlTimeInstant-->
	<!--RULE -->
	<xsl:template match="gmd:EX_TemporalExtent/gmd:extent" priority="1000" mode="M27">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_TemporalExtent/gmd:extent"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(string-length(normalize-space(@xlink:href)) &gt; 0) or (gml:TimePeriod or gml:TimeInstant)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(string-length(normalize-space(@xlink:href)) &gt; 0) or (gml:TimePeriod or gml:TimeInstant)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The temporal extent must be either a non-empty xlink:href or it must have content of the type gml:TimerPeriod or gml:TimeInstant</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M27"/>
	<xsl:template match="@*|node()" priority="-2" mode="M27">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<!--PATTERN GridSpatialRepresentation_axisDimensionProperties_must_be_present-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata/gmd:spatialRepresentationInfo" priority="1000" mode="M28">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata/gmd:spatialRepresentationInfo"/>
		<xsl:variable name="axisDimPropsCount" select="count(*/gmd:axisDimensionProperties)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not((name(*/*[1])='gmd:numberOfDimensions') and (name(*/*[$axisDimPropsCount+2])='gmd:cellGeometry')                                       and (name(*/*[$axisDimPropsCount+3])='gmd:transformationParameterAvailability')) or */gmd:axisDimensionProperties"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not((name(*/*[1])='gmd:numberOfDimensions') and (name(*/*[$axisDimPropsCount+2])='gmd:cellGeometry') and (name(*/*[$axisDimPropsCount+3])='gmd:transformationParameterAvailability')) or */gmd:axisDimensionProperties">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        GridSpatialRepresentation must include at least one axisDimensionProperties element.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M28"/>
	<xsl:template match="@*|node()" priority="-2" mode="M28">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<!--PATTERN GMD_Georectified_cornerPoints_must_be_present-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata/gmd:spatialRepresentationInfo" priority="1000" mode="M29">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata/gmd:spatialRepresentationInfo"/>
		<xsl:variable name="axisDimPropsCount" select="count(*/gmd:axisDimensionProperties)"/>
		<xsl:variable name="chkPntDescrCount" select="count(*/gmd:checkPointDescription)"/>
		<xsl:variable name="crnrPntCount" select="count(*/gmd:cornerPoints)"/>
		<xsl:variable name="ctrPntCount" select="count(*/gmd:centerPoint)"/>
		<xsl:variable name="elemCountTot1" select="$axisDimPropsCount + $chkPntDescrCount + $crnrPntCount + $ctrPntCount"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not((name(*/*[1])='gmd:numberOfDimensions') and (name(*/*[$axisDimPropsCount+4])='gmd:checkPointAvailability')                                 and (name(*/*[$elemCountTot1+5])='gmd:pointInPixel')) or */gmd:cornerPoints"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not((name(*/*[1])='gmd:numberOfDimensions') and (name(*/*[$axisDimPropsCount+4])='gmd:checkPointAvailability') and (name(*/*[$elemCountTot1+5])='gmd:pointInPixel')) or */gmd:cornerPoints">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
            Georectified must include at least one cornerPoints element.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M29"/>
	<xsl:template match="@*|node()" priority="-2" mode="M29">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<!--PATTERN VectorSpatialRepresentation_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_VectorSpatialRepresentation" priority="1000" mode="M30">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_VectorSpatialRepresentation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        MD_VectorSpatialRepresentation must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M30"/>
	<xsl:template match="@*|node()" priority="-2" mode="M30">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<!--PATTERN MdIdentifier_must_have_Authority-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Identifier" priority="1000" mode="M31">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Identifier"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:authority"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:authority">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata identifier must have an authority.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M31"/>
	<xsl:template match="@*|node()" priority="-2" mode="M31">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
	<!--PATTERN MdIdentifierAuthority_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Identifier/gmd:authority" priority="1000" mode="M32">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Identifier/gmd:authority"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(string-length(normalize-space(@xlink:href)) &gt; 0) or gmd:CI_Citation"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(string-length(normalize-space(@xlink:href)) &gt; 0) or gmd:CI_Citation">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata identifier authority must be either a non-empty xlink:href or a valid citation.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M32"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M32"/>
	<xsl:template match="@*|node()" priority="-2" mode="M32">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M32"/>
	</xsl:template>
	<!--PATTERN AuthorityLocalHref_must_be_Valid-->
	<!--RULE -->
	<xsl:template match="gmd:authority" priority="1000" mode="M33">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:authority"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(@xlink:href) or (not(starts-with(@xlink:href, '#')) or (starts-with(@xlink:href, '#') and (//gmd:CI_Citation[@id=(substring-after(current()/@xlink:href,'#'))])))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@xlink:href) or (not(starts-with(@xlink:href, '#')) or (starts-with(@xlink:href, '#') and (//gmd:CI_Citation[@id=(substring-after(current()/@xlink:href,'#'))])))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The authority attempts to locally reference a non-existent citation.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M33"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M33"/>
	<xsl:template match="@*|node()" priority="-2" mode="M33">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M33"/>
	</xsl:template>
	<!--PATTERN RsIdentifierAuthority_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmd:RS_Identifier/gmd:authority" priority="1000" mode="M34">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:RS_Identifier/gmd:authority"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(string-length(normalize-space(@xlink:href)) &gt; 0) or gmd:CI_Citation"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(string-length(normalize-space(@xlink:href)) &gt; 0) or gmd:CI_Citation">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata identifier authority must be either a non-empty xlink:href or a valid citation.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M34"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M34"/>
	<xsl:template match="@*|node()" priority="-2" mode="M34">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M34"/>
	</xsl:template>
	<!--PATTERN ReferenceSystem_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ReferenceSystem" priority="1000" mode="M35">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ReferenceSystem"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Reference System must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M35"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M35"/>
	<xsl:template match="@*|node()" priority="-2" mode="M35">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M35"/>
	</xsl:template>
	<!--PATTERN Identifier_includes_Content-->
	<!--RULE -->
	<xsl:template match="gmd:RS_Identifier" priority="1000" mode="M36">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:RS_Identifier"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:codeSpace/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:codeSpace/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        RS Identifier must include at least 1 codeSpace, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M36"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M36"/>
	<xsl:template match="@*|node()" priority="-2" mode="M36">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M36"/>
	</xsl:template>
	<!--PATTERN ImageDescription_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ImageDescription" priority="1000" mode="M37">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ImageDescription"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Image description must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M37"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M37"/>
	<xsl:template match="@*|node()" priority="-2" mode="M37">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M37"/>
	</xsl:template>
	<!--PATTERN RangeDimension_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_RangeDimension" priority="1000" mode="M38">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_RangeDimension"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        RangeDimension must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M38"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M38"/>
	<xsl:template match="@*|node()" priority="-2" mode="M38">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M38"/>
	</xsl:template>
	<!--PATTERN Band_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Band" priority="1000" mode="M39">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Band"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Band must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M39"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M39"/>
	<xsl:template match="@*|node()" priority="-2" mode="M39">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M39"/>
	</xsl:template>
	<!--PATTERN NMF_DigitalTransferOptions_must_have_Content-->
	<!--RULE -->
	<xsl:template match="nas:NMF_DigitalTransferOptions" priority="1000" mode="M40">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:NMF_DigitalTransferOptions"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The digital transfer options must have content, e.g. on-line resource information.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M40"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M40"/>
	<xsl:template match="@*|node()" priority="-2" mode="M40">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M40"/>
	</xsl:template>
	<!--PATTERN TimePosition_must_not_have_InconsistentContent-->
	<!--RULE -->
	<xsl:template match="gml:timePosition" priority="1000" mode="M41">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gml:timePosition"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(@indeterminatePosition = 'now')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@indeterminatePosition = 'now')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position indeterminate position 'now' shall not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not((@indeterminatePosition = 'unknown') and normalize-space(.))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not((@indeterminatePosition = 'unknown') and normalize-space(.))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position indeterminate position 'unknown' shall not be used if there is a specified time position value.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(((@indeterminatePosition = 'before') or (@indeterminatePosition = 'after')) and not(normalize-space(.)))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(((@indeterminatePosition = 'before') or (@indeterminatePosition = 'after')) and not(normalize-space(.)))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position indeterminate positions 'before' and 'after' shall not be used if there is no specified time position value..</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M41"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M41"/>
	<xsl:template match="@*|node()" priority="-2" mode="M41">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M41"/>
	</xsl:template>
	<!--PATTERN TimeInstantIsolated_must_not_have_InconsistentContent-->
	<!--RULE -->
	<xsl:template match="gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition" priority="1000" mode="M42">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(@indeterminatePosition)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@indeterminatePosition)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position indeterminate position shall not be used in the case of an isolated time instant (as opposed to one that is participating in a time period).</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M42"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M42"/>
	<xsl:template match="@*|node()" priority="-2" mode="M42">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M42"/>
	</xsl:template>
	<!--PATTERN BoundingPolygon_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:EX_BoundingPolygon" priority="1000" mode="M43">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M43"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M43"/>
	<xsl:template match="@*|node()" priority="-2" mode="M43">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M43"/>
	</xsl:template>
	<!--PATTERN TemporalExtent_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:EX_TemporalExtent" priority="1000" mode="M44">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_TemporalExtent"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:extent/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:extent/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The temporal extent must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M44"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M44"/>
	<xsl:template match="@*|node()" priority="-2" mode="M44">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M44"/>
	</xsl:template>
	<!--PATTERN TimePosition_must_have_ValidContent-->
	<!--RULE -->
	<xsl:template match="gml:timePosition" priority="1000" mode="M45">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gml:timePosition"/>
		<xsl:variable name="year" select="number(substring(.,1,4))"/>
		<xsl:variable name="month" select="number(substring(.,6,2))"/>
		<xsl:variable name="day" select="number(substring(.,9,2))"/>
		<xsl:variable name="hour" select="number(substring(.,12,2))"/>
		<xsl:variable name="minute" select="number(substring(.,15,2))"/>
		<xsl:variable name="second1" select="number(substring(.,18,2))"/>
		<xsl:variable name="second2" select="number(substring(.,18,4))"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(string-length(.) &gt;= 4) and (string-length(.) &lt;= 22) or (@indeterminatePosition = 'unknown')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(string-length(.) &gt;= 4) and (string-length(.) &lt;= 22) or (@indeterminatePosition = 'unknown')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position element contains '<xsl:text/>
						<xsl:value-of select="."/>
						<xsl:text/>' but should contain a proper date or dateTime.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(string-length(.) = 4) or         ((string-length(.) = 4) and ($year))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(string-length(.) = 4) or ((string-length(.) = 4) and ($year))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position element contains '<xsl:text/>
						<xsl:value-of select="."/>
						<xsl:text/>' but should contain a year in the format CCYY.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not((string-length(.) &gt; 4) and (string-length(.) &lt;= 7)) or          ((string-length(.) = 7) and ($year) and          (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not((string-length(.) &gt; 4) and (string-length(.) &lt;= 7)) or ((string-length(.) = 7) and ($year) and (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position element contains '<xsl:text/>
						<xsl:value-of select="."/>
						<xsl:text/>' but should contain a year-month in the format CCYY-MM.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not((string-length(.) &gt; 7) and (string-length(.) &lt;= 10)) or          ((string-length(.) = 10) and ($year) and          (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12) and          (substring(.,8,1) = '-') and ($day &gt;= 1 and $day &lt;= 31))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not((string-length(.) &gt; 7) and (string-length(.) &lt;= 10)) or ((string-length(.) = 10) and ($year) and (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12) and (substring(.,8,1) = '-') and ($day &gt;= 1 and $day &lt;= 31))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position element contains '<xsl:text/>
						<xsl:value-of select="."/>
						<xsl:text/>' but should contain a year-month-day in the format CCYY-MM-DD.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not((string-length(.) &gt; 12) and (string-length(.) &lt;= 20)) or          ((string-length(.) = 20) and ($year) and          (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12) and          (substring(.,8,1) = '-') and ($day &gt;= 1 and $day &lt;= 31) and         (substring(.,11,1) = 'T') and ($hour &gt;= 0 and $hour &lt;= 23) and          (substring(.,14,1) = ':') and ($minute &gt;= 0 and $minute &lt;= 59) and         (substring(.,17,1) = ':') and ($second1 &gt;=0 and $second1 &lt;= 59) and         (substring(.,20,1) = 'Z'))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not((string-length(.) &gt; 12) and (string-length(.) &lt;= 20)) or ((string-length(.) = 20) and ($year) and (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12) and (substring(.,8,1) = '-') and ($day &gt;= 1 and $day &lt;= 31) and (substring(.,11,1) = 'T') and ($hour &gt;= 0 and $hour &lt;= 23) and (substring(.,14,1) = ':') and ($minute &gt;= 0 and $minute &lt;= 59) and (substring(.,17,1) = ':') and ($second1 &gt;=0 and $second1 &lt;= 59) and (substring(.,20,1) = 'Z'))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position element contains '<xsl:text/>
						<xsl:value-of select="."/>
						<xsl:text/>' but should contain a year-month-day/hour-minute-second in the format CCYY-MM-DDTHH:MM:SSZ.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not((string-length(.) &gt; 20) and (string-length(.) &lt;= 22)) or          ((string-length(.) = 22) and ($year) and          (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12) and          (substring(.,8,1) = '-') and ($day &gt;= 1 and $day &lt;= 31) and         (substring(.,11,1) = 'T') and ($hour &gt;= 0 and $hour &lt;= 23) and          (substring(.,14,1) = ':') and ($minute &gt;= 0 and $minute &lt;= 59) and         (substring(.,17,1) = ':') and ($second2 &gt;=0 and $second1 &lt;= 59) and         (substring(.,22,1) = 'Z'))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not((string-length(.) &gt; 20) and (string-length(.) &lt;= 22)) or ((string-length(.) = 22) and ($year) and (substring(.,5,1) = '-') and ($month &gt;= 1 and $month &lt;= 12) and (substring(.,8,1) = '-') and ($day &gt;= 1 and $day &lt;= 31) and (substring(.,11,1) = 'T') and ($hour &gt;= 0 and $hour &lt;= 23) and (substring(.,14,1) = ':') and ($minute &gt;= 0 and $minute &lt;= 59) and (substring(.,17,1) = ':') and ($second2 &gt;=0 and $second1 &lt;= 59) and (substring(.,22,1) = 'Z'))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position element contains '<xsl:text/>
						<xsl:value-of select="."/>
						<xsl:text/>' but should contain a year-month-day/hour-minute-second in the format CCYY-MM-DDTHH:MM:SS.SZ.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M45"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M45"/>
	<xsl:template match="@*|node()" priority="-2" mode="M45">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M45"/>
	</xsl:template>
	<!--PATTERN TimePeriod_must_not_have_InconsistentEnds-->
	<!--RULE -->
	<xsl:template match="gml:TimePeriod" priority="1000" mode="M46">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gml:TimePeriod"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gml:begin/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'after')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gml:begin/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'after')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The begin time position shall not have an indeterminate position of 'after'.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gml:end/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'before')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gml:end/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'before')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The end time position shall not have an indeterminate position of 'before'.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M46"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M46"/>
	<xsl:template match="@*|node()" priority="-2" mode="M46">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M46"/>
	</xsl:template>
	<!--PATTERN TimePeriod_must_have_PositiveDuration-->
	<!--RULE -->
	<xsl:template match="gml:TimePeriod" priority="1000" mode="M47">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gml:TimePeriod"/>
		<xsl:variable name="year_begin" select="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,1,4))"/>
		<xsl:variable name="month_begin" select="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,6,2))"/>
		<xsl:variable name="day_begin" select="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,9,2))"/>
		<xsl:variable name="hour_begin" select="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,12,2))"/>
		<xsl:variable name="minute_begin" select="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,15,2))"/>
		<xsl:variable name="second1_begin" select="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,18,2))"/>
		<xsl:variable name="second2_begin" select="number(substring(gml:begin/gml:TimeInstant/gml:timePosition,18,4))"/>
		<xsl:variable name="year_end" select="number(substring(gml:end/gml:TimeInstant/gml:timePosition,1,4))"/>
		<xsl:variable name="month_end" select="number(substring(gml:end/gml:TimeInstant/gml:timePosition,6,2))"/>
		<xsl:variable name="day_end" select="number(substring(gml:end/gml:TimeInstant/gml:timePosition,9,2))"/>
		<xsl:variable name="hour_end" select="number(substring(gml:end/gml:TimeInstant/gml:timePosition,12,2))"/>
		<xsl:variable name="minute_end" select="number(substring(gml:end/gml:TimeInstant/gml:timePosition,15,2))"/>
		<xsl:variable name="second1_end" select="number(substring(gml:end/gml:TimeInstant/gml:timePosition,18,2))"/>
		<xsl:variable name="second2_end" select="number(substring(gml:end/gml:TimeInstant/gml:timePosition,18,4))"/>
		<xsl:variable name="yrmth_begin" select="number(concat(year_begin, month_begin))"/>
		<xsl:variable name="yrmth_end" select="number(concat(year_end, month_end))"/>
		<xsl:variable name="date_begin" select="number(concat(yrmth_begin, day_begin))"/>
		<xsl:variable name="date_end" select="number(concat(yrmth_end, day_end))"/>
		<xsl:variable name="datehr_begin" select="number(concat(date_begin, hour_begin))"/>
		<xsl:variable name="datehr_end" select="number(concat(date_end, hour_end))"/>
		<xsl:variable name="datehrmn_begin" select="number(concat(datehr_begin, minute_begin))"/>
		<xsl:variable name="datehrmn_end" select="number(concat(datehr_end, minute_end))"/>
		<xsl:variable name="fullDate1_begin" select="number(concat(datehrmn_begin, second1_begin))"/>
		<xsl:variable name="fullDate2_begin" select="number(concat(datehrmn_begin, second2_begin))"/>
		<xsl:variable name="fullDate1_end" select="number(concat(datehrmn_end, second1_end))"/>
		<xsl:variable name="fullDate2_end" select="number(concat(datehrmn_end, second2_end))"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gml:begin/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'unknown') or not(gml:end/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'unknown') and         ((not($year_end) or not($year_begin)) or ($year_begin &lt;= $year_end)) and         ((not($month_end) or not($month_begin)) or ($yrmth_begin &lt;= $yrmth_end)) and         ((not($day_end) or not($day_begin)) or ($date_begin &lt;= $date_end)) and         ((not($hour_end) or not($hour_begin)) or ($datehr_begin &lt;= $datehr_end)) and         ((not($minute_end) or not($minute_begin)) or ($datehrmn_begin &lt;= $datehrmn_end)) and         ((not($second1_end) or not($second1_begin)) or ($fullDate1_begin &lt;= $fullDate1_end)) and         ((not($second2_end) or not($second2_begin)) or ($fullDate2_begin &lt;= $fullDate2_end))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gml:begin/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'unknown') or not(gml:end/gml:TimeInstant/gml:timePosition/@indeterminatePosition = 'unknown') and ((not($year_end) or not($year_begin)) or ($year_begin &lt;= $year_end)) and ((not($month_end) or not($month_begin)) or ($yrmth_begin &lt;= $yrmth_end)) and ((not($day_end) or not($day_begin)) or ($date_begin &lt;= $date_end)) and ((not($hour_end) or not($hour_begin)) or ($datehr_begin &lt;= $datehr_end)) and ((not($minute_end) or not($minute_begin)) or ($datehrmn_begin &lt;= $datehrmn_end)) and ((not($second1_end) or not($second1_begin)) or ($fullDate1_begin &lt;= $fullDate1_end)) and ((not($second2_end) or not($second2_begin)) or ($fullDate2_begin &lt;= $fullDate2_end))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time period element specifies a non-positive duration: '<xsl:text/>
						<xsl:value-of select="gml:begin/gml:TimeInstant/gml:timePosition"/>
						<xsl:text/>' to '<xsl:text/>
						<xsl:value-of select="gml:end/gml:TimeInstant/gml:timePosition"/>
						<xsl:text/>'.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M47"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M47"/>
	<xsl:template match="@*|node()" priority="-2" mode="M47">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M47"/>
	</xsl:template>
	<!--PATTERN VerticalExtent_Valid-->
	<!--RULE -->
	<xsl:template match="gmd:EX_VerticalExtent" priority="1000" mode="M48">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_VerticalExtent"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:minimumValue/gco:Real &lt;= gmd:maximumValue/gco:Real"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:minimumValue/gco:Real &lt;= gmd:maximumValue/gco:Real">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The vertical extent must be a valid interval.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M48"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M48"/>
	<xsl:template match="@*|node()" priority="-2" mode="M48">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M48"/>
	</xsl:template>
	<!--PATTERN Contact_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmd:contact" priority="1000" mode="M49">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:contact"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(string-length(normalize-space(@xlink:href)) &gt; 0) or gmd:CI_ResponsibleParty"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(string-length(normalize-space(@xlink:href)) &gt; 0) or gmd:CI_ResponsibleParty">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The contact must have valid content, either as an xlink:href or a valid responsible party.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M49"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M49"/>
	<xsl:template match="@*|node()" priority="-2" mode="M49">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M49"/>
	</xsl:template>
	<!--PATTERN ContactLocalHref_must_be_Valid-->
	<!--RULE -->
	<xsl:template match="gmd:contact" priority="1000" mode="M50">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:contact"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(@xlink:href) or (not(starts-with(@xlink:href, '#')) or (starts-with(@xlink:href, '#') and (//gmd:CI_ResponsibleParty[@id=(substring-after(current()/@xlink:href,'#'))])))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@xlink:href) or (not(starts-with(@xlink:href, '#')) or (starts-with(@xlink:href, '#') and (//gmd:CI_ResponsibleParty[@id=(substring-after(current()/@xlink:href,'#'))])))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The contact attempts to locally reference a non-existent responsible party.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M50"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M50"/>
	<xsl:template match="@*|node()" priority="-2" mode="M50">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M50"/>
	</xsl:template>
	<!--PATTERN Series_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Series" priority="1000" mode="M51">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Series"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The series must have content, e.g., a name.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M51"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M51"/>
	<xsl:template match="@*|node()" priority="-2" mode="M51">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M51"/>
	</xsl:template>
	<!--PATTERN CellGeometryCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmd:MD_CellGeometryCode" priority="1000" mode="M52">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_CellGeometryCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/CellGeometryCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/CellGeometryCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
	    The code list mush reference an NMF-appropriate published resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeListValue = document($url)/reg:ListedValue/gml:identifier"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeListValue = document($url)/reg:ListedValue/gml:identifier">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M52"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M52"/>
	<xsl:template match="@*|node()" priority="-2" mode="M52">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M52"/>
	</xsl:template>
	<!--PATTERN CharacterSetCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:MD_CharacterSetCode" priority="1000" mode="M53">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_CharacterSetCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/CharacterSetCode') or          @codeList = concat($NSGREG, '/codelist/CharacterSetCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/CharacterSetCode') or @codeList = concat($NSGREG, '/codelist/CharacterSetCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M53"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M53"/>
	<xsl:template match="@*|node()" priority="-2" mode="M53">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M53"/>
	</xsl:template>
	<!--PATTERN ClassificationCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ClassificationCode" priority="1000" mode="M54">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ClassificationCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/ClassificationCode') or          @codeList = concat($NSGREG, '/codelist/ClassificationCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/ClassificationCode') or @codeList = concat($NSGREG, '/codelist/ClassificationCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M54"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M54"/>
	<xsl:template match="@*|node()" priority="-2" mode="M54">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M54"/>
	</xsl:template>
	<!--PATTERN Country_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:Country" priority="1000" mode="M55">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:Country"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = concat($GPAS, '/codelist/iso3166-1/digraph')) or                          (@codeList = concat($GPAS, '/codelist/iso3166-1/trigraph')) or                          (@codeList = concat($GPAS, '/codelist/fips10-4/digraph')) or                         (@codeList = 'http://api.nsgreg.nga.mil/geo-political/GENC/3/2-1') or                         (@codeList = 'http://api.nsgreg.nga.mil/geo-political/GENC/2/2-1') "/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = concat($GPAS, '/codelist/iso3166-1/digraph')) or (@codeList = concat($GPAS, '/codelist/iso3166-1/trigraph')) or (@codeList = concat($GPAS, '/codelist/fips10-4/digraph')) or (@codeList = 'http://api.nsgreg.nga.mil/geo-political/GENC/3/2-1') or (@codeList = 'http://api.nsgreg.nga.mil/geo-political/GENC/2/2-1')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/genc:GeopoliticalEntityEntry/genc:encoding/genc:char3CodeURISet/genc-cmn:codespaceURL)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/genc:GeopoliticalEntityEntry/genc:encoding/genc:char3CodeURISet/genc-cmn:codespaceURL)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/genc:GeopoliticalEntityEntry/genc:encoding/genc:char3Code)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/genc:GeopoliticalEntityEntry/genc:encoding/genc:char3Code)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M55"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M55"/>
	<xsl:template match="@*|node()" priority="-2" mode="M55">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M55"/>
	</xsl:template>
	<!--PATTERN CoverageContentTypeCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmd:MD_CoverageContentTypeCode" priority="1000" mode="M56">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_CoverageContentTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/CoverageContentTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/CoverageContentTypeCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
	    The code list mush reference an NMF-appropriate published resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M56"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M56"/>
	<xsl:template match="@*|node()" priority="-2" mode="M56">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M56"/>
	</xsl:template>
	<!--PATTERN DateTypeCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:CI_DateTypeCode" priority="1000" mode="M57">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_DateTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/DateTypeCode') or          @codeList = concat($NSGREG, '/codelist/DateTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/DateTypeCode') or @codeList = concat($NSGREG, '/codelist/DateTypeCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M57"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M57"/>
	<xsl:template match="@*|node()" priority="-2" mode="M57">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M57"/>
	</xsl:template>
	<!--PATTERN DimensionNameTypeCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmd:MD_DimensionNameTypeCode" priority="1000" mode="M58">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_DimensionNameTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/DimensionNameTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/DimensionNameTypeCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
	    The code list mush reference an NMF-appropriate published resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M58"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M58"/>
	<xsl:template match="@*|node()" priority="-2" mode="M58">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M58"/>
	</xsl:template>
	<!--PATTERN KeywordTypeCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:MD_KeywordTypeCode" priority="1000" mode="M59">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_KeywordTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/KeywordTypeCode') or          @codeList = concat($NSGREG, '/codelist/KeywordTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/KeywordTypeCode') or @codeList = concat($NSGREG, '/codelist/KeywordTypeCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M59"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M59"/>
	<xsl:template match="@*|node()" priority="-2" mode="M59">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M59"/>
	</xsl:template>
	<!--PATTERN ImagingConditionCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ImagingConditionCode" priority="1000" mode="M60">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ImagingConditionCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/ImagingConditionCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/ImagingConditionCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
	    The code list mush reference an NMF-appropriate published resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M60"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M60"/>
	<xsl:template match="@*|node()" priority="-2" mode="M60">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M60"/>
	</xsl:template>
	<!--PATTERN LanguageCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="nas:LanguageCode" priority="1000" mode="M61">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:LanguageCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GPAS, '/codelist/iso639-2') or          @codeList = concat($NSGREG, '/codelist/ISO639-2')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GPAS, '/codelist/iso639-2') or @codeList = concat($NSGREG, '/codelist/ISO639-2')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace or          @codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace or @codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeListValue = document($url)/gml:Definition/gml:identifier or          @codeList = document($url)/reg:ListedValue/gml:identifier"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeListValue = document($url)/gml:Definition/gml:identifier or @codeList = document($url)/reg:ListedValue/gml:identifier">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M61"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M61"/>
	<xsl:template match="@*|node()" priority="-2" mode="M61">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M61"/>
	</xsl:template>
	<!--PATTERN MaintenanceFrequencyCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:MD_MaintenanceFrequencyCode" priority="1000" mode="M62">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_MaintenanceFrequencyCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/MaintenanceFrequencyCode') or          @codeList = concat($NSGREG, '/codelist/MaintenanceFrequencyCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/MaintenanceFrequencyCode') or @codeList = concat($NSGREG, '/codelist/MaintenanceFrequencyCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M62"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M62"/>
	<xsl:template match="@*|node()" priority="-2" mode="M62">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M62"/>
	</xsl:template>
	<!--PATTERN ProgressCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ProgressCode" priority="1000" mode="M63">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ProgressCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/ProgressCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/ProgressCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
	    The code list mush reference an NMF-appropriate published resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M63"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M63"/>
	<xsl:template match="@*|node()" priority="-2" mode="M63">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M63"/>
	</xsl:template>
	<!--PATTERN ResourceAssociationTypeCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:DS_ResourceAssociationTypeCode" priority="1000" mode="M64">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:DS_ResourceAssociationTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/ResourceAssociationTypeCode') or          @codeList = concat($NSGREG, '/codelist/ResourceAssociationTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/ResourceAssociationTypeCode') or @codeList = concat($NSGREG, '/codelist/ResourceAssociationTypeCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M64"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M64"/>
	<xsl:template match="@*|node()" priority="-2" mode="M64">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M64"/>
	</xsl:template>
	<!--PATTERN RestrictionCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:MD_RestrictionCode" priority="1000" mode="M65">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_RestrictionCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/RestrictionCode') or          @codeList = concat($NSGREG, '/codelist/RestrictionCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/RestrictionCode') or @codeList = concat($NSGREG, '/codelist/RestrictionCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M65"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M65"/>
	<xsl:template match="@*|node()" priority="-2" mode="M65">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M65"/>
	</xsl:template>
	<!--PATTERN RoleCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:CI_RoleCode" priority="1000" mode="M66">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_RoleCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/RoleCode') or          @codeList = concat($NSGREG, '/codelist/RoleCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/RoleCode') or @codeList = concat($NSGREG, '/codelist/RoleCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M66"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M66"/>
	<xsl:template match="@*|node()" priority="-2" mode="M66">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M66"/>
	</xsl:template>
	<!--PATTERN ScopeCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ScopeCode" priority="1000" mode="M67">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ScopeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/ScopeCode') or          @codeList = concat($NSGREG, '/codelist/ScopeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/ScopeCode') or @codeList = concat($NSGREG, '/codelist/ScopeCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M67"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M67"/>
	<xsl:template match="@*|node()" priority="-2" mode="M67">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M67"/>
	</xsl:template>
	<!--PATTERN SpatialRepresentationTypeCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:MD_SpatialRepresentationTypeCode" priority="1000" mode="M68">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_SpatialRepresentationTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/SpatialRepresentationTypeCode') or          @codeList = concat($NSGREG, '/codelist/SpatialRepresentationTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/SpatialRepresentationTypeCode') or @codeList = concat($NSGREG, '/codelist/SpatialRepresentationTypeCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate published NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M68"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M68"/>
	<xsl:template match="@*|node()" priority="-2" mode="M68">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M68"/>
	</xsl:template>
	<!--PATTERN TopologyLevelCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:MD_TopologyLevelCode" priority="1000" mode="M69">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_TopologyLevelCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/TopologyLevelCode') or          @codeList = concat($NSGREG, '/codelist/TopologyLevelCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/TopologyLevelCode') or @codeList = concat($NSGREG, '/codelist/TopologyLevelCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate NSG Registry resource. (DSE resources depricated)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(@codeList, '/', @codeListValue)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or          (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeList = document($url)/gml:Definition/gml:identifier/@codeSpace) or (@codeList = document($url)/reg:ListedValue/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeList must match the codespace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or          (@codeListValue = document($url)/reg:ListedValue/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@codeListValue = document($url)/gml:Definition/gml:identifier) or (@codeListValue = document($url)/reg:ListedValue/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified codeListValue must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.) = ''">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The element must be empty.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M69"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M69"/>
	<xsl:template match="@*|node()" priority="-2" mode="M69">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M69"/>
	</xsl:template>
	<!--PATTERN PolygonSrsName_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gml:Polygon" priority="1000" mode="M70">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gml:Polygon"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="starts-with(@srsName, concat($GSIP, '/crs')) or starts-with(@srsName, concat($NSGREG, '/coord-ref-system'))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="starts-with(@srsName, concat($GSIP, '/crs')) or starts-with(@srsName, concat($NSGREG, '/coord-ref-system'))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The CRS must be from the set registered in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document(@srsName)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document(@srsName)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified srsName must reference a net-accessible resource in the NSG Registry (DSE GSIP Governance Namespace depricated).</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(concat(substring-before(@srsName, '/crs'),'/crs') = document(@srsName)//gml:identifier/@codeSpace) or          (concat(substring-before(@srsName, '/coord-ref-system'), '/coord-ref-system') = document(@srsName)/reg:GeodeticCRS/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(concat(substring-before(@srsName, '/crs'),'/crs') = document(@srsName)//gml:identifier/@codeSpace) or (concat(substring-before(@srsName, '/coord-ref-system'), '/coord-ref-system') = document(@srsName)/reg:GeodeticCRS/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The body of the srsName must match the codeSpace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(substring-after(@srsName, 'crs/') = document(@srsName)//gml:identifier) or          (substring-after(@srsName, 'coord-ref-system/') = document(@srsName)/reg:GeodeticCRS/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(substring-after(@srsName, 'crs/') = document(@srsName)//gml:identifier) or (substring-after(@srsName, 'coord-ref-system/') = document(@srsName)/reg:GeodeticCRS/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The tail of the srsName ('<xsl:text/>
						<xsl:value-of select="substring-after(@srsName, 'crs/')"/>
						<xsl:text/>') must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M70"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M70"/>
	<xsl:template match="@*|node()" priority="-2" mode="M70">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M70"/>
	</xsl:template>
	<!--PATTERN VerticalCRS_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:verticalCRS" priority="1000" mode="M71">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:verticalCRS"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="starts-with(@xlink:href, concat($GSIP, '/crs')) or starts-with(@xlink:href, concat($NSGREG, '/coord-ref-system'))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="starts-with(@xlink:href, concat($GSIP, '/crs')) or starts-with(@xlink:href, concat($NSGREG, '/coord-ref-system'))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The CRS must be from the set registered in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document(@xlink:href)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document(@xlink:href)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The specified xlink:href must reference a net-accessible resource in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(concat(substring-before(@xlink:href, '/crs'),'/crs') = document(@xlink:href)//gml:identifier/@codeSpace) or          (concat(substring-before(@xlink:href, '/coord-ref-system'), '/coord-ref-system') = document(@xlink:href)/reg:VerticalCRS/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(concat(substring-before(@xlink:href, '/crs'),'/crs') = document(@xlink:href)//gml:identifier/@codeSpace) or (concat(substring-before(@xlink:href, '/coord-ref-system'), '/coord-ref-system') = document(@xlink:href)/reg:VerticalCRS/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The body of the srsName must match the codeSpace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(substring-after(@xlink:href, 'crs/') = document(@xlink:href)//gml:identifier) or          (substring-after(@xlink:href, 'coord-ref-system/') = document(@xlink:href)/reg:VerticalCRS/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(substring-after(@xlink:href, 'crs/') = document(@xlink:href)//gml:identifier) or (substring-after(@xlink:href, 'coord-ref-system/') = document(@xlink:href)/reg:VerticalCRS/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The tail of the srsName ('<xsl:text/>
						<xsl:value-of select="substring-after(@xlink:href, 'crs/')"/>
						<xsl:text/>') must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M71"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M71"/>
	<xsl:template match="@*|node()" priority="-2" mode="M71">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M71"/>
	</xsl:template>
	<!--PATTERN RsIdentifier_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gmd:RS_Identifier" priority="1000" mode="M72">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:RS_Identifier"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(gmd:codeSpace/gco:CharacterString = concat($GSIP, '/crs')) or (gmd:codeSpace/gco:CharacterString = concat($NSGREG, '/coord-ref-system'))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(gmd:codeSpace/gco:CharacterString = concat($GSIP, '/crs')) or (gmd:codeSpace/gco:CharacterString = concat($NSGREG, '/coord-ref-system'))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The CRS must be from the set registered in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="url" select="concat(gmd:codeSpace/gco:CharacterString, '/', gmd:code/gco:CharacterString)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="document($url)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="document($url)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The URL '<xsl:text/>
						<xsl:value-of select="$url"/>
						<xsl:text/>' must reference a net-accessible resource in the NSG Resgistry (DSE GSIP Governance Namespace depricated.)</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(gmd:codeSpace/gco:CharacterString = document($url)//gml:identifier/@codeSpace) or          (gmd:codeSpace/gco:CharacterString = document($url)/reg:GeodeticCRS/gml:identifier/@codeSpace)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(gmd:codeSpace/gco:CharacterString = document($url)//gml:identifier/@codeSpace) or (gmd:codeSpace/gco:CharacterString = document($url)/reg:GeodeticCRS/gml:identifier/@codeSpace)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The body of the srsName must match the codeSpace of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(gmd:code/gco:CharacterString = document($url)//gml:identifier) or          (gmd:code/gco:CharacterString = document($url)/reg:GeodeticCRS/gml:identifier)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(gmd:code/gco:CharacterString = document($url)//gml:identifier) or (gmd:code/gco:CharacterString = document($url)/reg:GeodeticCRS/gml:identifier)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The tail of the srsName ('<xsl:text/>
						<xsl:value-of select="gmd:code/gco:CharacterString"/>
						<xsl:text/>') must match the value of the identifier in the resource.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M72"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M72"/>
	<xsl:template match="@*|node()" priority="-2" mode="M72">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M72"/>
	</xsl:template>
	<!--PATTERN gco-Record_contains_proper_derived_class-->
	<!--RULE -->
	<xsl:template match="gco:Record" priority="1000" mode="M73">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gco:Record"/>
		<xsl:variable name="APath" select="name(*)"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="contains($Record_AbstractDataComponent_Subclasses, $APath)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains($Record_AbstractDataComponent_Subclasses, $APath)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Record must be or derived from type AbstractDataComponent.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M73"/>
	<xsl:template match="@*|node()" priority="-2" mode="M73">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
	</xsl:template>
</xsl:stylesheet>
