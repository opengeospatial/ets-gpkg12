<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gss="http://www.isotc211.org/2005/gss" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:genc="http://api.nsgreg.nga.mil/schema/genc/2.0" xmlns:genc-cmn="http://api.nsgreg.nga.mil/schema/genc/2.0/genc-cmn" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ism="urn:us:gov:ic:ism" xmlns:nas="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:reg="http://api.nsgreg.nga.mil/schema/register/1.0" version="1.0">
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
		<svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="NMIS Schematron validation" schemaVersion="">
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
			<svrl:ns-prefix-in-attribute-values uri="http://api.nsgreg.nga.mil/schema/genc/2.0" prefix="genc"/>
			<svrl:ns-prefix-in-attribute-values uri="http://api.nsgreg.nga.mil/schema/genc/2.0/genc-cmn" prefix="genc-cmn"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
			<svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
			<svrl:ns-prefix-in-attribute-values uri="http://metadata.ces.mil/dse/ns/GSIP/5.0/nas" prefix="nas"/>
			<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmi" prefix="gmi"/>
			<svrl:ns-prefix-in-attribute-values uri="http://api.nsgreg.nga.mil/schema/register/1.0" prefix="reg"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">VersionCheck</xsl:attribute>
				<xsl:attribute name="name">VersionCheck</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M18"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Metadata_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Metadata_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M19"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">NasMetadata_has_correct_element_multiplicities</xsl:attribute>
				<xsl:attribute name="name">NasMetadata_has_correct_element_multiplicities</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M20"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Metadata_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">Metadata_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M21"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">HierarchyLevel_dataset_implies_TopicCategory</xsl:attribute>
				<xsl:attribute name="name">HierarchyLevel_dataset_implies_TopicCategory</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M22"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">HierarchyLevel_dataset_implies_Extent</xsl:attribute>
				<xsl:attribute name="name">HierarchyLevel_dataset_implies_Extent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M23"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MD_Metadata_contact_must_adhere_to_business_rule</xsl:attribute>
				<xsl:attribute name="name">MD_Metadata_contact_must_adhere_to_business_rule</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M24"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">HierarchyLevelName_uses_ScopeAmplificationCode</xsl:attribute>
				<xsl:attribute name="name">HierarchyLevelName_uses_ScopeAmplificationCode</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M25"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MetadataStandardName_uses_MetadataStandardNameCode</xsl:attribute>
				<xsl:attribute name="name">MetadataStandardName_uses_MetadataStandardNameCode</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M26"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MetadataStandardVersion_follows_Pattern</xsl:attribute>
				<xsl:attribute name="name">MetadataStandardVersion_follows_Pattern</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M27"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DataIdentification_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">DataIdentification_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M28"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">NasDataIdentification_has_correct_element_multiplicities</xsl:attribute>
				<xsl:attribute name="name">NasDataIdentification_has_correct_element_multiplicities</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M29"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">NasDataIdentification_must_have_Consistent_LocaleElement_Counts</xsl:attribute>
				<xsl:attribute name="name">NasDataIdentification_must_have_Consistent_LocaleElement_Counts</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M30"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MD_DataIdentificationLanguage_uses_LanguageCode</xsl:attribute>
				<xsl:attribute name="name">MD_DataIdentificationLanguage_uses_LanguageCode</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M31"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DataIdentification_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">DataIdentification_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M32"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ResourceConstraints_MD_Constraints_subclass_multiplicity</xsl:attribute>
				<xsl:attribute name="name">ResourceConstraints_MD_Constraints_subclass_multiplicity</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M33"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ResourceCapcoMarking_corresponds</xsl:attribute>
				<xsl:attribute name="name">ResourceCapcoMarking_corresponds</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M34"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">SecurityConstraints_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">SecurityConstraints_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M35"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">SecurityConstraintsClassificationCode_corresponds</xsl:attribute>
				<xsl:attribute name="name">SecurityConstraintsClassificationCode_corresponds</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M36"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">SecurityConstraintsClassificationSystem_is_US_CAPCO</xsl:attribute>
				<xsl:attribute name="name">SecurityConstraintsClassificationSystem_is_US_CAPCO</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M37"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MetadataConstraints_MD_Constraints_subclass_multiplicity</xsl:attribute>
				<xsl:attribute name="name">MetadataConstraints_MD_Constraints_subclass_multiplicity</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M38"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DataQualityLineage_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">DataQualityLineage_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M39"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DataQuality_LineageAndReport_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">DataQuality_LineageAndReport_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M40"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ScopeDescription_uses_ScopeAmplificationCode</xsl:attribute>
				<xsl:attribute name="name">ScopeDescription_uses_ScopeAmplificationCode</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M41"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">DQ_Element_result_multiplicity</xsl:attribute>
				<xsl:attribute name="name">DQ_Element_result_multiplicity</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M42"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Extent_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">Extent_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M43"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">GeographicElement_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">GeographicElement_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M44"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Extent_must_have_HorizontalGeometry</xsl:attribute>
				<xsl:attribute name="name">Extent_must_have_HorizontalGeometry</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M45"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">BoundingPoint_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:attribute name="name">BoundingPoint_must_not_have_ExcludedContent</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M46"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">GmlPoint_must_be_validly_specified</xsl:attribute>
				<xsl:attribute name="name">GmlPoint_must_be_validly_specified</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M47"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">Telephone_must_have_Content</xsl:attribute>
				<xsl:attribute name="name">Telephone_must_have_Content</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M48"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">VoiceTelephoneNumber_Internationalized</xsl:attribute>
				<xsl:attribute name="name">VoiceTelephoneNumber_Internationalized</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M49"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">FacsimileTelephoneNumber_Internationalized</xsl:attribute>
				<xsl:attribute name="name">FacsimileTelephoneNumber_Internationalized</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M50"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">CRCTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">CRCTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M51"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">MetadataStandardNameCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">MetadataStandardNameCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M52"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ResourceCategoryCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">ResourceCategoryCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M53"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">RevisionTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">RevisionTypeCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M54"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">ScopeAmplificationCode_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">ScopeAmplificationCode_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M55"/>
			<svrl:active-pattern>
				<xsl:attribute name="document"><!--<xsl:value-of select="document-uri(/)"/>--></xsl:attribute>
				<xsl:attribute name="id">PointSrsName_Valid_in_Resource</xsl:attribute>
				<xsl:attribute name="name">PointSrsName_Valid_in_Resource</xsl:attribute>
				<xsl:apply-templates/>
			</svrl:active-pattern>
			<xsl:apply-templates select="/" mode="M56"/>
		</svrl:schematron-output>
	</xsl:template>
	<!--SCHEMATRON PATTERNS-->
	<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">NMIS Schematron validation</svrl:text>
	<xsl:param name="GSIP" select="'http://metadata.ces.mil/mdr/ns/GSIP'"/>
	<xsl:param name="NSGREG" select="'http://api.nsgreg.nga.mil'"/>
	<xsl:param name="scope_content" select="(//gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset') or (//gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='series')"/>
	<xsl:param name="NMF_part2_profile" select="(//gmd:DQ_DataQuality/gmd:report) or (//gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep) or (//gmd:DQ_DataQuality/gmd:lineage/LI_Lineage/gmd:source)"/>
	<xsl:param name="NMF_part3_profile" select="(//gmi:MI_Georectified) or (//gmi:MI_Georeferenceable) or (//gmd:MD_CoverageDescription) or (//gmi:MI_ImageDescription) or (//gmi:MI_AcquisitionInformation)"/>
	<!--PATTERN VersionCheck-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M18">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(gmd:metadataStandardVersion/*) and                          contains(gmd:metadataStandardVersion, '2.2')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(gmd:metadataStandardVersion/*) and contains(gmd:metadataStandardVersion, '2.2')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
      NMIS version must be 2.2 </svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M18"/>
	<xsl:template match="@*|node()" priority="-2" mode="M18">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
	</xsl:template>
	<!--PATTERN Metadata_must_have_Content-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M19">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:fileIdentifier) or ((gmd:fileIdentifier/gco:CharacterString) and (string-length(normalize-space(gmd:fileIdentifier/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:fileIdentifier) or ((gmd:fileIdentifier/gco:CharacterString) and (string-length(normalize-space(gmd:fileIdentifier/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata file identifier, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:hierarchyLevel) or (gmd:hierarchyLevel/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:hierarchyLevel) or (gmd:hierarchyLevel/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata hierarchy level, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:hierarchyLevelName) or (gmd:hierarchyLevelName/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:hierarchyLevelName) or (gmd:hierarchyLevelName/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata hierarchy level name, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(gmd:contact/@xlink:href) or (gmd:contact/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(gmd:contact/@xlink:href) or (gmd:contact/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata contact must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:dateStamp/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:dateStamp/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata date stamp must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:metadataStandardName) or (gmd:metadataStandardName/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:metadataStandardName) or (gmd:metadataStandardName/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata metadata standard name, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:metadataStandardVersion) or ((gmd:metadataStandardVersion/nas:MetadataStandardVersion) and (string-length(normalize-space(gmd:metadataStandardVersion/nas:MetadataStandardVersion)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:metadataStandardVersion) or ((gmd:metadataStandardVersion/nas:MetadataStandardVersion) and (string-length(normalize-space(gmd:metadataStandardVersion/nas:MetadataStandardVersion)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata metadata standard version, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:locale) or (gmd:locale/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:locale) or (gmd:locale/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata locale, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:applicationSchemaInfo) or (gmd:applicationSchemaInfo/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:applicationSchemaInfo) or (gmd:applicationSchemaInfo/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata application schema information association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:dataQualityInfo) or (gmd:dataQualityInfo/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:dataQualityInfo) or (gmd:dataQualityInfo/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata data quality information association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:identificationInfo/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:identificationInfo/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata identification information association/element must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:metadataConstraints) or (gmd:metadataConstraints/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:metadataConstraints) or (gmd:metadataConstraints/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata constraints association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:referenceSystemInfo) or (gmd:referenceSystemInfo/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:referenceSystemInfo) or (gmd:referenceSystemInfo/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata reference system information association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M19"/>
	<xsl:template match="@*|node()" priority="-2" mode="M19">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
	</xsl:template>
	<!--PATTERN NasMetadata_has_correct_element_multiplicities-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M20">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(gmd:hierarchyLevel/* and (count(gmd:hierarchyLevel) = 1)) and (gmd:hierarchyLevelName/* and (count(gmd:hierarchyLevelName) = 1))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(gmd:hierarchyLevel/* and (count(gmd:hierarchyLevel) = 1)) and (gmd:hierarchyLevelName/* and (count(gmd:hierarchyLevelName) = 1))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The resource metadata must include exactly one hierarchy level and hierarchy level name, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:metadataStandardName/* and gmd:metadataStandardVersion/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:metadataStandardName/* and gmd:metadataStandardVersion/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The resource metadata must include a metadata standard name and version, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:applicationSchemaInfo) or gmd:applicationSchemaInfo/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:applicationSchemaInfo) or gmd:applicationSchemaInfo/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The application schema information association/element, if present, must have content.</svrl:text>
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
			The resource metadata must include either 1 or 2 resource constraints, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:identificationInfo/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:identificationInfo/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The identification information association/element must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:referenceSystemInfo) or gmd:referenceSystemInfo/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:referenceSystemInfo) or gmd:referenceSystemInfo/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The reference system information association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:dataQualityInfo) or gmd:dataQualityInfo/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:dataQualityInfo) or gmd:dataQualityInfo/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The data quality information association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:parentIdentifier) or ((gmd:parentIdentifier/gco:CharacterString) and (string-length(normalize-space(gmd:parentIdentifier/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:parentIdentifier) or ((gmd:parentIdentifier/gco:CharacterString) and (string-length(normalize-space(gmd:parentIdentifier/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The metadata parent identifier, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:dataSetURI) or ((gmd:dataSetURI/gco:CharacterString) and (string-length(normalize-space(gmd:dataSetURI/gco:CharacterString)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:dataSetURI) or ((gmd:dataSetURI/gco:CharacterString) and (string-length(normalize-space(gmd:dataSetURI/gco:CharacterString)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The metadata data set URI, if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:spatialRepresentationInfo) or (gmd:spatialRepresentationInfo/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:spatialRepresentationInfo) or (gmd:spatialRepresentationInfo/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The metadata spatial representation information, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:contentInfo) or (gmd:contentInfo/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:contentInfo) or (gmd:contentInfo/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The metadata content information, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:distributionInfo) or (gmd:distributionInfo/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:distributionInfo) or (gmd:distributionInfo/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The metadata distribution information, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:metadataMaintenance) or (gmd:metadataMaintenance/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:metadataMaintenance) or (gmd:metadataMaintenance/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The metadata maintenance, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmi:acquisitionInformation) or (gmi:acquisitionInformation/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmi:acquisitionInformation) or (gmi:acquisitionInformation/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			The metadata acquisition information, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M20"/>
	<xsl:template match="@*|node()" priority="-2" mode="M20">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
	</xsl:template>
	<!--PATTERN Metadata_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M21">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M21"/>
	<xsl:template match="@*|node()" priority="-2" mode="M21">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
	</xsl:template>
	<!--PATTERN HierarchyLevel_dataset_implies_TopicCategory-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M22">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') or ((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:identificationInfo/nas:MD_DataIdentification/gmd:topicCategory/*))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') or ((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:identificationInfo/nas:MD_DataIdentification/gmd:topicCategory/*))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata hierarchy level is 'dataset' therefore topic categories must be specified.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M22"/>
	<xsl:template match="@*|node()" priority="-2" mode="M22">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
	</xsl:template>
	<!--PATTERN HierarchyLevel_dataset_implies_Extent-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M23">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:referenceSystemInfo/*)) or          (((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:referenceSystemInfo/*))         and (gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox or         gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/nas:BoundingPoint))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:referenceSystemInfo/*)) or (((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset') and (gmd:referenceSystemInfo/*)) and (gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox or gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/nas:BoundingPoint))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata hierarchy level is 'dataset' and there is a spatial reference system therefore the extent must be specified at least as either a bounding box or a point.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series') and (gmd:referenceSystemInfo/*)) or          (((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series') and (gmd:referenceSystemInfo/*))         and (gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox or         gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series') and (gmd:referenceSystemInfo/*)) or (((gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series') and (gmd:referenceSystemInfo/*)) and (gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox or gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata hierarchy level is 'series' and there is a spatial reference system therefore the extent must be specified at least as either a bounding box or a polygon.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M23"/>
	<xsl:template match="@*|node()" priority="-2" mode="M23">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
	</xsl:template>
	<!--PATTERN MD_Metadata_contact_must_adhere_to_business_rule-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M24">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(count(gmd:contact) &lt;2) or (gmd:contact[position()=1]/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(count(gmd:contact) &lt;2) or (gmd:contact[position()=1]/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        When multiple contact elements are present, the first element shall use the role code "pointOfcontact"</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M24"/>
	<xsl:template match="@*|node()" priority="-2" mode="M24">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
	</xsl:template>
	<!--PATTERN HierarchyLevelName_uses_ScopeAmplificationCode-->
	<!--RULE -->
	<xsl:template match="gmd:hierarchyLevelName" priority="1000" mode="M25">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:hierarchyLevelName"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="nas:ScopeAmplificationCode"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nas:ScopeAmplificationCode">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        All hierarchy level names shall have a scope amplification code as their content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M25"/>
	<xsl:template match="@*|node()" priority="-2" mode="M25">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
	</xsl:template>
	<!--PATTERN MetadataStandardName_uses_MetadataStandardNameCode-->
	<!--RULE -->
	<xsl:template match="gmd:metadataStandardName" priority="1000" mode="M26">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:metadataStandardName"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="nas:MetadataStandardNameCode"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nas:MetadataStandardNameCode">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        All metadata standard names shall have a metadata standard name code as their content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M26"/>
	<xsl:template match="@*|node()" priority="-2" mode="M26">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
	</xsl:template>
	<!--PATTERN MetadataStandardVersion_follows_Pattern-->
	<!--RULE -->
	<xsl:template match="gmd:metadataStandardVersion" priority="1000" mode="M27">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:metadataStandardVersion"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="nas:MetadataStandardVersion"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nas:MetadataStandardVersion">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        All metadata standard version content shall be constrained to the Major.Minor.Corrigendum pattern.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M27"/>
	<xsl:template match="@*|node()" priority="-2" mode="M27">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
	</xsl:template>
	<!--PATTERN DataIdentification_must_have_Content-->
	<!--RULE -->
	<xsl:template match="nas:MD_DataIdentification" priority="1000" mode="M28">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_DataIdentification"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:citation/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:citation/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification citation must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:abstract/gco:CharacterString and (string-length(normalize-space(gmd:abstract/gco:CharacterString)) &gt; 0)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:abstract/gco:CharacterString and (string-length(normalize-space(gmd:abstract/gco:CharacterString)) &gt; 0)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification abstract must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:pointOfContact/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:pointOfContact/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification point of contact must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:spatialRepresentationType) or (gmd:spatialRepresentationType/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:spatialRepresentationType) or (gmd:spatialRepresentationType/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification spatial representation type, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:spatialResolution) or (gmd:spatialResolution/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:spatialResolution) or (gmd:spatialResolution/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification spatial resolution, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:language/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:language/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification language must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:characterSet/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:characterSet/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification character set must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:topicCategory) or (gmd:topicCategory/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:topicCategory) or (gmd:topicCategory/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification topic category, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:extent) or (gmd:extent/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:extent) or (gmd:extent/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification extent must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:aggregationInfo) or (gmd:aggregationInfo/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:aggregationInfo) or (gmd:aggregationInfo/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification aggregation information association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:descriptiveKeywords) or (gmd:descriptiveKeywords/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:descriptiveKeywords) or (gmd:descriptiveKeywords/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification descriptive keywords association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:resourceConstraints) or (gmd:resourceConstraints/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:resourceConstraints) or (gmd:resourceConstraints/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification resource constraints association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:resourceFormat) or (gmd:resourceFormat/*)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:resourceFormat) or (gmd:resourceFormat/*)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification resource format association/element, if present, must have content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M28"/>
	<xsl:template match="@*|node()" priority="-2" mode="M28">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
	</xsl:template>
	<!--PATTERN NasDataIdentification_has_correct_element_multiplicities-->
	<!--RULE -->
	<xsl:template match="nas:MD_DataIdentification" priority="1000" mode="M29">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_DataIdentification"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:pointOfContact/* and gmd:descriptiveKeywords/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:pointOfContact/* and gmd:descriptiveKeywords/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification must include a point of contact and descriptive keywords, with content.</svrl:text>
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
        The data identification must include either 1 or 2 resource constraints, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:characterSet/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:characterSet/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification must include at least one character set, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="nas:languageCountry/*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nas:languageCountry/*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The data identification must include at least one language country, with content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M29"/>
	<xsl:template match="@*|node()" priority="-2" mode="M29">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
	</xsl:template>
	<!--PATTERN NasDataIdentification_must_have_Consistent_LocaleElement_Counts-->
	<!--RULE -->
	<xsl:template match="nas:MD_DataIdentification" priority="1000" mode="M30">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_DataIdentification"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="count(gmd:language) = count(gmd:characterSet)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(gmd:language) = count(gmd:characterSet)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The sets of language codes and character encodings must have the same number of elements.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="count(gmd:language) = count(nas:languageCountry)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(gmd:language) = count(nas:languageCountry)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The sets of language codes and countries must have the same number of elements.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M30"/>
	<xsl:template match="@*|node()" priority="-2" mode="M30">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M30"/>
	</xsl:template>
	<!--PATTERN MD_DataIdentificationLanguage_uses_LanguageCode-->
	<!--RULE -->
	<xsl:template match="nas:MD_DataIdentification/gmd:language" priority="1000" mode="M31">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_DataIdentification/gmd:language"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:LanguageCode"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:LanguageCode">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			  All MD_DataIdentification language descriptions shall have a language code as their content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M31"/>
	<xsl:template match="@*|node()" priority="-2" mode="M31">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M31"/>
	</xsl:template>
	<!--PATTERN DataIdentification_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="nas:MD_DataIdentification" priority="1000" mode="M32">
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M32"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M32"/>
	<xsl:template match="@*|node()" priority="-2" mode="M32">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M32"/>
	</xsl:template>
	<!--PATTERN ResourceConstraints_MD_Constraints_subclass_multiplicity-->
	<!--RULE -->
	<xsl:template match="nas:MD_DataIdentification" priority="1000" mode="M33">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_DataIdentification"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:resourceConstraints/gmd:MD_LegalConstraints/* or gmd:resourceConstraints/nas:MD_SecurityConstraints/*) or ((gmd:resourceConstraints/gmd:MD_LegalConstraints/* or gmd:resourceConstraints/nas:MD_SecurityConstraints/*) and (count(gmd:resourceConstraints/gmd:MD_LegalConstraints) &lt; 2) and (count(gmd:resourceConstraints/nas:MD_SecurityConstraints) &lt; 2))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:resourceConstraints/gmd:MD_LegalConstraints/* or gmd:resourceConstraints/nas:MD_SecurityConstraints/*) or ((gmd:resourceConstraints/gmd:MD_LegalConstraints/* or gmd:resourceConstraints/nas:MD_SecurityConstraints/*) and (count(gmd:resourceConstraints/gmd:MD_LegalConstraints) &lt; 2) and (count(gmd:resourceConstraints/nas:MD_SecurityConstraints) &lt; 2))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
				Sub-classes of MD_Constraints can each only have one instance.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M33"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M33"/>
	<xsl:template match="@*|node()" priority="-2" mode="M33">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M33"/>
	</xsl:template>
	<!--PATTERN ResourceCapcoMarking_corresponds-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M34">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@ism:createDate = gmd:dateStamp/gco:Date"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:createDate = gmd:dateStamp/gco:Date">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata root must be ism-marked with the same creation date as that specified in the metadata date stamp.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@ism:classification = gmd:metadataConstraints/nas:MD_SecurityConstraints/nas:capcoMarking/@ism:classification"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:classification = gmd:metadataConstraints/nas:MD_SecurityConstraints/nas:capcoMarking/@ism:classification">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata root must be ism-marked with the same classification as that specified in the metadata constraints.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@ism:ownerProducer = gmd:metadataConstraints/nas:MD_SecurityConstraints/nas:capcoMarking/@ism:ownerProducer"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:ownerProducer = gmd:metadataConstraints/nas:MD_SecurityConstraints/nas:capcoMarking/@ism:ownerProducer">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The metadata root must be ism-marked with the same owner/producer as that specified in the metadata constraints.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M34"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M34"/>
	<xsl:template match="@*|node()" priority="-2" mode="M34">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M34"/>
	</xsl:template>
	<!--PATTERN SecurityConstraints_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="nas:MD_SecurityConstraints" priority="1000" mode="M35">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_SecurityConstraints"/>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M35"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M35"/>
	<xsl:template match="@*|node()" priority="-2" mode="M35">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M35"/>
	</xsl:template>
	<!--PATTERN SecurityConstraintsClassificationCode_corresponds-->
	<!--RULE -->
	<xsl:template match="nas:MD_SecurityConstraints" priority="1000" mode="M36">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_SecurityConstraints"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(not(nas:capcoMarking/@ism:classification = 'U')) or ((nas:capcoMarking/@ism:classification = 'U') and (gmd:classification/gmd:MD_ClassificationCode/@codeListValue = 'unclassified'))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(not(nas:capcoMarking/@ism:classification = 'U')) or ((nas:capcoMarking/@ism:classification = 'U') and (gmd:classification/gmd:MD_ClassificationCode/@codeListValue = 'unclassified'))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The ISO 19115 security constraints classification must match the ism:classification, respectively 'unclassified' and 'U'.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(nas:capcoMarking/@ism:classification = 'U') or (not(nas:capcoMarking/@ism:classification = 'U') and (gmd:classification/gmd:MD_ClassificationCode/@codeListValue = 'classified'))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(nas:capcoMarking/@ism:classification = 'U') or (not(nas:capcoMarking/@ism:classification = 'U') and (gmd:classification/gmd:MD_ClassificationCode/@codeListValue = 'classified'))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The ISO 19115 security constraints classification must match the ism:classification, respectively 'classified' and other than 'U'.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M36"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M36"/>
	<xsl:template match="@*|node()" priority="-2" mode="M36">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M36"/>
	</xsl:template>
	<!--PATTERN SecurityConstraintsClassificationSystem_is_US_CAPCO-->
	<!--RULE -->
	<xsl:template match="nas:MD_SecurityConstraints/gmd:classificationSystem" priority="1000" mode="M37">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_SecurityConstraints/gmd:classificationSystem"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="nas:ClassificationSystem"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nas:ClassificationSystem">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The security constraints classification system content shall be constrained to the restricted-value 'US CAPCO' pattern.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M37"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M37"/>
	<xsl:template match="@*|node()" priority="-2" mode="M37">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M37"/>
	</xsl:template>
	<!--PATTERN MetadataConstraints_MD_Constraints_subclass_multiplicity-->
	<!--RULE -->
	<xsl:template match="gmd:metadataConstraints" priority="1000" mode="M38">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:metadataConstraints"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:MD_LegalConstraints/* or nas:MD_SecurityConstraints/*) or ((gmd:MD_LegalConstraints/* or nas:MD_SecurityConstraints/*) and (count(gmd:MD_LegalConstraints) &lt; 2) and (count(nas:MD_SecurityConstraints) &lt; 2))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:MD_LegalConstraints/* or nas:MD_SecurityConstraints/*) or ((gmd:MD_LegalConstraints/* or nas:MD_SecurityConstraints/*) and (count(gmd:MD_LegalConstraints) &lt; 2) and (count(nas:MD_SecurityConstraints) &lt; 2))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
				Sub-classes of MD_Constraints can each only have one instance.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M38"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M38"/>
	<xsl:template match="@*|node()" priority="-2" mode="M38">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M38"/>
	</xsl:template>
	<!--PATTERN DataQualityLineage_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmd:DQ_DataQuality" priority="1000" mode="M39">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:DQ_DataQuality"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="($NMF_part2_profile or (not($NMF_part2_profile) and (not($scope_content) or ($scope_content and (gmd:lineage/gmd:LI_Lineage/gmd:statement/gco:CharacterString) ) )))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($NMF_part2_profile or (not($NMF_part2_profile) and (not($scope_content) or ($scope_content and (gmd:lineage/gmd:LI_Lineage/gmd:statement/gco:CharacterString) ) )))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Profiling the NMF Part 1 Core, the data quality scope is 'dataset' or 'series', however no lineage statement is specified.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M39"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M39"/>
	<xsl:template match="@*|node()" priority="-2" mode="M39">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M39"/>
	</xsl:template>
	<!--PATTERN DataQuality_LineageAndReport_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmd:DQ_DataQuality" priority="1000" mode="M40">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:DQ_DataQuality"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not($NMF_part2_profile) or ($NMF_part2_profile and (not($scope_content) or ($scope_content and (gmd:report/* or ((count(gmd:lineage/gmd:LI_Lineage/gmd:source/*) &gt; 0) or (count(gmd:lineage/gmd:LI_Lineage/gmd:processStep/*) &gt; 0) or gmd:lineage/gmd:LI_Lineage/gmd:statement))) ))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($NMF_part2_profile) or ($NMF_part2_profile and (not($scope_content) or ($scope_content and (gmd:report/* or ((count(gmd:lineage/gmd:LI_Lineage/gmd:source/*) &gt; 0) or (count(gmd:lineage/gmd:LI_Lineage/gmd:processStep/*) &gt; 0) or gmd:lineage/gmd:LI_Lineage/gmd:statement))) ))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
			  Profiling the NMF Part 2, the data quality scope is 'dataset' or 'series' and there is no specified report information and no lineage information (source or process step information, and no lineage statement is specified).
			</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M40"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M40"/>
	<xsl:template match="@*|node()" priority="-2" mode="M40">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M40"/>
	</xsl:template>
	<!--PATTERN ScopeDescription_uses_ScopeAmplificationCode-->
	<!--RULE -->
	<xsl:template match="gmd:levelDescription" priority="1000" mode="M41">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:levelDescription"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:MD_ScopeDescription/gmd:other/nas:ScopeAmplificationCode"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:MD_ScopeDescription/gmd:other/nas:ScopeAmplificationCode">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        All scope description other elements shall have a scope amplification code as their content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M41"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M41"/>
	<xsl:template match="@*|node()" priority="-2" mode="M41">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M41"/>
	</xsl:template>
	<!--PATTERN DQ_Element_result_multiplicity-->
	<!--RULE -->
	<xsl:template match="gmd:DQ_DataQuality/gmd:report/*" priority="1000" mode="M42">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:DQ_DataQuality/gmd:report/*"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:result/gmd:DQ_ConformanceResult/* or gmd:result/gmd:DQ_QuantitativeResult/*) or ((gmd:result/gmd:DQ_ConformmanceResult/* or gmd:result/gmd:DQ_QuantitativeResult/*) and (count(gmd:result/gmd:DQ_ConformanceResult) &lt; 2) and (count(gmd:result/gmd:DQ_QuantitativeResult) &lt; 2))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:result/gmd:DQ_ConformanceResult/* or gmd:result/gmd:DQ_QuantitativeResult/*) or ((gmd:result/gmd:DQ_ConformmanceResult/* or gmd:result/gmd:DQ_QuantitativeResult/*) and (count(gmd:result/gmd:DQ_ConformanceResult) &lt; 2) and (count(gmd:result/gmd:DQ_QuantitativeResult) &lt; 2))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
				Sub-classes of DQ_Result can each only have one instance.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M42"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M42"/>
	<xsl:template match="@*|node()" priority="-2" mode="M42">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M42"/>
	</xsl:template>
	<!--PATTERN Extent_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmd:EX_Extent" priority="1000" mode="M43">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:EX_Extent"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:geographicElement or gmd:temporalElement or gmd:verticalElement"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:geographicElement or gmd:temporalElement or gmd:verticalElement">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The spatial extent, if present, fails to specify at least one geographic element, temporal element or vertical element.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M43"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M43"/>
	<xsl:template match="@*|node()" priority="-2" mode="M43">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M43"/>
	</xsl:template>
	<!--PATTERN GeographicElement_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gmd:geographicElement" priority="1000" mode="M44">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:geographicElement"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="gmd:EX_GeographicBoundingBox or gmd:EX_BoundingPolygon or nas:BoundingPoint or gmd:EX_GeographicDescription"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gmd:EX_GeographicBoundingBox or gmd:EX_BoundingPolygon or nas:BoundingPoint or gmd:EX_GeographicDescription">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The geographic element, if present, must specify a geographic bounding box, bounding polygon, bounding point or description.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M44"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M44"/>
	<xsl:template match="@*|node()" priority="-2" mode="M44">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M44"/>
	</xsl:template>
	<!--PATTERN Extent_must_have_HorizontalGeometry-->
	<!--RULE -->
	<xsl:template match="nas:MD_Metadata" priority="1000" mode="M45">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MD_Metadata"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:referenceSystemInfo/*) or (gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox or          gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon or          gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/nas:BoundingPoint)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:referenceSystemInfo/*) or (gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox or gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon or gmd:identificationInfo/nas:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/nas:BoundingPoint)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The spatial extent, if present along with a spatial reference system, fails to specify at least one geographic bounding box, polygon or point.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M45"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M45"/>
	<xsl:template match="@*|node()" priority="-2" mode="M45">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M45"/>
	</xsl:template>
	<!--PATTERN BoundingPoint_must_not_have_ExcludedContent-->
	<!--RULE -->
	<xsl:template match="nas:BoundingPoint" priority="1000" mode="M46">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:BoundingPoint"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:extentTypeCode)"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:extentTypeCode)">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The bounding point extent type code must not be used.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M46"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M46"/>
	<xsl:template match="@*|node()" priority="-2" mode="M46">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M46"/>
	</xsl:template>
	<!--PATTERN GmlPoint_must_be_validly_specified-->
	<!--RULE -->
	<xsl:template match="gml:Point" priority="1000" mode="M47">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gml:Point"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@srsName"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@srsName">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The GML Point must have a specified CRS.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M47"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M47"/>
	<xsl:template match="@*|node()" priority="-2" mode="M47">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M47"/>
	</xsl:template>
	<!--PATTERN Telephone_must_have_Content-->
	<!--RULE -->
	<xsl:template match="gmd:CI_Telephone" priority="1000" mode="M48">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:CI_Telephone"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="*"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        Telesphone must have content</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:voice) or ((gmd:voice/nas:TelephoneNumber) and (string-length(normalize-space(gmd:voice/nas:TelephoneNumber)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:voice) or ((gmd:voice/nas:TelephoneNumber) and (string-length(normalize-space(gmd:voice/nas:TelephoneNumber)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The telephone voice(s), if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(gmd:facsimile) or ((gmd:facsimile/nas:TelephoneNumber) and (string-length(normalize-space(gmd:facsimile/nas:TelephoneNumber)) &gt; 0))"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(gmd:facsimile) or ((gmd:facsimile/nas:TelephoneNumber) and (string-length(normalize-space(gmd:facsimile/nas:TelephoneNumber)) &gt; 0))">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The telephone facsimile(s), if present, must have non-empty string content.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M48"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M48"/>
	<xsl:template match="@*|node()" priority="-2" mode="M48">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M48"/>
	</xsl:template>
	<!--PATTERN VoiceTelephoneNumber_Internationalized-->
	<!--RULE -->
	<xsl:template match="gmd:voice" priority="1000" mode="M49">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:voice"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="nas:TelephoneNumber"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nas:TelephoneNumber">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        All voice telephone number content shall be constrained to the internationalized telephone number pattern.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M49"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M49"/>
	<xsl:template match="@*|node()" priority="-2" mode="M49">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M49"/>
	</xsl:template>
	<!--PATTERN FacsimileTelephoneNumber_Internationalized-->
	<!--RULE -->
	<xsl:template match="gmd:facsimile" priority="1000" mode="M50">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:facsimile"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="nas:TelephoneNumber"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nas:TelephoneNumber">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        All facsimile telephone number content shall be constrained to the internationalized telephone number pattern.</svrl:text>
				</svrl:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M50"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M50"/>
	<xsl:template match="@*|node()" priority="-2" mode="M50">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M50"/>
	</xsl:template>
	<!--PATTERN CRCTypeCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="nas:CRCTypeCode" priority="1000" mode="M51">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:CRCTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/CRCTypeCode') or          @codeList = concat($NSGREG, '/codelist/CRCTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/CRCTypeCode') or @codeList = concat($NSGREG, '/codelist/CRCTypeCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate DSE resource.</svrl:text>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M51"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M51"/>
	<xsl:template match="@*|node()" priority="-2" mode="M51">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M51"/>
	</xsl:template>
	<!--PATTERN MetadataStandardNameCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="nas:MetadataStandardNameCode" priority="1000" mode="M52">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:MetadataStandardNameCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/MetadataStandardNameCode') or          @codeList = concat($NSGREG, '/codelist/MetadataStandardNameCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/MetadataStandardNameCode') or @codeList = concat($NSGREG, '/codelist/MetadataStandardNameCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate DSE resource.</svrl:text>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M52"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M52"/>
	<xsl:template match="@*|node()" priority="-2" mode="M52">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M52"/>
	</xsl:template>
	<!--PATTERN ResourceCategoryCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="nas:ResourceCategoryCode" priority="1000" mode="M53">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:ResourceCategoryCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/ResourceCategoryCode') or          @codeList = concat($NSGREG, '/codelist/ResourceCategoryCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/ResourceCategoryCode') or @codeList = concat($NSGREG, '/codelist/ResourceCategoryCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate DSE resource.</svrl:text>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M53"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M53"/>
	<xsl:template match="@*|node()" priority="-2" mode="M53">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M53"/>
	</xsl:template>
	<!--PATTERN RevisionTypeCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="nas:RevisionTypeCode" priority="1000" mode="M54">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:RevisionTypeCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/RevisionTypeCode') or          @codeList = concat($NSGREG, '/codelist/RevisionTypeCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/RevisionTypeCode') or @codeList = concat($NSGREG, '/codelist/RevisionTypeCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate DSE resource.</svrl:text>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M54"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M54"/>
	<xsl:template match="@*|node()" priority="-2" mode="M54">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M54"/>
	</xsl:template>
	<!--PATTERN ScopeAmplificationCode_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="nas:ScopeAmplificationCode" priority="1000" mode="M55">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nas:ScopeAmplificationCode"/>
		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@codeList = concat($GSIP, '/codelist/ScopeAmplificationCode') or          @codeList = concat($NSGREG, '/codelist/ScopeAmplificationCode')"/>
			<xsl:otherwise>
				<svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@codeList = concat($GSIP, '/codelist/ScopeAmplificationCode') or @codeList = concat($NSGREG, '/codelist/ScopeAmplificationCode')">
					<xsl:attribute name="location"><xsl:apply-templates select="." mode="schematron-select-full-path"/></xsl:attribute>
					<svrl:text>
        The code list must reference an NMF-appropriate DSE resource.</svrl:text>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M55"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M55"/>
	<xsl:template match="@*|node()" priority="-2" mode="M55">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M55"/>
	</xsl:template>
	<!--PATTERN PointSrsName_Valid_in_Resource-->
	<!--RULE -->
	<xsl:template match="gml:Point" priority="1000" mode="M56">
		<svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gml:Point"/>
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
        The specified srsName must reference a net-accessible resource in the DSE GSIP Governance Namespace.</svrl:text>
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
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M56"/>
	</xsl:template>
	<xsl:template match="text()" priority="-1" mode="M56"/>
	<xsl:template match="@*|node()" priority="-2" mode="M56">
		<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M56"/>
	</xsl:template>
</xsl:stylesheet>
