<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gss="http://www.isotc211.org/2005/gss" xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ism="urn:us:gov:ic:ism" xmlns:nas="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" xmlns:reg="http://api.nsgreg.nga.mil/schema/register/1.0" version="1.0">
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
		<svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="NMIS ISO/TS 19139-2 Schematron validation" schemaVersion="">
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
			<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmi" prefix="gmi"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml/3.2" prefix="gml"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
			<svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
			<svrl:ns-prefix-in-attribute-values uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" prefix="nas"/>
			<svrl:ns-prefix-in-attribute-values uri="http://api.nsgreg.nga.mil/schema/register/1.0" prefix="reg"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Operation_identifier_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">Operation_identifier_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M14"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MI_Georectified_must_have_Consistent_check_point_values</xsl:attribute>
				<xsl:attribute name="name">MI_Georectified_must_have_Consistent_check_point_values</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M15"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Georectified_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">Georectified_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M16"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">AccuracyReport_prohibited_when_no_part2NMF</xsl:attribute>
				<xsl:attribute name="name">AccuracyReport_prohibited_when_no_part2NMF</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M17"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Band_must_have_content</xsl:attribute>
				<xsl:attribute name="name">Band_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M18"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Band_units_must_be_present_if_min_and_max_values_present</xsl:attribute>
				<xsl:attribute name="name">Band_units_must_be_present_if_min_and_max_values_present</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M19"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ImageDescription_must_have_content</xsl:attribute>
				<xsl:attribute name="name">ImageDescription_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M20"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">AcquisitionInformation_must_have_content</xsl:attribute>
				<xsl:attribute name="name">AcquisitionInformation_must_have_content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M21"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">BandDefinition_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">BandDefinition_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M22"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ContextCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">ContextCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M23"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">GeometryTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">GeometryTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M24"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ObjectiveTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">ObjectiveTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M25"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">OperationTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">OperationTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M26"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">PolarisationOrientationCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">PolarisationOrientationCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M27"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">PriorityCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">PriorityCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M28"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">SequenceCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">SequenceCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M29"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TransferFunctionTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">TransferFunctionTypeCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M30"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">TriggerCode_Valid_in_Resouce</xsl:attribute>
				<xsl:attribute name="name">TriggerCode_Valid_in_Resouce</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M31"/>
		</svrl:schematron-output>
	</xsl:template>
	<!--SCHEMATRON PATTERNS-->
	<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">NMIS ISO/TS 19139-2 Schematron validation</svrl:text>
	<xsl:param name="NSGREG" select="'http://api.nsgreg.nga.mil'"/>
	<xsl:param name="NMF_part2_profile" select="(//gmd:DQ_DataQuality/gmd:report) or (//gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep) or (//gmd:DQ_DataQuality/gmd:lineage/LI_Lineage/gmd:source)"/>
	<xsl:param name="NMF_part3_profile" select="(//gmi:MI_Georectified) or (//gmi:MI_Georeferenceable) or (//gmd:MD_CoverageDescription) or (//gmi:MI_ImageDescription) or (//gmi:MI_AcquisitionInformation)"/>
	<!--PATTERN Operation_identifier_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmi:MI_Operation" priority="1000" mode="M14">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_Operation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmi:identifier and (count(gmi:identifier)=1)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmi:identifier and (count(gmi:identifier)=1)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
	    Operation must include exactly one identifier element.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M14"/>
	<xsl:template match="@*|node()" priority="-2" mode="M14">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
	</xsl:template>
	<!--PATTERN MI_Georectified_must_have_Consistent_check_point_values-->
	<!--RULE -->
	<xsl:template match="gmi:MI_Georectified" priority="1000" mode="M15">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_Georectified"/>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M15"/>
	<xsl:template match="@*|node()" priority="-2" mode="M15">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
	</xsl:template>
	<!--PATTERN Georectified_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="gmi:MI_Georectified" priority="1000" mode="M16">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_Georectified"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmi:geolocationIndentification)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmi:geolocationIndentification)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The georectified geolocationIdentification element must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M16"/>
	<xsl:template match="@*|node()" priority="-2" mode="M16">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
	</xsl:template>
	<!--PATTERN AccuracyReport_prohibited_when_no_part2NMF-->
	<!--RULE -->
	<xsl:template match="gmi:MI_GCP" priority="1000" mode="M17">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_GCP"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="$NMF_part2_profile or (not($NMF_part2_profile) and not(gmi:accuracyReport))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$NMF_part2_profile or (not($NMF_part2_profile) and not(gmi:accuracyReport))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
				When Part 2 (of the NMF) is not present, the accuracyReport element of MI_GCP is prohibited.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M17"/>
	<xsl:template match="@*|node()" priority="-2" mode="M17">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
	</xsl:template>
	<!--PATTERN Band_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmi:MI_Band" priority="1000" mode="M18">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_Band"/>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M18"/>
	<xsl:template match="@*|node()" priority="-2" mode="M18">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
	</xsl:template>
	<!--PATTERN Band_units_must_be_present_if_min_and_max_values_present-->
	<!--RULE -->
	<xsl:template match="gmi:MI_Band" priority="1000" mode="M19">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_Band"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:maxValue or gmd:minValue or gmd:peakResponse) or ((gmd:maxValue or gmd:minValue or gmd:peakResponse) and (gmd:units/@xlink:href or gmd:units/*))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:maxValue or gmd:minValue or gmd:peakResponse) or ((gmd:maxValue or gmd:minValue or gmd:peakResponse) and (gmd:units/@xlink:href or gmd:units/*))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			  Units are mandatory if maxValue, minValue, or peakResponse is provided.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M19"/>
	<xsl:template match="@*|node()" priority="-2" mode="M19">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<!--PATTERN ImageDescription_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmi:MI_ImageDescription" priority="1000" mode="M20">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_ImageDescription"/>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M20"/>
	<xsl:template match="@*|node()" priority="-2" mode="M20">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<!--PATTERN AcquisitionInformation_must_have_content-->
	<!--RULE -->
	<xsl:template match="gmi:MI_AcquisitionInformation" priority="1000" mode="M21">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_AcquisitionInformation"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        AcquisitionInformation must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M21"/>
	<xsl:template match="@*|node()" priority="-2" mode="M21">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<!--PATTERN BandDefinition_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_BandDefinition" priority="1000" mode="M22">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_BandDefinition"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/BandDefinition')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/BandDefinition')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M22"/>
	<xsl:template match="@*|node()" priority="-2" mode="M22">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<!--PATTERN ContextCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_ContextCode" priority="1000" mode="M23">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_ContextCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/ContextCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/ContextCode')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M23"/>
	<xsl:template match="@*|node()" priority="-2" mode="M23">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<!--PATTERN GeometryTypeCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_GeometryTypeCode" priority="1000" mode="M24">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_GeometryTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/GeometryTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/GeometryTypeCode')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M24"/>
	<xsl:template match="@*|node()" priority="-2" mode="M24">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<!--PATTERN ObjectiveTypeCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_ObjectiveTypeCode" priority="1000" mode="M25">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_ObjectiveTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/ObjectiveTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/ObjectiveTypeCode')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M25"/>
	<xsl:template match="@*|node()" priority="-2" mode="M25">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<!--PATTERN OperationTypeCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_OperationTypeCode" priority="1000" mode="M26">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_OperationTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/OperationTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/OperationTypeCode')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M26"/>
	<xsl:template match="@*|node()" priority="-2" mode="M26">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<!--PATTERN PolarisationOrientationCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_PolarisationOrientationCode" priority="1000" mode="M27">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_PolarisationOrientationCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/PolarisationOrientationCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/PolarisationOrientationCode')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M27"/>
	<xsl:template match="@*|node()" priority="-2" mode="M27">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<!--PATTERN PriorityCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_PriorityCode" priority="1000" mode="M28">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_PriorityCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/PriorityCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/PriorityCode')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M28"/>
	<xsl:template match="@*|node()" priority="-2" mode="M28">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<!--PATTERN SequenceCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_SequenceCode" priority="1000" mode="M29">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_SequenceCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/SequenceCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/SequenceCode')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M29"/>
	<xsl:template match="@*|node()" priority="-2" mode="M29">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<!--PATTERN TransferFunctionTypeCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_TransferFunctionTypeCode" priority="1000" mode="M30">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_TransferFunctionTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/TransferFunctionTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/TransferFunctionTypeCode')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M30"/>
	<xsl:template match="@*|node()" priority="-2" mode="M30">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<!--PATTERN TriggerCode_Valid_in_Resouce-->
	<!--RULE -->
	<xsl:template match="gmi:MI_TriggerCode" priority="1000" mode="M31">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmi:MI_TriggerCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($NSGREG, '/codelist/TriggerCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($NSGREG, '/codelist/TriggerCode')">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M31"/>
	<xsl:template match="@*|node()" priority="-2" mode="M31">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
</xsl:stylesheet>
