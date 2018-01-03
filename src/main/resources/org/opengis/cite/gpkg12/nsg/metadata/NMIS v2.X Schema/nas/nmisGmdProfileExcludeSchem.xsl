<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gss="http://www.isotc211.org/2005/gss" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ism="urn:us:gov:ic:ism" xmlns:nas="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" version="1.0">
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
		<svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="NMIS GMD Profile Exclusion Schematron validation" schemaVersion="">
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
			<svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
			<svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
			<svrl:ns-prefix-in-attribute-values uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" prefix="nas"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Metadata_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">Metadata_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M10"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DataIdentification_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">DataIdentification_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M11"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">AggregateInformation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">AggregateInformation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M12"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Constraints_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">Constraints_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M13"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">SecurityConstraints_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">SecurityConstraints_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M14"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">LegalConstraints_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">LegalConstraints_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M15"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ScopeDescription_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">ScopeDescription_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M16"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MaintenanceInformation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">MaintenanceInformation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M17"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">VectorSpatialRepresentation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">VectorSpatialRepresentation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M18"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">FeatureCatalogueDiscription_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">FeatureCatalogueDiscription_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M19"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Format_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">Format_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M20"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Distributor_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">Distributor_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M21"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DigitalTransferOptions_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">DigitalTransferOptions_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M22"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">NMF_DigitalTransferOptions_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">NMF_DigitalTransferOptions_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M23"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ApplicationSchemaInformation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">ApplicationSchemaInformation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M24"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Extent_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">Extent_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M25"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">BoundingPoint_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">BoundingPoint_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M26"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">GeographicBoundingBox_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">GeographicBoundingBox_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M27"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">BoundingPolygon_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">BoundingPolygon_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M28"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">GeographicDescription_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">GeographicDescription_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M29"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TimePosition_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">TimePosition_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M30"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Citation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">Citation_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M31"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Series_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">Series_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M32"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">OnlineResource_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">OnlineResource_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M33"/>
		</svrl:schematron-output>
	</xsl:template>
	<!--SCHEMATRON PATTERNS-->
	<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">NMIS GMD Profile Exclusion Schematron validation</svrl:text>
	<!--PATTERN Metadata_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M10">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:language)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:language)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata language element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:characterSet)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:characterSet)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata character set element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:portrayalCatalogueInfo)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:portrayalCatalogueInfo)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata portrayal catalogue information association/element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:metadataExtensionInfo)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:metadataExtensionInfo)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata metadata extension information association/element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M10"/>
	<xsl:template match="@*|node()" priority="-2" mode="M10">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
	</xsl:template>
	<!--PATTERN DataIdentification_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="nas:MD_DataIdentification" priority="1000" mode="M11">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_DataIdentification"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:purpose)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:purpose)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification purpose element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:credit)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:credit)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification credit element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:status)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:status)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification status element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:environmentDescription)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:environmentDescription)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification environment description element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:supplementalInformation)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:supplementalInformation)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification supplemental information element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:graphicOverview)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:graphicOverview)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification graphic overview association/element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:resourceSpecificUsage)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:resourceSpecificUsage)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification resource specific usage association/element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M11"/>
	<xsl:template match="@*|node()" priority="-2" mode="M11">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
	</xsl:template>
	<!--PATTERN AggregateInformation_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_AggregateInformation" priority="1000" mode="M12">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_AggregateInformation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:initiativeType)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:initiativeType)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The aggregate information initiative type element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M12"/>
	<xsl:template match="@*|node()" priority="-2" mode="M12">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
	</xsl:template>
	<!--PATTERN Constraints_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Constraints" priority="1000" mode="M13">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Constraints"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:useLimitation)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:useLimitation)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The use limitation constraint element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M13"/>
	<xsl:template match="@*|node()" priority="-2" mode="M13">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
	</xsl:template>
	<!--PATTERN SecurityConstraints_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_SecurityConstraints" priority="1000" mode="M14">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_SecurityConstraints"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:useLimitation)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:useLimitation)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The security constraints use limitation  element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:userNote)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:userNote)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The security constraints user note  element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:handlingDescription)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:handlingDescription)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The security constraints handling description element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M14"/>
	<xsl:template match="@*|node()" priority="-2" mode="M14">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
	</xsl:template>
	<!--PATTERN LegalConstraints_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_LegalConstraints" priority="1000" mode="M15">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_LegalConstraints"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:useLimitation)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:useLimitation)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The security constraints use limitation  element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:otherConstraints)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:otherConstraints)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The legal constraints other constraints element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M15"/>
	<xsl:template match="@*|node()" priority="-2" mode="M15">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
	</xsl:template>
	<!--PATTERN ScopeDescription_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ScopeDescription" priority="1000" mode="M16">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ScopeDescription"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(attributes)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(attributes)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The scope description attributes elment must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(features)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(features)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The scope description  features element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(featureInstances)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(featureInstances)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The scope description feature instances element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(attributeInstances)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(attributeInstances)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The scope description attribute instances element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(dataset)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(dataset)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The scope description dataset element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M16"/>
	<xsl:template match="@*|node()" priority="-2" mode="M16">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
	</xsl:template>
	<!--PATTERN MaintenanceInformation_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_MaintenanceInformation" priority="1000" mode="M17">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_MaintenanceInformation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:userDefinedMaintenanceFrequency)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:userDefinedMaintenanceFrequency)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The user defined maintenance frequency element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:updateScope)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:updateScope)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The update scope element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:updateScopeDescription)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:updateScopeDescription)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The update scope description element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:maintenanceNote)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:maintenanceNote)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The maintenance note element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M17"/>
	<xsl:template match="@*|node()" priority="-2" mode="M17">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
	</xsl:template>
	<!--PATTERN VectorSpatialRepresentation_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_VectorSpatialRepresentation" priority="1000" mode="M18">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_VectorSpatialRepresentation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:geometricObjects)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:geometricObjects)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The geometric objects element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M18"/>
	<xsl:template match="@*|node()" priority="-2" mode="M18">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
	</xsl:template>
	<!--PATTERN FeatureCatalogueDiscription_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_FeatureCatalogueDescription" priority="1000" mode="M19">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_FeatureCatalogueDescription"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:complianceCode)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:complianceCode)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The compliance code element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:language)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:language)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The language element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:featureTypes)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:featureTypes)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The featur types element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M19"/>
	<xsl:template match="@*|node()" priority="-2" mode="M19">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<!--PATTERN Format_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Format" priority="1000" mode="M20">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Format"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:amendmentNumber)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:amendmentNumber)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The format amendment number element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:specification)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:specification)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The format specification element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:fileDecompressionTechnique)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:fileDecompressionTechnique)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The format file decompression technique element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M20"/>
	<xsl:template match="@*|node()" priority="-2" mode="M20">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<!--PATTERN Distributor_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_Distributor" priority="1000" mode="M21">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Distributor"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:distributionOrderProcess)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:distributionOrderProcess)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The distributor distribution order process association/element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M21"/>
	<xsl:template match="@*|node()" priority="-2" mode="M21">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<!--PATTERN DigitalTransferOptions_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="//*" priority="1000" mode="M22">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//*"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:MD_DigitalTransferOptions)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:MD_DigitalTransferOptions)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Instantiations of Digital Transfer Options must use nas:NMF_DigitalTransferOptions.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M22"/>
	<xsl:template match="@*|node()" priority="-2" mode="M22">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<!--PATTERN NMF_DigitalTransferOptions_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="nas:NMF_DigitalTransferOptions" priority="1000" mode="M23">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:NMF_DigitalTransferOptions"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:unitsOfDistribution)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:unitsOfDistribution)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The digital transfer options units of distribution element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:offLine)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:offLine)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The digital transfer options off-line element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M23"/>
	<xsl:template match="@*|node()" priority="-2" mode="M23">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<!--PATTERN ApplicationSchemaInformation_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:MD_ApplicationSchemaInformation" priority="1000" mode="M24">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_ApplicationSchemaInformation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:schemaAscii)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:schemaAscii)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The application schema information specification schema ASCII element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:graphicsFile)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:graphicsFile)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The application schema information specification graphics file element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:softwareDevelopmentFile)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:softwareDevelopmentFile)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The application schema information specification software development file element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:softwareDevelopmentFileFormat)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:softwareDevelopmentFileFormat)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The application schema information specification software development file format element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M24"/>
	<xsl:template match="@*|node()" priority="-2" mode="M24">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<!--PATTERN Extent_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:EX_Extent" priority="1000" mode="M25">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_Extent"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:description)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:description)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The extent description element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M25"/>
	<xsl:template match="@*|node()" priority="-2" mode="M25">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<!--PATTERN BoundingPoint_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="nas:BoundingPoint" priority="1000" mode="M26">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:BoundingPoint"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:extentTypeCode)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:extentTypeCode)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The bounding point extent type code element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M26"/>
	<xsl:template match="@*|node()" priority="-2" mode="M26">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<!--PATTERN GeographicBoundingBox_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:EX_GeographicBoundingBox" priority="1000" mode="M27">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_GeographicBoundingBox"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:extentTypeCode)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:extentTypeCode)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The geographic bounding box extent type code element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M27"/>
	<xsl:template match="@*|node()" priority="-2" mode="M27">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<!--PATTERN BoundingPolygon_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:EX_BoundingPolygon" priority="1000" mode="M28">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_BoundingPolygon"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:extentTypeCode)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:extentTypeCode)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The bounding polygon extent type code element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M28"/>
	<xsl:template match="@*|node()" priority="-2" mode="M28">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<!--PATTERN GeographicDescription_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:EX_GeographicDescription" priority="1000" mode="M29">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_GeographicDescription"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:extentTypeCode)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:extentTypeCode)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The geographic description extent type code element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M29"/>
	<xsl:template match="@*|node()" priority="-2" mode="M29">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<!--PATTERN TimePosition_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gml:timePosition" priority="1000" mode="M30">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gml:timePosition"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(@frame) or (@frame='#ISO-8601')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@frame) or (@frame='#ISO-8601')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position frame attribute must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(@calendarEraName)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@calendarEraName)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The time position calendar era name attribute must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M30"/>
	<xsl:template match="@*|node()" priority="-2" mode="M30">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<!--PATTERN Citation_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Citation" priority="1000" mode="M31">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Citation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:edition)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:edition)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation date edition element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:editionDate)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:editionDate)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation date edition date element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:presentationForm)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:presentationForm)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation date presentation form element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:otherCitationDetails)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:otherCitationDetails)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation date other citation details element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:collectiveTitle)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:collectiveTitle)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation date collective title element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:ISBN)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:ISBN)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation date ISBN element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:ISSN)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:ISSN)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The citation date ISSN element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M31"/>
	<xsl:template match="@*|node()" priority="-2" mode="M31">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
	<!--PATTERN Series_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Series" priority="1000" mode="M32">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Series"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:issueIdentification)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:issueIdentification)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The series issue identification element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:page)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:page)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The series page element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M32"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M32"/>
	<xsl:template match="@*|node()" priority="-2" mode="M32">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M32"/>
	</xsl:template>
	<!--PATTERN OnlineResource_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmd:CI_OnlineResource" priority="1000" mode="M33">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_OnlineResource"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:applicationProfile)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:applicationProfile)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The online resource application profile element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:description)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:description)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The online resource description element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:function)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:function)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The online resource function element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M33"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M33"/>
	<xsl:template match="@*|node()" priority="-2" mode="M33">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M33"/>
	</xsl:template>
</xsl:stylesheet>
