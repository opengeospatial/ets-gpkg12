package org.opengis.cite.gpkg12;

/**
 * Defines keys used to access localized messages for assertion errors. The messages are
 * stored in Properties files that are encoded in ISO-8859-1 (Latin-1). For some languages
 * the {@code native2ascii} tool must be used to process the files and produce escaped
 * Unicode characters.
 */
public class ErrorMessageKeys {

	public static final String NOT_SCHEMA_VALID = "NotSchemaValid";

	public static final String EMPTY_STRING = "EmptyString";

	public static final String XPATH_RESULT = "XPathResult";

	public static final String NAMESPACE_NAME = "NamespaceName";

	public static final String LOCAL_NAME = "LocalName";

	public static final String XML_ERROR = "XMLError";

	public static final String XPATH_ERROR = "XPathError";

	public static final String MISSING_INFOSET_ITEM = "MissingInfosetItem";

	public static final String UNEXPECTED_STATUS = "UnexpectedStatus";

	public static final String UNEXPECTED_MEDIA_TYPE = "UnexpectedMediaType";

	public static final String MISSING_ENTITY = "MissingEntity";

	public static final String CONFORMANCE_CLASS_DISABLED = "ConformanceClassDisabled";

	public static final String CONFORMANCE_CLASS_NOT_USED = "ConformanceClassNotUsed";

	public static final String INVALID_HEADER_STR = "InvalidHeaderString";

	public static final String UNKNOWN_APP_ID = "UnknownApplicationId";

	public static final String UNKNOWN_USER_VERSION = "UnknownUserVersion";

	public static final String INVALID_SUFFIX = "InvalidSuffix";

	public static final String INVALID_COLUMN_DEFINITION = "InvalidColumnDefinition";

	public static final String INVALID_DATA_TYPE = "InvalidDataType";

	public static final String MISSING_COLUMN = "MissingColumn";

	public static final String UNEXPECTED_COLUMN = "UnexpectedColumn";

	public static final String UNEXPECTED_VALUE = "UnexpectedValue";

	public static final String ILLEGAL_VALUE = "IllegalValue";

	public static final String MISSING_REFERENCE = "MissingReference";

	public static final String MISSING_ROW = "MissingRow";

	public static final String NON_UNIQUE_VALUE = "NonUniqueValue";

	public static final String PRAGMA_INTEGRITY_CHECK_NOT_OK = "PragmaIntegrityCheckNotOk";

	public static final String INVALID_FOREIGN_KEY = "InvalidForeignKey";

	public static final String NO_SQL_ACCESS = "NoSqlAccess";

	public static final String SQLITE_OMIT_OPTIONS = "SqliteOmitOptions";

	public static final String TABLE_DEFINITION_INVALID = "TableDefinitionInvalid";

	public static final String MISSING_TABLE = "MissingTable";

	public static final String TABLE_NO_PK = "TableNoPK";

	public static final String TABLE_PK_NOT_UNIQUE = "TablePKNotUnique";

	public static final String NO_GEOGRAPHIC_SRS = "NoGeographicSrs";

	public static final String NO_UNDEFINED_CARTESIAN_SRS = "NoUndefinedCartesianSrs";

	public static final String NO_UNDEFINED_GEOGRAPHIC_SRS = "NoUndefinedGeographicSrs";

	public static final String UNDEFINED_SRS = "UndefinedSrs";

	public static final String SRS_MISMATCH = "SRSMismatch";

	public static final String CONTENT_TABLE_DOES_NOT_EXIST = "ContentTableDoesNotExist";

	public static final String BAD_CONTENTS_ENTRY_LAST_CHANGE_FORMAT = "BadContentsEntryLastChangeFormat";

	public static final String BAD_CONTENTS_TABLE_SRS_FOREIGN_KEY = "BadContentsTableSrsForeignKey";

	public static final String BAD_CONTENTS_TABLE_DEFINITION = "BadContentsTableDefinition";

	public static final String OPTIONS_NO_FEATURES_OR_TILES = "OptionsNoFeaturesOrTiles";

	public static final String FEATURES_BINARY_INVALID = "FeaturesBinaryInvalid";

	public static final String FEATURES_GEOMETRY_COLUMNS_INVALID = "FeaturesGeometryColumnsInvalid";

	public static final String FEATURES_GEOMETRY_COLUMNS_NO_FK = "FeaturesGeometryColumnsNoFK";

	public static final String FEATURES_GEOMETRY_COLUMNS_MISMATCH = "FeaturesGeometryColumnsMismatch";

	public static final String FEATURES_GEOMETRY_COLUMNS_INVALID_COL = "FeaturesGeometryColumnsInvalidCol";

	public static final String FEATURES_GEOMETRY_COLUMNS_INVALID_GEOM = "FeaturesGeometryColumnsInvalidGeom";

	public static final String FEATURES_GEOMETRY_COLUMNS_INVALID_Z = "FeaturesGeometryColumnsInvalidZ";

	public static final String FEATURES_GEOMETRY_COLUMNS_INVALID_M = "FeaturesGeometryColumnsInvalidM";

	public static final String FEATURES_ONE_GEOMETRY_COLUMN = "FeaturesOneGeometryColumn";

	public static final String TILES_TABLES_NOT_REFERENCED_IN_CONTENTS = "TilesTablesNotReferencedInContents";

	public static final String VALUES_DO_NOT_VARY_BY_FACTOR_OF_TWO = "ValuesDoNotVaryByFactorOfTwo";

	public static final String INVALID_IMAGE_FORMAT = "InvalidImageFormat";

	public static final String BAD_TILE_MATRIX_SET_TABLE_DEFINITION = "BadTileMatrixSetTableDefinition";

	public static final String UNREFERENCED_TILE_MATRIX_SET_TABLE = "UnreferencedTileMatrixSetTable";

	public static final String UNREFERENCED_TILES_CONTENT_TABLE_NAME = "UnreferencedTilesContentTableName";

	public static final String BAD_MATRIX_SET_SRS_REFERENCE = "BadMatrixSetSrsReference";

	public static final String BAD_TILE_MATRIX_TABLE_DEFINITION = "BadTileMatrixTableDefinition";

	public static final String BAD_MATRIX_CONTENTS_REFERENCES = "BadMatrixContentsReferences";

	public static final String MISSING_TILE_MATRIX_ENTRY = "MissingTileMatrixEntry";

	public static final String BAD_PIXEL_DIMENSIONS = "BadPixelDimensions";

	public static final String NEGATIVE_ZOOM_LEVEL = "NegativeZoomLevel";

	public static final String NON_POSITIVE_MATRIX_WIDTH = "NonPositiveMatrixWidth";

	public static final String NON_POSITIVE_MATRIX_HEIGHT = "NonPositiveMatrixHeight";

	public static final String NON_POSITIVE_TILE_WIDTH = "NonPositiveTileWidth";

	public static final String NON_POSITIVE_TILE_HEIGHT = "NonPositiveTileHeight";

	public static final String NON_POSITIVE_PIXEL_X_SIZE = "NonPositivePixelXSize";

	public static final String NON_POSITIVE_PIXEL_Y_SIZE = "NonPositivePixelYSize";

	public static final String PIXEL_SIZE_NOT_DECREASING = "PixelSizeNotDecreasing";

	public static final String BAD_TILE_PYRAMID_USER_DATA_TABLE_DEFINITION = "BadTilePyramidUserDataTableDefinition";

	public static final String UNDEFINED_ZOOM_LEVEL = "UndefinedZoomLevel";

	public static final String TILE_COLUMN_OUT_OF_RANGE = "TileColumnOutOfRange";

	public static final String TILE_ROW_OUT_OF_RANGE = "TileRowOutOfRange";

	public static final String INVALID_RTREE_REFERENCE = "InvalidRTreeReference";

	public static final String INVALID_DATA_COLUMN = "InvalidDataColumn";

	public static final String INVALID_DATA_TABLE = "InvalidDataTable";

	public static final String INVALID_EXTENSION_DATA_SCOPE = "InvalidExtensionDataScope";

	public static final String ILLEGAL_EXTENSION_DATA_SCOPE = "IllegalExtensionDataScope";

	public static final String EXTENDED_GEOMETRY_REFERENCE_MISSING = "ExtendedGeometryReferenceMissing";

	public static final String INVALID_RTREE_DEFINITION = "InvalidRTreeDefinition";

	public static final String INVALID_METADATA_SCOPE = "InvalidMetadataScope";

	public static final String BAD_METADATA_REFERENCE_TABLE_DEFINITION = "BadMetadataReferenceTableDefinition";

	public static final String INVALID_METADATA_REFERENCE_SCOPE = "InvalidMetadataReferenceScope";

	public static final String BAD_METADATA_REFERENCE_SCOPE_COLUMN_NAME_AGREEMENT = "BadMetadataReferenceScopeColumnNameAgreement";

	public static final String INVALID_METADATA_REFERENCE_TABLE = "InvalidMetadataReferenceTable";

	public static final String COVERAGE_ANCILLARY_COLUMNS_INVALID = "CoverageAncillaryColumnsInvalid";

	public static final String COVERAGE_ANCILLARY_NO_FK = "CoverageAncillaryNoFK";

	public static final String TILE_ANCILLARY_COLUMNS_INVALID = "TileAncillaryColumnsInvalid";

	public static final String TILE_ANCILLARY_NO_FK = "TileAncillaryNoFK";

	public static final String NO_ELEVATION_SRS = "NoElevationSrs";

	public static final String NO_ELEVATION_SRS_REFERENCE = "NoElevationSrsReference";

	public static final String ELEVATION_EXTENSION_ROWS_MISSING = "ElevationExtensionRowsMissing";

	public static final String UNREFERENCED_COVERAGE_TILE_MATRIX_SET_TABLE = "UnreferencedCoverageTileMatrixSetTable";

	public static final String CONSTRAINT_NON_NULL_VALUE = "ConstraintNonNullValue";

	public static final String CONSTRAINT_MINMAX_INVALID = "ConstraintMinMaxInvalid";

	public static final String CONSTRAINT_INCLUSIVE_INVALID = "ConstraintInclusiveInvalid";

	public static final String COVERAGE_ANCILLARY_DATATYPE_INVALID = "CoverageAncillaryDatatypeInvalid";

	public static final String TILE_ANCILLARY_REFERENCES = "TileAncillaryReferences";

	public static final String TILE_ANCILLARY_TABLE_REF_INVALID = "TileAncillaryTableRefInvalid";

	public static final String FEATURE_TABLE_NAMES_MISSING = "FeatureTableNamesMissing";

	public static final String FEATURE_GEOMETRY_INVALID_MAGIC_NUMBER = "FeatureGeometryColumnInvalidMagicNumber";

	public static final String FEATURE_GEOMETRY_INVALID_VERSION = "FeatureGeometryColumnInvalidVersion";

	public static final String FEATURE_GEOMETRY_INVALID_BINARY_CODE = "FeatureGeometryColumnInvalidBinaryCode";

	public static final String FEATURE_GEOMETRY_INVALID_ENVELOPE_CODE = "FeatureGeometryColumnInvalidEnvelopeCode";

	public static final String FEATURE_GEOMETRY_INVALID_DETECTED_EMPTY_GEOMETRY_FLAG_BUT_ENVELOPE_HAS_CONTENT = "FeatureGeometryColumnDetectedEmptyGeometryFlagButEnvelopeHasContent";

	public static final String FEATURE_GEOMETRY_SRS_NOT_IN_GPKG_CONTENTS = "FeatureGeometryColumnSRSNotInGpkgContents";

	public static final String FEATURE_GEOMETRY_POSSIBLE_BYTE_SWAP_ERROR_SRS_MATCH = "FeatureGeometryColumnSRSMatchWhenBytesSwapped";

	public static final String FEATURE_GEOMETRY_SRS_MISMATCH = "FeatureGeometryColumnSRSDoesNotMatchSpecifiedSRSForFeature";

	public static final String FEATURE_GEOMETRY_TYPE_INVALID = "FeatureGeometryColumnGeometryTypeNotValid";

	public static final String FEATURE_GEOMETRY_TYPE_INVALID_POSSIBLE_BYTE_SWAP = "FeatureGeometryColumnGeometryTypeNotValidButByteSwapErrorPossible";

	public static final String FEATURE_GEOMETRY_NOT_ASSIGNABLE_TO_SUPERTYPE = "Feature_GeometryColumnGeometryNotAssignableToSupertype";

	public static final String FEATURE_GEOMETRY_TYPE_NOT_PRESENT_AS_EXTENSION = "FeatureGeometryColumnGeometryTypeNotPresentAsExtension";

	public static final String FEATURE_GEOMETRY_ENVELOPE_OUTSIDE_BOUNDS_OF_GEOPACKAGE = "FeatureGeometryColumnEnvelopeOutsideExtentsOfGeoPackage";

	public static final String FEATURE_GEOMETRY_ENVELOPE_OUTSIDE_TOLERANCE_OF_RTREE_TRIGGER_MIN_MAX = "FeatureGeometryColumnEnvelopeOutsideToleranceOfRTreeTriggerMinMax";

	public static final String FEATURE_FOREIGN_KEY_NOT_SPECIFIED_CORRECTLY = "FeatureForeignKeyNotSpecifiedCorrectly";

	public static final String FEATURE_GEOMETRY_ENVELOPE_RTREE_TABLE_MISSING_OR_IN_ERROR = "FeatureGeometryColumnRtreeTableMissingOrInError";

	public static final String FEATURE_GEOMETRY_BLOB_PROCESSING_TEST_FAILURE = "FeatureGeometryColumnBLOBProcessingTestFailure";

	public static final String FEATURE_GEOMETRY_WKB_ITEM_COUNT_ILLEGAL = "FeatureGeometryWKBItemCountIllegal";

	public static final String FEATURE_GEOMETRY_COLUMNS_DOES_NOT_MATCH_CONTENTS_COUNT = "FeatureGeometryColumnsDoeNotMatchContents";

	public static final String FEATURE_GEOMETRY_COLUMNS_SRS_ID_NOT_CONSISTENT_WITH_CONTENTS = "FeatureGeometryColumnsSRSIDNotConsistentWithContents";

}
