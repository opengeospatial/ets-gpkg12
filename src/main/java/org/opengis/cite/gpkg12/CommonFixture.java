package org.opengis.cite.gpkg12;

import static org.testng.Assert.assertTrue;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;

import javax.sql.DataSource;

import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.sqlite.SQLiteConfig;
import org.sqlite.SQLiteDataSource;
import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

/**
 * A supporting base class that sets up a common test fixture. These
 * configuration methods are invoked before any that may be defined in a
 * subclass.
 */
public class CommonFixture {
	protected enum GeoPackageVersion {
		V102(102), V110(110), V120(120);
		private int value;
		private GeoPackageVersion(int value){
			this.value = value;
		}
		
		protected boolean equals(GeoPackageVersion right) {
			return this.value == right.value;
		}
	}
	
	private GeoPackageVersion[] allowedVersions = {GeoPackageVersion.V102, GeoPackageVersion.V110, GeoPackageVersion.V120};
	private final String ICS = "Core,Tiles,Features,Attributes,Extension Mechanism,Non-Linear Geometry Types,RTree Spatial Indexes,Tiles Encoding WebP,Metadata,Schema,WKT for Coordinate Reference Systems,Tiled Gridded Elevation Data";
	
	protected GeoPackageVersion[] getAllowedVersions() {
		return allowedVersions;
	}

	private GeoPackageVersion geopackageVersion;

    protected GeoPackageVersion getGeopackageVersion() {
		return geopackageVersion;
	}

	/** Root test suite package (absolute path). */
    public static final String ROOT_PKG_PATH = "/org/opengis/cite/gpkg12/";
    /** A SQLite database file containing a GeoPackage. */
    protected File gpkgFile;
    /** A JDBC DataSource for accessing the SQLite database. */
    protected DataSource dataSource;

    protected Connection databaseConnection;
    
    /**
     * Initializes the common test fixture. The fixture includes the following
     * components:
     * <ul>
     * <li>a File representing a GeoPackage;</li>
     * <li>a DataSource for accessing a SQLite database.</li>
     * </ul>
     *
     * @param testContext
     *            The test context that contains all the information for a test
     *            run, including suite attributes.
     * @throws SQLException
     *             If a database access error occurs.
     * @throws IOException
     *             If attempts to detect the database version fail
     */
    @BeforeClass
    public void initCommonFixture(final ITestContext testContext) throws SQLException, IOException {
        final Object testFile = testContext.getSuite().getAttribute(SuiteAttribute.TEST_SUBJ_FILE.getName());
        if (testFile == null || !File.class.isInstance(testFile)) {
            throw new IllegalArgumentException(
                    String.format("Suite attribute value is not a File: %s", SuiteAttribute.TEST_SUBJ_FILE.getName()));
        }
        this.gpkgFile = File.class.cast(testFile);
        this.gpkgFile.setWritable(false);
        final SQLiteConfig dbConfig = new SQLiteConfig();
        dbConfig.setSynchronous(SQLiteConfig.SynchronousMode.OFF);
        dbConfig.setJournalMode(SQLiteConfig.JournalMode.MEMORY);
        dbConfig.enforceForeignKeys(true);
        final SQLiteDataSource sqliteSource = new SQLiteDataSource(dbConfig);
        sqliteSource.setUrl("jdbc:sqlite:" + this.gpkgFile.getPath());
        this.dataSource = sqliteSource;
        this.databaseConnection = this.dataSource.getConnection();
        setupVersion();
    }

    @AfterClass
    public void close() throws SQLException {
        if (this.databaseConnection != null && !this.databaseConnection.isClosed()) {
            this.databaseConnection.close();
        }
    }
    
    @BeforeTest
    public void validateClassEnabled(ITestContext testContext) throws IOException {
      Map<String, String> params = testContext.getSuite().getXmlSuite().getParameters();
      String pstr = params.get(TestRunArg.ICS.toString());
      final String testName = testContext.getName();
      setTestName(testName);
      if(pstr == null || pstr.isEmpty()){
    	  pstr = this.ICS;
      }
      HashSet<String> set = new HashSet<String>(Arrays.asList(pstr.split(",")));
      Assert.assertTrue(set.contains(testName), ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_DISABLED, testName));
    }
    
    /**
     * A GeoPackage SHALL contain a value of 0x47504B47 ("GPKG" in ASCII) in 
     * the "application_id" field of the SQLite database header to indicate 
     * that it is a GeoPackage. A GeoPackage SHALL contain an appropriate 
     * value in "user_version" field of the SQLite database header to 
     * indicate its version. The value SHALL be in integer with a major 
     * version, two-digit minor version, and two-digit bug-fix. For 
     * GeoPackage Version 1.2 this value is 0x000027D8 (the hexadecimal value 
     * for 10200). 
     *
     * @throws IOException
     *             If an I/O error occurs while trying to read the data file.
     * @throws SQLException
     *             on any SQL error
     *
     * @see <a href="http://www.geopackage.org/spec/#_requirement-2" target=
     *      "_blank">File Format - Requirement 2</a>
     * @see <a href=
     *      "http://www.sqlite.org/src/artifact?ci=trunk&filename=magic.txt"
     *      target= "_blank">Assigned application IDs</a>
     */
    @Test(description = "See OGC 12-128r12: Requirement 2")
    private void setupVersion() throws SQLException, IOException{
        final byte[] headerBytes = new byte[GPKG12.DB_HEADER_LENGTH];
        try (FileInputStream fileInputStream = new FileInputStream(this.gpkgFile)) {
            fileInputStream.read(headerBytes);
        }
        // 1
        final byte[] appID = Arrays.copyOfRange(headerBytes, GPKG12.APP_ID_OFFSET, GPKG12.APP_ID_OFFSET + 4);
        // 2
    	if (Arrays.equals(appID, GPKG12.APP_GP10)){
    		geopackageVersion = GeoPackageVersion.V102;
    		// 3
    	} else if (Arrays.equals(appID, GPKG12.APP_GP11)){
    		geopackageVersion = GeoPackageVersion.V110;
    		// 4
    	} else if (Arrays.equals(appID, GPKG12.APP_GPKG)){
    		geopackageVersion = GeoPackageVersion.V120;
    	} 
    	// 5
        assertTrue(geopackageVersion != null, ErrorMessage.format(ErrorMessageKeys.UNKNOWN_APP_ID, new String(appID, StandardCharsets.US_ASCII)));
    }   
    
    /**
     * This function returns the name of a single primary key column for the given table
     * 
     * @return the name of the primary key column
     * @param tableName the name of the table
     * @throws SQLException on any error
     */
    protected String getPrimaryKeyColumn(String tableName) throws SQLException {
    	String result = null;
    	
    	try (
    			final Statement statement = this.databaseConnection.createStatement();
    			// 1
    			final ResultSet resultSet = statement.executeQuery(String.format("PRAGMA table_info(%s);", tableName));
    			) {
    		// 2
    		assertTrue(resultSet.next(),
    				ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableName));
    		
    		boolean pass = false;
    		// 3
    		do {
    			final int pk = resultSet.getInt("pk");
    			final String name = resultSet.getString("name");
    			final String type = resultSet.getString("type");
    			if (pk > 0) {
    				assertTrue(pk == 1, 
    						ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, tableName, 
    								String.format("%s has an invalid primary key value of %d", name, pk)));
    				assertTrue("INTEGER".equalsIgnoreCase(type), 
    						ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_TYPE, name, tableName));
    				result = name;
    				pass = true;
    			}
    		} while (resultSet.next());

    		assertTrue(pass && (result != null), ErrorMessage.format(ErrorMessageKeys.TABLE_NO_PK, tableName));    		
    	}
		
		return result;
    }

    /**
     * This function accounts for extensions to Requirement 5 and 25
     * 
     * @param tableName the table name to inspect
     * @param columnName the column name to inspect
     * @return true: this table/column is an exception to Requirement 5 and should be skipped
     * @throws SQLException on any error
     */
    protected boolean isExtendedType(String tableName, String columnName) throws SQLException {
    	boolean result = false;
    	
    	// This accounts for the exception in Requirement 65
    	if(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions")) {
    		try (
    				final Statement statement  = this.databaseConnection.createStatement();
    				final ResultSet resultSet = statement.executeQuery(String.format("SELECT COUNT(*) FROM gpkg_extensions WHERE table_name = '%s' AND column_name = '%s' AND extension_name LIKE 'gpkg_geom_%%'",  tableName, columnName));
    				) {    			
    			resultSet.next();
    			result |= (resultSet.getInt(1) > 0);
    		}
    	}

    	return result;
    }
    
    /**
     * This function checks to determine whether the primary key is valid.
     * Checking the notnull column of PRAGMA table_info is insufficient. 
     * See https://github.com/opengeospatial/geopackage/issues/282 for more details. 
     * @param tableName the name of the table (required)
     * @param pkName the name of the required primary key (may be null, in which case it is detected)
     * @throws SQLException on any error
     */
    protected void checkPrimaryKey(String tableName, String pkName) throws SQLException {
    	// 0 sanity checks
		if (pkName == null) {
			throw new IllegalArgumentException("pkName must not be null.");
		}
		if (tableName == null) {
			throw new IllegalArgumentException("tableName must not be null.");
		}
		
		boolean pass = false;
		try (
				final Statement statement = this.databaseConnection.createStatement();
				// 1
				final ResultSet resultSet = statement.executeQuery(String.format("PRAGMA table_info(%s);", tableName));
				) {

			// 2
			assertTrue(resultSet.next(),
					ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableName));

			pass = false;
			// 3
			do {
				final int pk = resultSet.getInt("pk");
				final String name = resultSet.getString("name");
				final String type = resultSet.getString("type");
				if (pk > 0) {
					assertTrue(pk == 1, 
							ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, tableName, 
									String.format("%s is a primary key of %d", name, pk)));
					assertTrue("INTEGER".equals(type), 
							ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_TYPE, name, tableName));
					assertTrue(pkName.equals(name),
							ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, tableName,
									"pk " + name));
					pass = true;
				}
			} while (resultSet.next());
		}



		assertTrue(pass, ErrorMessage.format(ErrorMessageKeys.TABLE_NO_PK, tableName));
		
		try (
				// 4
				final Statement statement2 = this.databaseConnection.createStatement();

				final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT COUNT(distinct %s) - COUNT(*) from %s", pkName, tableName));
				) {
			// 5
			assertTrue(resultSet2.getInt(1) == 0, String.format(ErrorMessageKeys.TABLE_PK_NOT_UNIQUE, tableName));
		}
    }

    public String getTestName() {
		return testName;
	}

	public void setTestName(String testName) {
		this.testName = testName;
	}

	private String testName;
}
