package org.opengis.cite.gpkg12.features;

import static org.testng.Assert.assertTrue;
import static org.testng.AssertJUnit.fail;

import java.math.BigInteger;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.opengis.cite.gpkg12.ColumnDefinition;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.FeaturesFixture;
import org.opengis.cite.gpkg12.TableVerifier;
import org.opengis.cite.gpkg12.util.GeoPackageVersion;
import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.testng.Assert;
import org.testng.SkipException;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to descriptive information about a
 * GeoPackage's content as it pertains to features.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#features" target= "_blank">
 * GeoPackage Encoding Standard - 2.1 Features</a> (OGC 12-128r13) and OGC 12-128r14 </li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class FeaturesTests extends FeaturesFixture {

	    // --------------------- Private Class Variables -----------------
		private final Boolean NativeOrderIsBE = ByteOrder.nativeOrder().equals(ByteOrder.BIG_ENDIAN);
    
		private static final Map<String, ColumnDefinition> FeatureTableExpectedColumns; 
		private static final Map<String, List<String>> GeometrySubtypesAllowed; 
		
		// These flags can be set once and then used to quickly skip tests that depend on these two things
		private boolean hasGeometryColumnsTable;
		private boolean hasGPKGExtensionsTable;

	
		private final Collection<String> possibleFeatureTableNames         = new ArrayList<>();
		private final Collection<String> featureTableNames = new ArrayList<>();

		
	
		// For tests 19, 20, 32, 33, 19b, 67, 78 - they will all be run based on an iterator and we need the error reporting to be capped,
		// hence these counters and limits are defined to cap those error reports.
		 int errorDetected19 = 0;
		 int errorDetected32 = 0;
		 int errorDetected33 = 0;
		 int errorDetectedNSG19b = 0;
		 int errorDetected66 = 0;
		 int errorDetected67 = 0;
		 int errorDetected78 = 0;
		 int errorDetected20 = 0 ;
		 
		// Since a feature typically will have all instances reporting the same errors, this maximum count reduces the reporting per feature.
		private static final int maxErrorsToReport19 = 15;           // This is a per feature maximum report. This test has several different things going on.
																	 // and it should be split into sub items to better report these issues.
		private static final int maxErrorsToReport32 = 5;            // Per feature maximum, this test reports one issue - but it'll list all instances found
		private static final int maxErrorsToReport33 = 5;            // Per feature maximum, this test reports one issue - but it'll list all instances found
//		private static final int maxErrorsToReportNSG19b = 5;
		private static final int maxErrorsToReport66 = 5;
		private static final int maxErrorsToReport67 = 5;
		private static final int maxErrorsToReport78 = 5;
		private static final int maxErrorsToReport20 = 5;
		
		// Masks and starting byte index for Geometry BLOB Contents
//		private static final byte magicB0 = 0x47;
//		private static final byte magicB1 = 0x50;
		private static final byte maskFlagBinaryType = 0x20;
		private static final int  shiftFlagBinaryType = 5;
		private static final byte maskFlagEmptyGeometry = 0x10;
		private static final int  shiftFlagEmptyGeometry = 4;
		private static final byte maskFlagEnvelope = 0x0E;
		private static final int  shiftFlagEnvelope = 1;
		private static final byte maskFlagHeaderEndian = 0x01;
		private static final int  startOfVersion = 2;
		private static final int  startOfFlags = 3;
		private static final int  startOfSRIDIndex = 4;
		private static final int  startOfEnvelopeIndex = 8;
		private static final int  startOfGeometryType = 1;
//		private static final int  startOfEnvelopeCodeIndex = 3;
		private static final int maximumEnvelopeSize = 8 * Double.BYTES;  // As per the OGC spec, no more than 8 doubles should be in the envelope
		
	    private static final String myminx = "minx";
	    private static final String myminy = "miny";
	    private static final String mymaxx = "maxx";
	    private static final String mymaxy = "maxy";
	    private static final String myminz = "minz";
	    private static final String mymaxz = "maxz";
	    private static final String myminm = "minm";
	    private static final String mymaxm = "maxm";

	    
	    private static final String geomCIRCULARSTRING = "CIRCULARSTRING";
	    private static final String geomCOMPOUNDCURVE = "COMPOUNDCURVE";
	    private static final String geomCURVEPOLYGON = "CURVEPOLYGON";
	    private static final String geomMULTICURVE = "MULTICURVE";
	    private static final String geomMULTISURFACE = "MULTISURFACE";
	    private static final String geomCURVE = "CURVE";
	    private static final String geomSURFACE = "SURFACE";
	    private static final String geomUNSUPPORTED = "UNSUPPORTED";
	    
		// From Annex G: These are in a "Note" under table 28
		   // GEOMETRY subtypes are POINT, CURVE, SURFACE and GEOMCOLLECTION  <-- assume they must mean GEOMETRYCOLLECTION because GEOMCOLLECTION is not a geometry type
		   // CURVE subtypes are LINESTRING, CIRCULARSTRING and COMPOUNDCURVE
		   // SURFACE subtype is CURVEPOLYGON
		   // CURVEPOLYGON subtype is POLYGON
		   // GEOMETRYCOLLECTION subtypes are MULTIPOINT, MULTICURVE and MULTISURFACE
		   // MULTICURVE subtype is MULTILINESTRING  <- contradicted in 2.1.1
		   // MULTISURFACE subtype is MULTIPOLYGON   <- contradicted in 2.1.1
		
		// Assumption that subtypes of subtypes are also allowed
		// This static hasmap defines for each supertype, all of the allowed subtype geometries.
	    // TODO this section needs work. There are inconsistencies in the spec and the test requirement isn't very specific
		 static
		 {
			 GeometrySubtypesAllowed = new HashMap<>();
			 GeometrySubtypesAllowed.put(geomCURVE,  Arrays.asList(geomLINESTRING, geomCIRCULARSTRING, geomCOMPOUNDCURVE              // Subtypes
					));
			 
			 GeometrySubtypesAllowed.put(geomSURFACE,  Arrays.asList(geomCURVEPOLYGON,                                              // Subtypes
					 geomPOLYGON));   // Polygon is a subtype of a subtype
			 
			 GeometrySubtypesAllowed.put(geomCURVEPOLYGON,  Arrays.asList(geomPOLYGON,                                              // Subtypes
					 geomCURVE, geomLINESTRING, geomCIRCULARSTRING, geomCOMPOUNDCURVE));

			 // 2.1.1 Polygon: A restricted form of CurvePolygon where each ring is defined as a simple, closed LineString.
			 GeometrySubtypesAllowed.put(geomPOLYGON,  Arrays.asList(geomLINESTRING
					 ));
			 
			 GeometrySubtypesAllowed.put(geomGEOMETRYCOLLECTION,  Arrays.asList(geomMULTIPOINT, geomMULTICURVE, geomMULTISURFACE,       // Subtypes
					 geomMULTIPOLYGON, geomMULTILINESTRING));  // Multipolygon is a subtype of a subtype and Multilinestring is subtype of a subtype
			 
			 
			 // 2.1.1 MultiSurface: A restricted form of GeometryCollection where each Geometry in the collection must be of type Surface.
			 GeometrySubtypesAllowed.put(geomMULTISURFACE,  Arrays.asList(geomSURFACE     ));  

			 // 2.1.1 MultiPolygon: A restricted form of MultiSurface where each Surface in the collection must be of type Polygon.
			 GeometrySubtypesAllowed.put(geomMULTIPOLYGON,  Arrays.asList(geomPOLYGON   ));    
			 
			 // 2.1.1 MultiCurve: A restricted form of GeometryCollection where each Geometry in the collection must be of type Curve
			 GeometrySubtypesAllowed.put(geomMULTICURVE,  Arrays.asList( geomCURVE  ));   
			 
			 // 2.1.1 MultiLineString: A restricted form of MultiCurve where each Curve in the collection must be of type LineString.
			 GeometrySubtypesAllowed.put(geomMULTILINESTRING,  Arrays.asList(geomLINESTRING ));  

			 // 2.1.1 ???
			 GeometrySubtypesAllowed.put(geomMULTIPOINT,  Arrays.asList(geomPOINT ));  
			 
			 GeometrySubtypesAllowed.put(geomGEOMETRY,  Arrays.asList(geomPOINT, geomCURVE, geomSURFACE, geomGEOMETRYCOLLECTION,          // Subtypes
					 geomLINESTRING, geomCIRCULARSTRING, geomCOMPOUNDCURVE, geomCURVEPOLYGON, geomPOLYGON,  geomMULTIPOINT, geomMULTICURVE, geomMULTISURFACE, geomMULTIPOLYGON, geomMULTILINESTRING));
		 }
	
		 // Define the required columns of the feature table
		static
		{
			FeatureTableExpectedColumns = new HashMap<>();
			FeatureTableExpectedColumns.put("id",           new ColumnDefinition("INTEGER", false, true,  true,  null));
			FeatureTableExpectedColumns.put("geometry",    new ColumnDefinition("GEOMETRY", true,  false, false, null));
		}
		
		// End Private Class Information
		

	/**
	 * Sets up variables used across methods
	 *
	 * @throws SQLException
	 *             if there is a database error
	 */
	@BeforeClass
	public void setUp() throws SQLException {

		// Set internal flag denoting whether the geopackage has geometry columns table or not. If it does not, then many tests will be skipped.
    	this.hasGeometryColumnsTable = DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_geometry_columns");
    	this.hasGPKGExtensionsTable = DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions");

    	// Capture any **potential** feature table names that are **NOT** listed within the gpkg_contents
    	// Save these names as we will compare them later on to the names specified in the gpkg_contents.
    	
        try(Statement statement = this.databaseConnection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT tbl_name FROM sqlite_master WHERE tbl_name NOT LIKE \'gpkg_%\' AND (type = \'tile\' OR type = \'view\');"))
        {
            while(resultSet.next())
            {
            	// Examine each of the potential feature tables in the geopackage to see if they are missing from the
            	// contents specification. This test is not specifically identified in the standard.
                try
                {
                	// FORITY ISSUE within verifyTable
                    final String tableName = ValidateSQLiteTableColumnStringInput(resultSet.getString("tbl_name"));

                    // If we think we have a feature table, make sure it has the expected columns.
                    // This throws if the table definition doesn't match, and won't be added to the collection
                    TableVerifier.verifyTable(this.databaseConnection,
                                              tableName,
                                              FeatureTableExpectedColumns,
                                              null,
                                              null);
                    // Save the feature table on a list so that we may use it later on.
                    this.possibleFeatureTableNames.add(tableName);
                }
                catch(final Throwable ignore)
                {
                    // If verification fails- it's not a features table and we don't care about it so ignore

                }
            }
		}
		

		try (
				final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type = \'features\';");
				) {
			while (resultSet.next()) {
				this.featureTableNames.add(resultSet.getString(1));
			}
		}


		Assert.assertTrue(!this.featureTableNames.isEmpty(), ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_DISABLED, getTestName()));
	}


	
    
    /**
     * A DataProvider that supplies feature instance test methods with content from gpkg_geometry_columns
     * such that feature instance test methods may verify feature internal content is consistent with
     * gpkg_geometry_columns information.
     * 
     * @return An Iterator over an array containing a set of objects representing
     *         the information needed to process tests against geometry BLOB information
     */
    @DataProvider(name = "feature-geometry-information")
    public Iterator<Object[]> getFeaturesWithGeometryInfo() {
    	List<Object[]> data = new ArrayList<Object[]>();
        
    	/*
		 * 1. SELECT table_name AS tn, column_name AS cn FROM gpkg_geometry_columns WHERE table_name IN (SELECT table_name FROM gpkg_contents WHERE data_type = ‘features’)
		 *    added srs_id, geometry_type_name, z, m in order to capture the remaining testable values in gpkg_geometry_columns for which we will visit every feature instance.
		 */
        try(final Statement statement = this.databaseConnection.createStatement();
                final ResultSet resultSet = statement.executeQuery("SELECT table_name AS tn, column_name AS cn, srs_id, geometry_type_name AS gt_name, z as z_flag, m as m_flag FROM gpkg_geometry_columns WHERE table_name IN (SELECT table_name FROM gpkg_contents WHERE data_type = \'features\');"))
        {
            while(resultSet.next())
            {
  				/* Package the parameters:
  				*  String TableName
  				* String GeometryColumnName gpkg_geometry_columns
  				* String GeometryType from gpkg_geometry_columns
  				* Integer SRS id from gpkg_geometry_columns
  				* byte Z flag from gpkg_geometry_columns
  				* byte M flag from gpkg_geometry_columns
  				*/

  	        	Object[] tuple = {resultSet.getString("tn"), 						
  	        			resultSet.getString("cn"), 						
  	        			resultSet.getString("gt_name").toUpperCase(),
  	        			resultSet.getInt("srs_id"), 
  	        			(byte) resultSet.getInt("z_flag"), 
  	        			(byte) resultSet.getInt("m_flag")
  	        	}; 
  	        	data.add(tuple);
  			}
                  	
        } catch (SQLException e) {
    		// TODO Auto-generated catch block
    		e.printStackTrace();
    	}        

        return data.iterator();
    }

    /**
     * Verify that the gpkg_contents table_name value table exists, and is apparently a feature table for every row with a data_type column value of 'features'
     *
     * Test Case
     * {@code /opt/features/contents/data/features_row}
     * @see <a href="http://www.geopackage.org/spec120/index.html" target=
     *            "_blank">Vector Features - Requirement 18</a>
     *            
     * 
     * @throws SQLException
     *                If an SQL query causes an error
     */
	@Test( description = "See OGC 12-128r14: Requirement 18")
	public void features_contents_data_features_row() throws SQLException
	{
		/*
		 *  TEST METHOD
		* 1.  Execute test<br>/opt/features/vector_features/data/feature_table_integer_primary_key
		*/
		final Collection<String> missingFeatureTableNames = this.possibleFeatureTableNames
				.stream()
				.filter(tableName -> !this.featureTableNames.contains(tableName))
				.collect(Collectors.toList());

	   final String reportOut = String.join(", ", missingFeatureTableNames);
	   Assert.assertTrue((missingFeatureTableNames == null || missingFeatureTableNames.isEmpty()),
			   ErrorMessage.format(ErrorMessageKeys.FEATURE_TABLE_NAMES_MISSING,
					   reportOut));

	}
	

     
 
	 

	/**
	 * A GeoPackage MAY contain tables or updateable views containing vector 
	 * features. Every such feature table or view in a GeoPackage SHALL have 
	 * a column with column type INTEGER and PRIMARY KEY AUTOINCREMENT column 
	 * constraints per EXAMPLE : Sample Feature Table or View Definition and 
	 * sample_feature_table Table Definition SQL (Informative).
	 *
	 * Test case
	 * {@code /opt/features/vector_features/data/feature_table_integer_primary_key}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Vector
	 *      Features User Data Tables - Requirement 29</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 29")
	public void featureTableIntegerPrimaryKey() throws SQLException {
		// 1
		for (final String tableName : this.featureTableNames) {
			try (
					final Statement statement = this.databaseConnection.createStatement();
					// 3a
					final ResultSet resultSet = statement.executeQuery(String.format("PRAGMA table_info(\'%s\');", tableName));
					) {
				// 3b
				assertTrue(resultSet.next(),
						ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableName));				
			}

			// 3c/3d
			checkPrimaryKey(tableName, getPrimaryKeyColumn(tableName, false), false);
		}
	}


	
    /**
     * Verify that geometries stored in feature table geometry columns are encoded in the StandardGeoPackageBinary format.
     * and are consistent with the information specified in the gpkg_geometry_columns table for the feature type.
     * Also verify that the geometry information is consistent with other elements of the geopackage as per
     * specified test requirements. In order to optimize processing as much as possible, all tests involving
     * the feature instance geometry element are performed within this block. 
     * The entry to this test is via an iterator operating on each feature table - hence the test reports will
     * be specific to each feature table processed.
     *
     * Test Case for tests 19, 20, 32, 33, 66 (partial) 67, 78
     * {@code /opt/features/geometry_encoding/data/blob 
     * /opt/features/geometry_encoding/data/core_types_existing_sparse_data 
     * /opt/features/vector_features/data/data_values_geometry_type
     *  /opt/features/vector_features/data/data_value_geometry_srs_id
     *  /extensions/geometry_types/extension_name
     *  /reg_ext/features/spatial_indexes/implementation/sql_functions}
     * 
     * 
     * @see <a href="http://www.geopackage.org/spec120/index.html" target=
     *            "_blank">Geometry Encoding - Requirements 19, 20, 32, 33, 66 (partial), 67, 78 and Geometry Extents check (NSG 19B)</a>
     *  
     * @param thisTableName 	The feature table name being processed
     * @param thisColumnName   The feature column name (the geometry column) being processed; as specified in the gpkg_geometry_columns entry table associated with this feature
     * @param geomType			The geometry type as specified in the gpkg_geometry_columns entry table associated with this feature
     * @param srs_id			The srs identifier as specified in the gpkg_geometry_columns entry table associated with this feature
     * @param z_flag			The z flag as specified in the gpkg_geometry_columns entry table associated with this feature
     * @param m_flag			The m flag as specified in the gpkg_geometry_columns entry table associated with this feature
     * 
     * @throws SQLException
     *                If an SQL query causes an error
     */
    @Test( description = "See OGC 12-128r14: Requirements 19, 20, 32, 33, 66 (partial), 67, 78; and NSG Requirement 19B", dataProvider = "feature-geometry-information")
    public void featureGeometryEncodingTesting(String thisTableName, String thisColumnName, String geomType, 
   		 Integer srs_id, byte z_flag, byte m_flag) throws SQLException
    {

    	try {

    		/*
    		 * 1. SELECT table_name AS tn, column_name AS cn FROM gpkg_geometry_columns WHERE table_name IN (SELECT table_name FROM gpkg_contents WHERE data_type = ‘features’)
    		 * 2. Not testable if returns an empty result set
    		 * 3. For each row from step 1
    		 */
    		try( final Statement statementInternal = this.databaseConnection.createStatement();
    				final ResultSet resultSetInternal = statementInternal.executeQuery(String.format("SELECT rowid, %s as geom FROM \'%s\';", thisColumnName, thisTableName)))
    		{
    			/* a. SELECT cn FROM tn
    			 * b. Not testable if none found
    			 */

    			// quick fix for https://github.com/opengeospatial/ets-gpkg12/issues/74
				//while(resultSetInternal.next() )
    			if(resultSetInternal.next() )
    			{
    				// The SQL should give us a numeric identifier and a geometry blob.  All of the tests in this series operate off
    				// of these two values and the parameters passed in by the iterator.
    				final long rowID = (long) resultSetInternal.getLong(1);
    				final byte[] bytes = resultSetInternal.getBytes("geom");

    				// We must allow for null geometries.
    				if (bytes == null){
    					//continue;
						throw new SkipException( "No geom available." );
    				}
    				// From the geometry blob, populate a few of the values that we can easily extract from the geometry
    				final byte envelopeCode = (byte) ((bytes[startOfFlags] & maskFlagEnvelope) >> shiftFlagEnvelope);
    				final byte binaryTypeFlag = (byte) ((bytes[startOfFlags] & maskFlagBinaryType) >> shiftFlagBinaryType);
    				final byte emptyGeometryFlag = (byte) ((bytes[startOfFlags] & maskFlagEmptyGeometry) >> shiftFlagEmptyGeometry);
    				final byte headerLE = (byte) (bytes[startOfFlags] & maskFlagHeaderEndian);

    				// variables needed by this series of tests that will be used by more than one test
    				Map<String, Double> envelopeVals = new HashMap<>();               // We will put the envelope in here in a bit
    				final int envelopeSize = mygetEnvelopeByteSize(envelopeCode);     
    				final boolean swapHeaderBytes = (this.NativeOrderIsBE && headerLE == 1) || (!this.NativeOrderIsBE && headerLE == 0);
    				boolean nanDetected = false;

    				// Tests begin now

    				// ** START ************** 19 ************************ 19 ************************** 19 **************************
    				/* Requirement 19:
    				 * c. For each cn value from step a                 [ cn is essentially a BLOB - layout partly shown below ]
    				 *    i. Fail if the first two bytes of each gc are not 'GP'
    				 *    ii. Fail if gc.version_number is not 0
    				 *    iii. Fail if gc.flags.GeopackageBinary type != 0
    				 *    iv.  (Fail if cn.flags.E is 5-7)   Previously in 128r12 was:  Fail if ST_IsEmpty(cn value) = 1 
    				 *    v. *Fail if the geometry is empty but the envelope is not empty (gc.flags.envelope != 0 and envelope values are not NaN)
    				 * 4. Pass if no fails
    				 */


    				// GeoPackageBinaryHeader {
    				//  byte[2] magic = 0x4750;      // "GP" in ASCII
    				//  byte version;                // 0 = version 1
    				//  byte flags;                  // bit layout for flags below, note flags includes endianness for the rest of this header
    				//  int32 srs_id;
    				//  double[] envelope;           // size of this is implied by the envelope indicator code in the flags
    				//  }     
    				//
    				// flags bit layout:
    				//   7  6  5  4  3  2  1  0
    				//   R  R  X  Y  E  E  E  B
    				//
    				//    7: R: Reserved set to 0
    				//    6: R: Reserved set to 0
    				//    5: X: GeoPackage Binary Type  0=Standard, 1=Extended
    				//    4: Y: Empty Geometry Flag    0= non-empty geometry, 1=Empty Geometry  (so envelope should be empty or NaN too, test v.)
    				//    3-1: E: Envelope Indicator Code (3-bit unsigned)
    				//          0 = no envelope   0 byte envelope
    				//          1 = envelope is [minx, maxx, miny, maxy] 32 bytes envelope
    				//          2 = envelope is [minx, maxx, miny, maxy, minz, maxz] 48 bytes envelope
    				//          3 = envelope is [minx, maxx, miny, maxy, minz, maxz, minm, maxm]  64 bytes envelope
    				//          5-7 = invalid value for envelope  (test iv.)
    				//    0: B: Byte order for header values   0 = Big Endian, 1 = Little Endian
    				//
    				// The GeoPackageBinaryHeader is followed by WKB



    				try {
    					// i. Fail if the first two bytes of each gc are not "GP" 
    					final byte[] GP_HEADER = new String("GP")
    							.getBytes(StandardCharsets.US_ASCII);
    					if  ( (bytes[0] != GP_HEADER[0]) || (bytes[1] != GP_HEADER[1]) ) {
    						errorDetected19 ++;
    						if (errorDetected19 < maxErrorsToReport19)
    							Assert.assertTrue(false,
    									ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_INVALID_MAGIC_NUMBER, 
    											thisTableName, rowID, thisColumnName, String.format("0x%02x%02x",  bytes[0], bytes[1])));
    					}


    					// ii. Fail if gc.version_number is not 0
    					final byte version = (byte)bytes[startOfVersion];
    					if (version != 0) {
    						errorDetected19 ++;
    						if (errorDetected19 < maxErrorsToReport19)
    							Assert.assertTrue(false,
    									ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_INVALID_VERSION,
    											thisTableName, rowID, thisColumnName, version));
    					}

    					// iii. Fail if gc.flags.GeopackageBinary type != 0
    					if (binaryTypeFlag != 0) {
    						errorDetected19 ++;
    						if (errorDetected19 < maxErrorsToReport19)
    							Assert.assertTrue(false,
    									ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_INVALID_BINARY_CODE,
    											thisTableName, rowID, thisColumnName, binaryTypeFlag));
    					}


    					// iv. (Fail if cn.flags.E is 5-7)  
    					if ( envelopeCode > 4 || envelopeCode < 0 ) {
    						errorDetected19 ++;
    						if (errorDetected19 < maxErrorsToReport19)
    							Assert.assertTrue(false,
    									ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_INVALID_ENVELOPE_CODE,
    											thisTableName, rowID, thisColumnName, envelopeCode));
    					}  

    				} catch(final Exception th)
    				{
    					fail(
    							ErrorMessage.format(
    									ErrorMessageKeys.FEATURE_GEOMETRY_BLOB_PROCESSING_TEST_FAILURE, 
    									String.format("Failure testing requirement 19i-iv on feature {0}", thisTableName), th.getMessage()));
    				}  	
    				// ** END ************** 19 i-iv ************************ 19 ************************** 19 **************************


    				// ** START **************  33 ************************  ************
    				//{@code /opt/features/vector_features/data/data_value_geometry_srs_id}
    				// description = "See OGC 12-128r14: Requirement 33", dataProvider = "feature-geometry-information" 
    				/* 
    				 * REQUIREMENT 33
    				 * a. SELECT DISTINCT st_srid(cn) FROM tn            Note in this code, we process each row and we already performed the SELECT above to get each row
    				 * b. For each row from step a
    				 * i. Fail if returnvalue not equal to gc_srs_id
    				 * 4. Pass if no fails
    				 */

    				// Note: dependency on the value of currentSRID that we used for a different test is within this one.
    				// the SRSID extracted from the geometry BLOB will be compared to the srsContents (srs_id) retrieved from gpkg_contents

    				// Get a byte array at the correct offset for the srs_id and set up the byte array size to be the size of an integer
    				byte[] srspartID = byteArraySubset(bytes, startOfSRIDIndex, Integer.BYTES);   // 4 bytes

    				// Using our helper function, get the integer from the byte array, and signify whether there is byte swapping needed
    				// We will SAVE this SRID as it is needed for a couple of tests
    				int currentSRID = getIntegerFromBytesWithPossibleSwap(srspartID, swapHeaderBytes);   // this value is needed for this test and a test in #19        		 


    				// Check for possible byte swap error on this SRS ID content vs the gpkg_geometry_columns value (which was a parameter to this test).
    				// This will tell us if there is a problem with the detection
    				// of the endianness either within the geometry blob, or of the machine hardware upon which the test is being run.
    				// Since this is the ONLY place we are going to try to test the endianness, it needs to be done prior to messing
    				// with the envelope values. Hence, this is why this test is put prior to 19v.
    				try {

    					if (currentSRID != srs_id )
    					{
    						// So far, the test failed. Perform an extra test - swap the bytes and see if we get the SRID now -
    						// to see if the issue can be identified as a byte swap issue. Note, this may not work with large or negative values
    						// due to sign extension on the integer, but we will try it anyway.
    						int tempSRID = Integer.reverseBytes(currentSRID);

    						if (tempSRID == srs_id) {
    							// It appears this may then be a byte swap issue, so report the SR ID problem and the fact it may be a byte swap issue
    							// meaning the header endianness may be incorrect or this code base is incorrect.
    							errorDetected33 ++;
    							if (errorDetected33 < maxErrorsToReport33)
    								Assert.assertTrue(false,
    										ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_POSSIBLE_BYTE_SWAP_ERROR_SRS_MATCH,
    												rowID, thisColumnName, currentSRID, srs_id, thisTableName));
    						} else {
    							// Not able to determine if the issue is a byte swap issue, so report it as an SRS ID issue
    							errorDetected33 ++;
    							if (errorDetected33 < maxErrorsToReport33)
    								Assert.assertTrue(false,
    										ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_SRS_MISMATCH,
    												rowID, thisColumnName, currentSRID, srs_id, thisTableName));
    						}
    					}
    				} catch(final Exception th)
    				{
    					fail(
    							ErrorMessage.format(
    									ErrorMessageKeys.FEATURE_GEOMETRY_BLOB_PROCESSING_TEST_FAILURE, 
    									String.format("Failure testing requirement 33 part b on feature {0}", thisTableName), th.getMessage()));
    				}


    				// ** END *** 33 ************************  33 *************************


    				// ** START ************** 19v ************************ 19 ************************** 19 **************************
    				try {

    					// v. *Fail if the geometry is empty but the envelope is not empty (gc.flags.envelope != 0 and envelope values are not NaN)
    					if (envelopeSize > 0 && envelopeSize < maximumEnvelopeSize) {
    						final byte bytesEnvelope[] = byteArraySubset(bytes, startOfEnvelopeIndex , envelopeSize);
    						try {
    							// Ignoring the return value; we are just looking for the exception processing at this time
    							mygetEnvelope(envelopeSize, swapHeaderBytes, bytesEnvelope, envelopeVals);

    						} catch(IllegalArgumentException ee)  // this should catch the indication that we a nan values in the envelope 
    						{
    							//final String errMsg = ee.getMessage();
    							nanDetected = true;
    						}


    						if (!nanDetected && emptyGeometryFlag != 0) {
    							errorDetected19 ++;
    							if (errorDetected19 < maxErrorsToReport19)
    								Assert.assertTrue(false,
    										ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_INVALID_DETECTED_EMPTY_GEOMETRY_FLAG_BUT_ENVELOPE_HAS_CONTENT,
    												rowID, thisColumnName, thisTableName));
    						}
    					}  // end if envelopeSize > 0 ...   Currently it is valid to have an envelope that is 0 size. In the future, that may change if there is geometry.
    					// also we should never get an envelopeSize over the max size (as it comes from the code and a private method here) so we are not checking for that.


    				} catch(final Exception th)
    				{
    					fail(
    							ErrorMessage.format(
    									ErrorMessageKeys.FEATURE_GEOMETRY_BLOB_PROCESSING_TEST_FAILURE, 
    									String.format("Failure testing requirement 19v on feature {0}", thisTableName), th.getMessage()));
    				}
    				// ** END ************** 19v ************************ 19 ************************** 19 **************************


    				// WKB Header
    				// byte    byteOrder     0 = Big Endian; 1 = Little Endian
    				// uint32  wkbGeometryType
    				// GEOMETRY
    				
    				String actualGeometryType = geomUNSUPPORTED;
    				
    				// These next tests require that there be geometry
    				if (emptyGeometryFlag == 0) {

    					final int geometryStart = startOfEnvelopeIndex + envelopeSize;                                 // Find the start of the WKB Geometry Blob within the SHAPE Blob
    					// The geometry WKB has yet another structure with yet another possible big / little endian setting
    					final byte geometryByteOrderLE = bytes[geometryStart];                                          // The Geometry Blob may have a different byte order than the header or the SQLite
    					final boolean swapGeometryBytes = (geometryByteOrderLE == 1 && this.NativeOrderIsBE) || (geometryByteOrderLE == 0 && !this.NativeOrderIsBE);

    					// Get the subset of bytes representing the geometry type, 
    					// then get the geometry type integer from those bytes, 
    					// then get the geometry type string from the integer
    					byte[] geomtypeBytes = byteArraySubset(bytes, geometryStart + startOfGeometryType, Integer.BYTES);
    					final int currentGeomType = getIntegerFromBytesWithPossibleSwap(geomtypeBytes, swapGeometryBytes);
    					actualGeometryType = getGeomTypeFromNum(currentGeomType).toUpperCase();

    					// ** START ****** 20 ************************ 20 ************************** 20 **************************
    					/* 
    					 * REQUIREMENT 20
    					 * 1.   b.  For  each row from step a, 
    					 * if bytes 2-5 of cn.wkb as uint32 in endianness of gc.wkb 
    					 * 
    					 * ***** NOTE THIS TEST SHOULD NOT be performed if there is NO geometry
    					 * 
    					 * byte 1 of cn from #1 are a geometry type value from Annex G Table 42, 
    					 * then
    					 *    i.  Log cn.header values, wkb endianness and geometry type
    					 *    
    					 *    TEST IS NOT including full decomposition of WKB, only the geometry type
    					 *   ii.  *If cn.wkb is not  correctly encoded per ISO 13249-3  clause 5.1.46  then log fail
    					 *  iii.  Otherwise log pass
    					 *  6.  Pass  if log contains pass and no fails
    					 */
    					try {

    						// Verify that the actual geometry type is something valid, our getGeomTypeFromNum will assign "UNSUPPORTED" if it is invalid
    						if ( actualGeometryType.equals(geomUNSUPPORTED)) {
    							// So the geometry type is not recognized. Try a byte swap on the value and see if we get any
    							// supported value now. Report a different error if we get a value.
    							final int altGeomType = getIntegerFromBytesWithPossibleSwap(geomtypeBytes, !swapGeometryBytes);   // test if the byte swap flag might be wrong
    							final String testGeomType = getGeomTypeFromNum(altGeomType).toUpperCase();
    							if (testGeomType.equals(geomUNSUPPORTED)) {
	    							errorDetected20 ++;
	    							if (errorDetected20 < maxErrorsToReport20)
	    								Assert.assertTrue(false,
	    										ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_TYPE_INVALID,		 
	    												rowID, thisColumnName, geomType, (int)currentGeomType, thisTableName));
    							} else {
    								// Report a possible byte swap problem in the WKB portion of this BLOB
	    							errorDetected20 ++;
	    							if (errorDetected20 < maxErrorsToReport20)
	    								Assert.assertTrue(false,
	    										ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_TYPE_INVALID_POSSIBLE_BYTE_SWAP,		 
	    												rowID, thisColumnName, geomType, (int)currentGeomType, thisTableName, (int)altGeomType, testGeomType));
    							}
    						}

    					} catch(final Exception th)
    					{
    						fail(
    								ErrorMessage.format(
    										ErrorMessageKeys.FEATURE_GEOMETRY_BLOB_PROCESSING_TEST_FAILURE, 
    										String.format("Failure testing requirement 20 on feature {0}", thisTableName), th.getMessage()));
    					}						 

    					// ** END ****** 20 ************************ 20 ************************** 20 ***************************/


    					// ** START  ****** 32 ************************ 32 ************************** 32 ***************************/
    					//@ID (/opt/features/vector_features/data/data_value_geometry_srs_id)
    					//@Test( description = "See OGC 12-128r14: Requirement 32 all items", dataProvider = "feature-geometry-information")

    					/*
    					 *  REQUIREMENT 32
    					 * Test Method
    					 *    3. For each row from step 1
    					 *    a. *Select the set of geometry types in use for the values in cn (geometry column)   WAS: SELECT DISTINCT ST_GeometryType(cn) FROM tn
    					 *    b. For each row actual_type_name from step a
    					 *    i. Determine if each geometry type is assignable to the actual_type_name
    					 *    ii. Fail if any are not assignable
    					 *    4. Pass if no fails
    					 *    
    					 */


    					// Guess what - we have already retrieved both the current WKB geometry type and the geometry specified for this feature type
    					// so it is just a matter of determining whether the
    					// geom_type representing the geometry_column_table type vs. the GeometryType in the current WKB record are compatible.
    					try {

    						// Verify that the actual geometry type is 'assignable' i.e. equal to or a subset of the specified geometry from the geometry table
    						// The call to IsAssignable is expecting a return of 1 if assignable, 0 if not.
    						// the variable actualGeometryType is coming from the feature WKB while the geomType is from the gpkg_geometry_columns
    						// If the value actualGeometryType is equal to or is defined a s a subtype to the geomType, this will return the value of 1

    						if ( this.IsAssignable(geomType, actualGeometryType) == 0 ) {
    							errorDetected32 ++;
    							if (errorDetected32 < maxErrorsToReport32)
    								Assert.assertTrue(false,
    										ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_NOT_ASSIGNABLE_TO_SUPERTYPE,		
    												rowID, thisColumnName, geomType, actualGeometryType, thisTableName));
    						}

    					} catch(final Exception th)
    					{
    						fail(
    								ErrorMessage.format(
    										ErrorMessageKeys.FEATURE_GEOMETRY_BLOB_PROCESSING_TEST_FAILURE, 
    										String.format("Failure testing requirement 32 on feature {0}", thisTableName), th.getMessage()));
    					}

    					// ** END  ****** 32 ************************ 32 ************************** 32 **************************



    					// ************** PARTIAL TEST for Requirement 66 here ********** 66************************66 *********************66 ***************
    					//
    					int geometryItemCount = 1;
        				if (actualGeometryType != geomPOINT)
        				{
        					byte[] wkbGeometryCount = byteArraySubset(bytes, geometryStart + startOfGeometryType + Integer.BYTES, Integer.BYTES);
        					geometryItemCount = getIntegerFromBytesWithPossibleSwap(wkbGeometryCount, swapGeometryBytes);
        				}
        				if (geometryItemCount < 0) {
							errorDetected66 ++;
							if (errorDetected66 < maxErrorsToReport66)
								Assert.assertTrue(false,
										ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_WKB_ITEM_COUNT_ILLEGAL,		
												thisTableName, rowID, thisColumnName,  actualGeometryType, geometryItemCount));        					
        				}
        				// ** END  ****** PARTIAL 66 ************************ 66 ************************** 66 **************************


    					// ** START  ****** 67 ************************ 67 ************************** 67 **************************
    					/*  
    					 * REQUIREMENT 67
    					 *  C. SELECT ST_GeometryType(geometry column value) AS <gtype>;
    					 * D.  SELECT extension_name FROM gpkg_extensions WERE table_name
    					 *     = result_set_table_name AND  column_name = result_set_column_name AND extension_name = \'gpkg_geom_' || <gtype>
    					 * I.  Fail if result set is empty
    					 * II.  Log pass otherwise
    					 * 4.  Pass  if logged pass and no fails
    					 */

    					if (this.hasGPKGExtensionsTable == true)
    					{
    						try {
    							// Tests have shown it is possible to NOT have these in the extensions table at all. Since they are 'extensions' that would
    							// not be an error!  Therefore, first check to be sure the gpkg_geom_* extensions are present at all in the gpkg_extensions
    							// table.  If, at some time, it is determine that these are requirements and not just extensions, we can remove this
    							// first sub-test.
    							boolean testForGeomExtensions = false;
    							try(final Statement statementST = this.databaseConnection.createStatement();
    									final ResultSet resultSetST = statementST.executeQuery(String.format(
    											"SELECT extension_name FROM gpkg_extensions WHERE (extension_name LIKE \'gpkg_geom_\');")))	        	                            
    							{
    								if (resultSetST.next() == true) {  // false if the result is empty
    									testForGeomExtensions = true;
    								}
    							}

    							// If we have verified the geometry extensions are present in the extensions table, proceed
    							if (testForGeomExtensions) {
    								try(final Statement statementST = this.databaseConnection.createStatement();
    										final ResultSet resultSetST = statementST.executeQuery(String.format(
    												"SELECT extension_name FROM gpkg_extensions WHERE (table_name = \'%s\' AND column_name = \'%s\' AND extension_name = \'gpkg_geom_%s\');", 
    												thisTableName, thisColumnName, actualGeometryType)))		        	                            
    								{
    									if (resultSetST.next() == false)  { // returns false if the result set is empty	    				 
    										errorDetected67 ++;
    										if (errorDetected67 < maxErrorsToReport67)
    											Assert.assertTrue(false,
    													ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_TYPE_NOT_PRESENT_AS_EXTENSION,
    															rowID, thisColumnName, actualGeometryType, actualGeometryType, thisTableName));
    									}	    				 
    								}
    							}
    						} catch(final Exception th)
    						{
    							fail(
    									ErrorMessage.format(
    											ErrorMessageKeys.FEATURE_GEOMETRY_BLOB_PROCESSING_TEST_FAILURE, 
    											String.format("Failure testing requirement 67 on feature {0}", thisTableName), th.getMessage()));
    						}
    					}

    					// ** END  ****** 67 ************************ 67 ************************** 67 **************************

    				} // End tests of WKB Geometry requiring non empty geometry flag





    				// ** START   ****** NSG 19B ************************ NSG 19B ************************** NSG 19B **************************
    				//@Test( description = "See NSG Requirement 19b: Requirement NSG 19b features portion", dataProvider = "feature-geometry-information")




    				// This next set looks at the gpkg_contents as compared to the values in the feature
    				// instance geometry BLOB.  This is for NSG requirement 19 B
    				// NOTE: This test does not test profiles but we're going to keep it (commented out) for now
    				// because a requirement could be added as part of GPKG 1.3.0.
    				/*
    				try {
    					if (!envelopeVals.isEmpty()) {
    						try(final Statement statementST = this.databaseConnection.createStatement();
    								final ResultSet resultSetST = statementST.executeQuery(
    										String.format(
    							"SELECT srs_id as srsContents, min_x, min_y, max_x, max_y FROM gpkg_contents WHERE (data_type = \'features\' and table_name = \'%s\' and srs_id IN (%s) );",
    							thisTableName, srs_id)))
    						{

    							while (resultSetST.next()) {
    								// Get the srs extents and save for comparison
    								final Map<String, Double> extentsforsrs = new HashMap<>();
    								extentsforsrs.put(myminx, resultSetST.getDouble("min_x"));
    								extentsforsrs.put(mymaxx, resultSetST.getDouble("max_x"));
    								extentsforsrs.put(myminy, resultSetST.getDouble("min_y"));
    								extentsforsrs.put(mymaxy, resultSetST.getDouble("max_y"));


    								// If they are null, all values will be 0 (getDouble) will put them to 0 if they are null. 
    								// Perform the test if any values are set and test only if we have anything of value here.

    								if (!checkIfValueWithinToleranceOfTargetValue(extentsforsrs.get(myminx),0.0D, 1.0e-10) ||  
    										!checkIfValueWithinToleranceOfTargetValue(extentsforsrs.get(myminy),0.0D, 1.0e-10) || 
    										!checkIfValueWithinToleranceOfTargetValue(extentsforsrs.get(mymaxx),0.0D, 1.0e-10) || 
    										!checkIfValueWithinToleranceOfTargetValue(extentsforsrs.get(mymaxy),0.0D, 1.0e-10)) {
    									final String enveloperesult = geometryEnvelopeWithinExtents(envelopeVals, extentsforsrs);
    									if (enveloperesult != "") {
    										errorDetectedNSG19b ++;
    										if (errorDetectedNSG19b < maxErrorsToReportNSG19b) {
    											Assert.assertTrue(false,
    													ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_ENVELOPE_OUTSIDE_BOUNDS_OF_GEOPACKAGE,
    															rowID, thisColumnName, srs_id, thisTableName, envelopeVals.get(myminx), envelopeVals.get(mymaxx),  
    															envelopeVals.get(myminy),  envelopeVals.get(mymaxy), enveloperesult ));
    										}

    									}  // end if geometryEvelopeWithinExtents == false
    								} // end if check of min max values show they are not 0
    							}
    						}
    					}
    				} catch(final Exception th)
    				{

    					fail(
    							ErrorMessage.format(
    									ErrorMessageKeys.FEATURE_GEOMETRY_BLOB_PROCESSING_TEST_FAILURE, 
    									String.format("Failure testing requirement NSG 19B on feature {0}", thisTableName), th.getMessage()));
    				}
						*/
    				// ** END   ****** NSG 19B ************************ NSG 19B ************************** NSG 19B **************************



    				// ** START   ****** 78 ************************ 78 ************************** 78 **************************
    				//@Test( description = "See OGC 12-128r14: Requirement 78", dataProvider = "feature-geometry-information")



    				// Tests on gpkg_extensions and rtree. We have to flip the stated test around because we are doing this per
    				// feature instance.
    				// Stated test #78 from Spec 128r14
    				//
    				// Using the rtree_FeatureTableName_GeometryColumnName
    				// 1.  Open Geometry Test Data Set GeoPackage with GeoPackage SQLite Extension
    				// 2.  For   each  Geometry Test   Data  Set   <gtype_test> data  table  row  for   each geometry type in  Annex G, for  an assortment of srs_ids, 
    				//      for  an assortment of coordinate values including empty geometries, without and with z and / or  m values, in both big and little endian encodings:
    				// a.  SELECT 'Fail'  FROM <gtype_test> WHERE ST_IsEmpty(geom.) != empty  <---- note we are not checking this. This test is not going to happen if the geometry is empty
    				// b.  SELECT 'Fail'  FROM <gtype_test> WHERE ST_MinX(geom) != minx
    				// c.  SELECT 'Fail'  FROM <gtype_test> WHERE ST_MaxX(geom) != maxx 
    				// d.  SELECT 'Fail'  FROM <gtype_test> WHERE ST_MinY(geom) != miny 
    				// e.  SELECT 'Fail'  FROM <gtype_test> WHERE ST_MaxY(geom) != maxy
    				// 3.  Pass  if no 'Fail'  selected from step 2

    				// Dependent on the feature instance min and max geometry values and whether we have envelope values

    				try {
  
    					// If we have no envelope, we cannot perform this test
    					//Commented as deprecated in  OGC 12-128r14 (Refer issue #99)
    					/*if (!envelopeVals.isEmpty()) {

    						final String rtreeTable = String.format("rtree_%s_%s",thisTableName, thisColumnName);

    						try(final Statement statementST = this.databaseConnection.createStatement();
    								final ResultSet resultSetST = statementST.executeQuery(String.format("SELECT minx, maxx, miny, maxy FROM \'%s\' WHERE (rowid = %s);", rtreeTable, rowID)))		        	                            
    						{
    							final Double localtolerance = 1.0e-4;        // 1.0e-5 is not good enough for most geopackages to pass!

    							while(resultSetST.next() ) {
    								final Map<String, Double> rtreeminmaxVals = new HashMap<>();
    								rtreeminmaxVals.put(myminx, resultSetST.getDouble(myminx));
    								rtreeminmaxVals.put(mymaxx, resultSetST.getDouble(mymaxx));
    								rtreeminmaxVals.put(myminy, resultSetST.getDouble(myminy));
    								rtreeminmaxVals.put(mymaxy, resultSetST.getDouble(mymaxy));

    								// Verify the geometry envelope falls within the rtree extents for this instance
    								// final String enveloperesult = geometryEnvelopeWithinExtents(envelopeVals, rtreeminmaxVals);   // this test would test for the envelope within the rtree, not equal to
    								if (!checkIfValueWithinToleranceOfTargetValue(rtreeminmaxVals.get(myminx), envelopeVals.get(myminx), localtolerance) ||
    										!checkIfValueWithinToleranceOfTargetValue(rtreeminmaxVals.get(mymaxx), envelopeVals.get(mymaxx), localtolerance) ||
    										!checkIfValueWithinToleranceOfTargetValue(rtreeminmaxVals.get(myminy), envelopeVals.get(myminy), localtolerance) ||
    										!checkIfValueWithinToleranceOfTargetValue(rtreeminmaxVals.get(mymaxy), envelopeVals.get(mymaxy), localtolerance) )						 
    								{
    									errorDetected78 ++;
    									if (errorDetected78 < maxErrorsToReport78) {
    										Assert.assertTrue(false,
    												ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_ENVELOPE_OUTSIDE_TOLERANCE_OF_RTREE_TRIGGER_MIN_MAX,
    														rowID, thisColumnName, thisTableName, envelopeVals.get(myminx), envelopeVals.get(mymaxx),  envelopeVals.get(myminy),  envelopeVals.get(mymaxy)));
    									}

    								}
    							}
    						}
    					}*/
    				} catch(final Exception th)
    				{

    					//   At this time, do not report an error here. If there is no rtree table, I guess it is not worth reporting an error
    					//   ets-gpkg12 tests including the features-0.gpkg sample will fail right here.
    					//		 errorDetected78 ++;
    					//		 if (errorDetected78 < maxErrorsToReport78) {
    					//			 Assert.assertTrue(false,
    					//					ErrorMessage.format(ErrorMessageKeys.FEATURE_GEOMETRY_ENVELOPE_RTREE_TABLE_MISSING_OR_IN_ERROR,
    					//							thisTableName, thisColumnName));
    					//		 }
    				}


    				// ** END   ****** 78 ************************ 78 ************************** 78 **************************

    			} // End while result set
    		}
    	} 
    	catch(final Exception th)
    	{
    		fail(
    				ErrorMessage.format(
    						ErrorMessageKeys.FEATURE_GEOMETRY_BLOB_PROCESSING_TEST_FAILURE, "main loop", th.getMessage()));
    	}   
    }

 

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/table_def}
	 *
	 * @see <a href="_requirement-21" target= "_blank">Vector
	 *      Features Geometry Columns Table - Requirement 21</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 21")
	public void featureGeometryColumnsTableDef() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("PRAGMA table_info(\'gpkg_geometry_columns\');");
				) {

			// 2
			int passFlag = 0;
			final int flagMask = 0b00111111;

			while (resultSet.next()) {
				// 3
				final String name = resultSet.getString("name");
				if ("geometry_type_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 0, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= 1;
				} else if ("table_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 1);
				} else if ("m".equals(name)){
					assertTrue("TINYINT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 0, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 2);
				} else if ("z".equals(name)){
					assertTrue("TINYINT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 0, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 3);
				} else if ("srs_id".equals(name)){
					assertTrue("INTEGER".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 0, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 4);
				} else if ("column_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 2, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 5);
				}
			} 
			assertTrue((passFlag & flagMask) == flagMask, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);			
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_geometry_columns}
	 *
	 * @see <a href="_requirement-22" target= "_blank">Vector
	 *      Features Geometry Columns Table - Requirement 22</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 22")
	public void featureGeometryColumnsDataValues() throws SQLException {
		try (		
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type = \'features\';");
				) {
			// 2
			if (resultSet.next()){
				try (
						// 3
						final Statement statement2 = this.databaseConnection.createStatement();

						final ResultSet resultSet2 = statement2.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type = \'features\' AND table_name NOT IN (SELECT table_name FROM gpkg_geometry_columns);");
						) {
					assertTrue(!resultSet2.next(), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_MISMATCH);
				}
			}			
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_table_name} and
	 * {@code /opt/features/geometry_columns/data/data_values_srs_id}
	 *
	 * @see <a href="_requirement-23" target= "_blank">Vector
	 *      Features Geometry Columns Table - Requirement 23</a>
	 * and  <a href="_requirement-26" target= "_blank">Vector
	 *      Features Geometry Columns SRS ID - Requirement 26</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 23, 26")
	public void featureGeometryColumnsDataValuesTableName() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("PRAGMA foreign_key_list(\'gpkg_geometry_columns\');");
				) {
			boolean foundContents = false;
			boolean foundSpatialRefSys = false;

			// 2
			while (resultSet.next()){
				// 3
				final String table = resultSet.getString("table");
				if ("gpkg_spatial_ref_sys".equals(table)){
					if ("srs_id".equals(resultSet.getString("from")) && "srs_id".equals(resultSet.getString("to"))){
						foundSpatialRefSys = true;
					}
				} else if ("gpkg_contents".equals(table)){
					if ("table_name".equals(resultSet.getString("from")) && "table_name".equals(resultSet.getString("to"))){
						foundContents = true;
					}
				}
			}
			assertTrue(foundContents && foundSpatialRefSys, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_NO_FK);
		}
	}


	
	   /**
	    * Test case
	    * {@code /opt/features/geometry_columns/data/data_values_table_name}
	    * 
	    * Verify that the table_name column values in the gpkg_geometry_columns table are valid.
	    *
	    * @see <a href="http://www.geopackage.org/spec/#_requirement-23" target=
	    *            "_blank">Data Values Table Name - Requirement 23</a>
	    * @throws SQLException
	    *                If an SQL query causes an error
	    */
	    @Test( description = "See OGC 12-128r14: Requirement 23")
	    public void featureGeometryColumnsDataValuesTableNameNEW() throws SQLException
	    {
	        /*
	         * Test Method
	         *    Test as per 12-128r14
	         *    1. PRAGMA foreign_key_list(gpkg_geometry_columns);
			 *    2. Fail if there is no row designating table_name as a foreign key to table_name in gpkg_contents
	         */
	        if(this.hasGeometryColumnsTable)
	        {

	        	final Collection<String> reportFKIssues = new ArrayList<>();
	        	int countResults = 0;
		        try ( final Statement statement  = this.databaseConnection.createStatement();
		                 final ResultSet resultSet = statement.executeQuery("PRAGMA foreign_key_list(\'gpkg_geometry_columns\');"))
		            {
		        		
		        		
			            while(resultSet.next())
			            {
			            	Boolean testFailedForFKItem = true;
			            	final String thisTableName = ValidateSQLiteTableColumnStringInput(resultSet.getString("table"));   // maybe not the right column?
			            	// final String thisColumnFrom = resultSet.getString("from");
			            	final String thisColumnTo = ValidateSQLiteTableColumnStringInput(resultSet.getString("to"));
			            	countResults ++;
			            	// FORTIFY CWE Corrected
	                    	try(final Statement preparedStatement = this.databaseConnection.createStatement();
	                                final ResultSet pragmaTableInfo   = preparedStatement.executeQuery(String.format("PRAGMA table_info(\'%s\');", thisTableName)))
	                            {
	                        		
	                                while(pragmaTableInfo.next() && testFailedForFKItem)
	                                {
	                                	final String columnName = pragmaTableInfo.getString("name");
	                                
	                                	if (thisColumnTo.equals(columnName))
	                                	{
	                                		testFailedForFKItem = false;
	                                	}
	                                }
	                            }
	                    	// failure if EITHER no table exists that matches the specified FK, the specified FK column in the table does not exist
	                    	if (testFailedForFKItem) {
	                    		reportFKIssues.add(thisTableName);
	                    	}

			            	}  // end while resultSet.next()
			            } // end try to get foreign key list

		        		// Check for the possible initial failure indicating there were no foreign keys specified at all
		        		if (countResults == 0) {
		        			reportFKIssues.add("No foreign key specified in gpkg_geometry_columns");
		        		}
		        		final String reportOut = String.join(", ", reportFKIssues);
			            
			            Assert.assertTrue((reportFKIssues == null || reportFKIssues.isEmpty()),
			            		ErrorMessage.format(ErrorMessageKeys.FEATURE_FOREIGN_KEY_NOT_SPECIFIED_CORRECTLY,
			    						reportOut));
		      } 
	        	
	    }
		
		
		
	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_column_name}
	 *
	 * @see <a href="_requirement-24" target= "_blank">Vector
	 *      Features Geometry Columns Column - Requirement 24</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 24")
	public void featureGeometryColumnsDataValuesColumnName() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name FROM gpkg_geometry_columns;");
				) {
			// 2
			while (resultSet.next()){
				final String tableName = ValidateSQLiteTableColumnStringInput(resultSet.getString("table_name"));
				final String columnName = ValidateSQLiteTableColumnStringInput(resultSet.getString("column_name"));

				try (
						final Statement statement2 = this.databaseConnection.createStatement();
						// FORTIFY CWE Corrected
						final ResultSet resultSet2 = statement2.executeQuery(String.format("PRAGMA table_info(\'%s\');", tableName));
						) {
					boolean foundMatch = false;

					while (resultSet2.next()) {
						if (resultSet2.getString("name").equals(columnName)){
							foundMatch = true;
							break;
						}
					}

					assertTrue(foundMatch, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_COL, tableName, columnName));
				}
			}	
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_srs_id_match}
	 *
	 * @see <a href="_requirement-146" target= "_blank">Vector
	 *      Features Geometry Columns Column - Requirement 146</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 146")
	public void featureGeometryColumnsDataValuesSrsId() throws SQLException {
		try (
			// 1
			final Statement statement = this.databaseConnection.createStatement();

			final ResultSet resultSet = statement.executeQuery("SELECT a.srs_id srs_id, a.table_name tn FROM gpkg_geometry_columns a, gpkg_contents b WHERE a.table_name = b.table_name and a.srs_id != b.srs_id");
		) {
			// 2
			if (resultSet.next()){
				fail(ErrorMessage.format(ErrorMessageKeys.SRS_MISMATCH, "gpkg_geometry_columns", resultSet.getInt("srs_id"), resultSet.getString("tn")));
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_geometry_type_name}
	 *
	 * @see <a href="_requirement-25" target= "_blank">Vector
	 *      Features Geometry Columns Geometry Type - Requirement 25</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 25")
	public void featureGeometryColumnsDataValuesGeometryType() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name, geometry_type_name FROM gpkg_geometry_columns");
				) {
			// 2
			while (resultSet.next()){
				// 3
				final String geometryTypeName = resultSet.getString("geometry_type_name");
				final String tableName = resultSet.getString("table_name");
				final String columnName = resultSet.getString("column_name");

				boolean pass = false;

				if (geopackageVersion.equals(GeoPackageVersion.V120)){
					pass = ALLOWED_GEOMETRY_TYPES.contains(geometryTypeName);
				} else {
					final Iterator<String> iterator = ALLOWED_GEOMETRY_TYPES.iterator();
					while(iterator.hasNext()){
						if (geometryTypeName.equalsIgnoreCase(iterator.next())){
							pass = true;
							break;
						}
					}
				}

				if (!pass) {
					pass = isExtendedType(tableName, columnName);
				}

				assertTrue(pass, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_GEOM, geometryTypeName, tableName));
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_z}
	 *
	 * @see <a href="_requirement-27" target= "_blank">Vector
	 *      Features Geometry Columns Z - Requirement 27</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 27")
	public void featureGeometryColumnsDataValuesZ() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT z FROM gpkg_geometry_columns");
				) {
			// 2
			if (resultSet.next()){
				try (
						// 3
						final Statement statement2 = this.databaseConnection.createStatement();

						final ResultSet resultSet2 = statement2.executeQuery("SELECT z FROM gpkg_geometry_columns WHERE z NOT IN (0,1,2)");
						) {
					if(resultSet2.next()){
						assertTrue(false, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_Z, resultSet2.getInt("z")));
					}
				}
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_m}
	 *
	 * @see <a href="_requirement-28" target= "_blank">Vector
	 *      Features Geometry Columns M - Requirement 28</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 28")
	public void featureGeometryColumnsDataValuesM() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT m FROM gpkg_geometry_columns");
				) {
			// 2
			if (resultSet.next()){
				try (
						// 3
						final Statement statement2 = this.databaseConnection.createStatement();

						final ResultSet resultSet2 = statement2.executeQuery("SELECT m FROM gpkg_geometry_columns WHERE m NOT IN (0,1,2)");
						) {
					if(resultSet2.next()){
						assertTrue(false, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_M, resultSet2.getInt("m")));
					}
				}
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/vector_features/data/feature_table_one_geometry_column}
	 *
	 * @see <a href="_requirement-30" target= "_blank">Vector
	 *      Features One Geometry Column - Requirement 30</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 30")
	public void featureTableOneGeometryColumn() throws SQLException {
		try (		
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type=\'features\'");
				) {
			// 2
			while (resultSet.next()){
				// 3
				final String tableName = ValidateSQLiteTableColumnStringInput(resultSet.getString("table_name"));
				try (
						final Statement statement2 = this.databaseConnection.createStatement();
						// FORTIFY CWE Corrected
						final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT count(*) FROM gpkg_geometry_columns WHERE table_name = \'%s\'", tableName));
						) {
					resultSet2.next();
					assertTrue(resultSet2.getInt(1) == 1, ErrorMessageKeys.FEATURES_ONE_GEOMETRY_COLUMN);
				}
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/vector_features/data/feature_table_geometry_column_type}
	 *
	 * @see <a href="_requirement-31" target= "_blank">Vector
	 *      Features Geometry Column Type - Requirement 31</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 31")
	public void featureTableGeometryColumnType() throws SQLException {
		// We're just going to skip this test on older GeoPackages and hope for the best.
		if (geopackageVersion.equals(GeoPackageVersion.V120)){
			try (
					// 1
					final Statement statement = this.databaseConnection.createStatement();

					final ResultSet resultSet = statement.executeQuery(
					"SELECT table_name, column_name, geometry_type_name FROM gpkg_geometry_columns WHERE table_name IN (SELECT table_name FROM gpkg_contents WHERE data_type = \'features\')");
					) {
				// 2
				while (resultSet.next()){
					// 2a
					final String geometryTypeName = resultSet.getString("geometry_type_name");
					// This assertion being removed as per https://github.com/opengeospatial/geopackage/issues/347
					//				assertTrue(allowedGeometryTypes.contains(geometryTypeName), ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_GEOM, geometryTypeName));

					//2b
					final String tableName = ValidateSQLiteTableColumnStringInput(resultSet.getString("table_name"));
					final String columnName = ValidateSQLiteTableColumnStringInput(resultSet.getString("column_name"));
					try (
							final Statement statement2 = this.databaseConnection.createStatement();
							// FORTIFY CWE Corrected
							final ResultSet resultSet2 = statement2.executeQuery(String.format("PRAGMA table_info(\'%s\')", tableName));
							) {
						while (resultSet2.next()){
							if (columnName.equals(resultSet2.getString("name"))) {
								assertTrue(geometryTypeName.equals(resultSet2.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_MISMATCH);
								break;
							}
						}
					}
				}				
			}
		}
	}


	

    // *************************SUPPORTING  METHODS *****************    SUPPORTING METHODS ***********************
    
    /**
     * Returns an integer from a byte array and provides for
     * byte swap if necessary.
     *
     * @param bytesIn The integer bytes as an array; must be number of bytes in an integer
     * @param swapFlag Boolean indicator for whether the bytes are to be swapped or not
     *
     * @return Integer value of the bytes
     * @throws IllegalArgumentException if the byte array length is not equivalent to the number of bytes in an integer
     */   
    private int getIntegerFromBytesWithPossibleSwap(byte[] bytesIn, boolean swapFlag) {
   	 int returnValue = 0;
   	// Verify length of byte array is correct, throw and error on failure
   	 if (bytesIn.length == Integer.BYTES) {
   		 // Based on endianness of this platform and the swapFlag, and our intends use of BigInteger, which assumes BigEndian data,
   		 // determine whether the bytes will be swapped or not.  Note: We could do this the old-fashioned way with shifts as an alternative.
			if ((!swapFlag && this.NativeOrderIsBE) || (swapFlag && !this.NativeOrderIsBE)) {   
				returnValue = new BigInteger(bytesIn).intValue();
				} else {
					returnValue = Integer.reverseBytes(new BigInteger(bytesIn).intValue());
				}
   	 } else {
   		 throw new IllegalArgumentException("Invalid byte array length");
   	 }
   	 return returnValue;
    }

    /**
     * Returns an long integer from a byte array and provides for
     * byte swap if necessary.
     *
     * @param bytesIn The long bytes as an array of bytes; must be number of bytes in an long integer
     * @param swapFlag Boolean indicator for whether the bytes are to be swapped or not
     *
     * @return Long value of the bytes
     * @throws IllegalArgumentException if the byte array length is not equivalent to the number of bytes in a Long integer
     */          
    private long getLongFromBytesWithPossibleSwap(byte[] bytesIn, boolean swapFlag) {
   	 long returnValue = 0;
   	 // Verify length of byte array is correct, throw and error on failure
   	 if (bytesIn.length == Long.BYTES) {
   		 // Based on endianness of this platform and the swapFlag, and our intends use of BigInteger, which assumes BigEndian data,
   		 // determine whether the bytes will be swapped or not.  Note: We could do this the with bit shifts as an alternative; may be faster.
          	 // alternative method: (long)(bytesIn[ii+0] << 56 | (bytesIn[ii+1] & 0xFF) << 48 | (bytesIn[ii+2] & 0xFF) << 40 | (bytesIn[ii+3] & 0xFF) << 32 | (bytesIn[ii+4] & 0xFF) << 24 | (bytesIn[ii+5] & 0xFF) << 16 | (bytesIn[ii+6] & 0xFF) << 8 | (bytesIn[ii+7] & 0xFF));
			 // alternative method: (long)(bytesIn[ii+7] << 56 | (bytesIn[ii+6] & 0xFF) << 48 | (bytesIn[ii+5] & 0xFF) << 40 | (bytesIn[ii+4] & 0xFF) << 32 | (bytesIn[ii+3] & 0xFF) << 24 | (bytesIn[ii+2] & 0xFF) << 16 | (bytesIn[ii+1] & 0xFF) << 8 | (bytesIn[ii+0] & 0xFF));     
			if ((!swapFlag && this.NativeOrderIsBE) || (swapFlag && !this.NativeOrderIsBE)) {
				returnValue = new BigInteger(bytesIn).longValue();
				} else {
					returnValue = Long.reverseBytes(new BigInteger(bytesIn).longValue());
				}
   	 } else {
   		 throw new IllegalArgumentException("Invalid byte array length");
   	 }
   	 return returnValue;
    }

    /**
     * Returns an double from a byte array and provides for
     * byte swap if necessary. Upon detection of NaN
     *
     * @param bytesIn The integer bytes as an array; must be number of bytes in an integer
     * @param swapFlag Boolean indicator for whether the bytes are to be swapped or not
     *
     * @return Double value of the bytes
     * 
     * @throws IllegalArgumentException if the byte array length is not equivalent to the number of bytes in a Double
     * @throws IllegalArgumentException if any value is NaN
     */ 
    private double getDoubleFromBytesWithPossibleSwap(byte[] bytesIn, boolean swapFlag) {
   	 double returnValue = 0;
   	// Verify length of byte array is correct, throw and error on failure
   	 if (bytesIn.length == Double.BYTES) {
   		 // Cannot simply convert the bytes into a double as the floating point processor may change the
   		 // bits on us during the conversion. First get the bytes into a Long and then use the LongBitsToDouble
   		 // to move the bits into a double.
   		 long tempLong = getLongFromBytesWithPossibleSwap(bytesIn, swapFlag);
   		 // If the tempLong is NaN, throw an error that the double is not valid
   		 
   		 // Need to test for NaN here as conversion to Double may change the bits. Java encodes NaN a infinity
   		 if (isLongRepresentationNaN(tempLong))
   		 {
   			 throw new IllegalArgumentException("NaN");
   		 } 
       	 returnValue = Double.longBitsToDouble(tempLong);
   	 } else {
   		 throw new IllegalArgumentException("Invalid byte array length");
   	 }
   	 return returnValue;
    }
    
    

    /**
     * Detects a numeric representation as NaN if provided a long integer representation
     * of a double. This tests for the NaN as specified in 12-128r14 Table 6. bit layout of GeoPackageBinary flags byte  NaN
     *
     * @param inValue The long integer representation of the bits of a double
     *
     * @return Boolean true if NaN, false if not NaN
     */ 
    private boolean isLongRepresentationNaN(long inValue)
    {

   	 return ((this.NativeOrderIsBE && (inValue == 0x7ff8000000000000L)) || 
   		(!this.NativeOrderIsBE && (inValue == 0x000000000000f87fL))) ? true : false;
    }
    

    /**
     * Test for Java representation of Double NaN or Infinity which may be the Java representation
     * of the NaN as specified in OGC 12-128r14 Table 6.
     *
     * @param inValue The double value that is to be tested
     *
     * @return Boolean true if NaN, false if not NaN
     */ 
    private boolean isDoubleRepresentationNaNorInfinity(Double inValue) 
    {
   	 return (Double.isNaN(inValue) || Double.isInfinite(inValue)) ? true : false;
    }
    
    

    /**
     * Get the geometry type string given the geometry type integer from WKB.
     * of the NaN as specified in OGC 12-128r14 Table 28.
     *
     * @param geomTypeIn The integer geometry type from WKB
     *
     * @return String geometry type. If the geometry type is not found, returns "UNSUPPORTED"
     */ 
    

    
    private String getGeomTypeFromNum(int geomTypeIn) {
    	String result = "";
    	switch(geomTypeIn) {
    	// Table 28. Geometry Type Codes
    	case 0: case 1000: case 2000: case 3000:
    		result = geomGEOMETRY;
    		break;
    	case 1: case 1001: case 2001: case 3001:
    		result =  geomPOINT;
    		break;
    	case 2: case 1002: case 2002: case 3002:
    		result =  geomLINESTRING;
    		break;
    	case 3: case 1003: case 2003: case 3003:
    		result =  geomPOLYGON;
    		break;
    	case 4: case 1004: case 2004: case 3004:
    		result =  geomMULTIPOINT;
    		break;
    	case 5: case 1005: case 2005: case 3005:
    		result =  geomMULTILINESTRING;
    		break;
    	case 6: case 1006: case 2006: case 3006:
    		result =  geomMULTIPOLYGON;
    		break;
    	case 7: case 1007: case 2007: case 3007:
    		result =  geomGEOMETRYCOLLECTION;
    		break;
    	// Table 28. Geometry Type Codes (Extension)
    	case 8: case 1008: case 2008: case 3008:
    		result =  geomCIRCULARSTRING;
    		break;
    	case 9: case 1009: case 2009: case 3009:
    		result =  geomCOMPOUNDCURVE;
    		break;
    	case 10: case 1010: case 2010: case 3010:
    		result =  geomCURVEPOLYGON;
    		break;
    	case 11: case 1011: case 2011: case 3011:
    		result =  geomMULTICURVE;
    		break;
    	case 12: case 1012: case 2012: case 3012:
    		result =  geomMULTISURFACE;
    		break;
    	case 13: case 1013: case 2013: case 3013:
    		result =  geomCURVE;
    		break;
    	case 14: case 1014: case 2014: case 3014:
    		result =  geomSURFACE;
    		break;
    	default:
    		result =  geomUNSUPPORTED;    // Specific value is returned to enable tests that detect this rather than look for nothing
    		break;
    	}
    	return result;
    }

    
    
    /**
     * Test if the geometry is assignable. A geometry may be more specific within a
     * feature subtype than the superclass. 
     *
     * @param supertypeGeometry The geometry type expected
     * @param subtypeGeometry   the actual geometry that has been specified
     *
     * @return Integer 1 if assignable, 0 if not assignable
     */ 
    private int IsAssignable(String supertypeGeometry, String subtypeGeometry) {
    	int returnValue = 0;

    	// Verify the string input contains values
    	if (!supertypeGeometry.isEmpty() && !subtypeGeometry.isEmpty()) {
    		// Return 1 if the stings are the same or if the supertype and subtype are valid together
        	if (supertypeGeometry.equals(subtypeGeometry) || 
        		( GeometrySubtypesAllowed.containsKey(supertypeGeometry) &&
        		( GeometrySubtypesAllowed.get(supertypeGeometry)).contains(subtypeGeometry)) ) 
        	{
        		returnValue = 1;
        	}
    	}
    	return returnValue;
    }
    

    /**
     * Return a subset byte array from a larger starting byte array
     *
     * @param bytesIn         The source byte array
     * @param startIndex      The starting index from which the subset shall begin
     * @param numberOfBytes   The number of bytes the subset shall contain
     *           
     * @return Byte[] subsetArray subset byte array
     * 
     * @throws IllegalArgumentException if the number of bytes is invalid or the start index + number of bytes desired exceeds the length of the source array
     */ 
   private byte[] byteArraySubset(byte[] bytesIn, int startIndex, int numberOfBytes )
   {
   	byte[] subsetArray = new byte[numberOfBytes];
   	if ((startIndex + numberOfBytes) <= bytesIn.length ) {
	        
	        System.arraycopy(bytesIn, startIndex, subsetArray, 0, numberOfBytes);
	        
   	} else {
   		throw new IllegalArgumentException(
   				String.format(
   						"Invalid numberOfBytes value: %d or startIndex %d. The startIndex + numberOfBytes exceed the length of the byte array.", numberOfBytes, startIndex));
   	}
   	return subsetArray;
   }

   

   /**
    * Get the set of envelope double values from the byte array
    *
    * @param bytesExpected    A count of the number of bytes expected. This value must be a multiple of 8 (the size of a double)
    * @param swapFlag Boolean indicator for whether the bytes are to be swapped or not
    * @param bytesIn          The integer bytes as an array; must be number of bytes in an integer
    * @param envelopeValues   Hash map in which the envelope values will be placed
    *
    * @return boolean true if values are returned, false if all values are 0
    * 
    * @throws IllegalArgumentException if the byte array length is invalid
    * @throws IllegalArgumentException if any value is NaN
    */ 
   private boolean mygetEnvelope(int bytesExpected, boolean swapFlag, byte[] bytesIn, Map<String, Double> envelopeValues) {

   	boolean allzerovalues = true;
   	int envelopeIndex = 0;
   	
   	Assert.assertTrue(envelopeValues.isEmpty(),
				 "Attempt to get envelope when there are already values");
   	

   	if (bytesExpected > 0  && (bytesExpected % Double.BYTES == 0)  && bytesIn.length == bytesExpected) {
			for (int ii = 0; ii < bytesExpected; ii += Double.BYTES) {
				final byte[] envibtem = byteArraySubset(bytesIn, ii, Double.BYTES);    // 8 bytes
				try {
					final Double tempDouble = this.getDoubleFromBytesWithPossibleSwap(envibtem, swapFlag);
					
					if (this.isDoubleRepresentationNaNorInfinity(tempDouble)) {
						throw new IllegalArgumentException(String.format("NaN value detected."));
					}
					// System.out.println(String.format("Envelope item %d with value %f", ii, tempDouble));
   				 //          1 = envelope is [minx, maxx, miny, maxy] 32 bytes envelope
   				 //          2 = envelope is [minx, maxx, miny, maxy, minz, maxz] 48 bytes envelope
   				 //          3 = envelope is [minx, maxx, miny, maxy, minz, maxz, minm, maxm]  64 bytes envelope
					switch(envelopeIndex) {
					case 0: 
						envelopeValues.put(myminx, tempDouble);
						break;
					case 1:
						envelopeValues.put(mymaxx, tempDouble);
						break;		
					case 2:
						envelopeValues.put(myminy, tempDouble);
						break;		
					case 3:
						envelopeValues.put(mymaxy, tempDouble);
						break;		
					case 4:
						envelopeValues.put(myminz, tempDouble);
						break;		
					case 5:
						envelopeValues.put(mymaxz, tempDouble);
						break;		
					case 6:
						envelopeValues.put(myminm, tempDouble);
						break;		
					case 7:
						envelopeValues.put(mymaxm, tempDouble);
						break;		
					}
					
					
					// Extra check here because if the entire envelope is all zero values, 
					//  we basically need to clear the envelope out
					// to save from later excessive processing.  This will set a flag if there
					// are ANY non-zero envelope values seen that that we do not accidentally clear
					// it.
					if (!checkIfValueWithinToleranceOfTargetValue(tempDouble ,0.0D, 1.0e-10))
						allzerovalues = false;
					
					
				} catch (IllegalArgumentException ee)   // This is supposed to catch a NaN
				{
					throw new IllegalArgumentException(ee.getMessage());
				}
				envelopeIndex++;
			}
   	} else {
   		// we either got 0 bytes length or the size of the byte array is inconsistent for a set of doubles
   		throw new IllegalArgumentException(String.format("Invalid bytesExpected value: %d. Is 0 or is not divisible by the size of a double or not the size of the byte array parameter.", bytesExpected));
   	}

		// If we found the entire envelope to be all zero, clear all the elements out of it
   	if (allzerovalues == true) 
   		envelopeValues.clear();
   	
   	return !allzerovalues;
   }

   /**
    * Compare a envelope A defined by minx, maxx, miny, maxy values 
    * against an envelope B to determine if A falls inside or is equal to envelope B
    *
    * @param envelopein  A hash map of 4 (or more with z and m) values representing an envelope
    * @param extentin    A hash map of 4 values representing the min and max extents
    *
    * @return String     Empty string, if no issue. Otherwise it reports the first issue found
    * 
    */ 
   /* This test is only used as part of the NSG 19B test, but could be reinstated later.
   private String geometryEnvelopeWithinExtents(Map<String, Double> envelopein, Map<String, Double> extentin)
   {
   	String fallswithin = "";
   	if (envelopein.get(myminx) < extentin.get(myminx))
   		fallswithin = "Envelope minx less than extent minx";
   	else if (envelopein.get(myminx) > extentin.get(mymaxx))
   		fallswithin = "Envelope minx greater than extent maxx";
   	else if (envelopein.get(mymaxx) < extentin.get(myminx))
   		fallswithin = "Envelope maxx less than extent minx";
   	else if (envelopein.get(mymaxx) > extentin.get(mymaxx))
   		fallswithin = "Envelope maxx greater than extent maxx";
 
   	else if (envelopein.get(myminy) < extentin.get(myminy))
   		fallswithin = "Envelope miny less than extent miny";
   	else if (envelopein.get(myminy) > extentin.get(mymaxy))
   		fallswithin = "Envelope miny greater than extent maxy";
   	else if (envelopein.get(mymaxy) < extentin.get(myminy))
   		fallswithin = "Envelope maxy less than extent miny";
   	else if (envelopein.get(mymaxy) > extentin.get(mymaxy))
   		fallswithin = "Envelope maxy greater than extent maxy";

   	return fallswithin;
   }
	*/
   /**
    * Return the expected size of the envelope based on the envelope code
    *
    * @param envelopeCode    The byte code for the envelope
    *           
    * @return int bytesExpected Number of bytes expected to be present in this envelope
    */ 	
	private int mygetEnvelopeByteSize(byte envelopeCode) {
		int bytesExpected = 0;

		// Note, Caution! Java sign extends each byte for this test, 
		// but these all should be okay because we are dealing with a small value
   	switch (envelopeCode) {
		case 0:
			bytesExpected = 0;
   		break;
		case 1:    // 4 values 32 bytes
			bytesExpected = 32;
			break;
		case 2: case 3:    // 48 bytes total (another 16 bytes)
			bytesExpected = 48;
			break;
		case 4:    // 64 bytes
			bytesExpected = 64;
			break;
		default:	// invalid
			bytesExpected = 0;
			break;
   	} // end switch
		return bytesExpected;
	}

   /**
    * Compares two double values to determine if the are close enough to be called equal within
    * a specified level of tolerance
    *
    * @param valueIn     The input value (double)
    * @param targetValue The target value (double)
    * @param tolerance   The tolerance value (double)
    *           
    * @return true if the value is within tolerance of the target value, false if not
    */ 	
	private boolean checkIfValueWithinToleranceOfTargetValue(double valueIn, double targetValue, double tolerance)
	{
		
		if (Math.abs(valueIn - targetValue) > tolerance)
			return false;
		else
			return true;
	}

}
