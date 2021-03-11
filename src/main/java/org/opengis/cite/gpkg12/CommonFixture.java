package org.opengis.cite.gpkg12;

import static org.testng.Assert.assertTrue;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;

import javax.sql.DataSource;

import org.opengis.cite.gpkg12.util.GeoPackageVersion;
import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.sqlite.SQLiteConfig;
import org.sqlite.SQLiteDataSource;
import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeTest;

/**
 * A supporting base class that sets up a common test fixture. These
 * configuration methods are invoked before any that may be defined in a
 * subclass.
 */
public class CommonFixture {
	
	private final String ICS = "Core,Tiles,Features,Attributes,Extension Mechanism,Non-Linear Geometry Types,RTree Spatial Indexes,Tiles Encoding WebP,Metadata,Schema,WKT for Coordinate Reference Systems,Tiled Gridded Coverage Data";

	/** Root test suite package (absolute path). */
    public static final String ROOT_PKG_PATH = "/org/opengis/cite/gpkg12/";
    /** A SQLite database file containing a GeoPackage. */
    protected File gpkgFile;
    /** A JDBC DataSource for accessing the SQLite database. */
    protected DataSource dataSource;

    protected Connection databaseConnection;

    protected GeoPackageVersion geopackageVersion;

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
        this.geopackageVersion = (GeoPackageVersion) testContext.getSuite().getAttribute( SuiteAttribute.GPKG_VERSION.getName() );
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
     * This function returns the name of a single primary key column for the given table
     * 
     * @return the name of the primary key column
     * @param tableName the name of the table
     * @param enforcePk 
     *   true: the column must be a primary key
     *   false: default to the first column as long as it is an integer
     * @throws SQLException on any error
     */
    protected String getPrimaryKeyColumn(String tableName, boolean enforcePk) throws SQLException {
    	String result = null;
    	
    	try (
    			final Statement statement = this.databaseConnection.createStatement();
    			// 1
    			final ResultSet resultSet = statement.executeQuery(String.format("PRAGMA table_info('%s');", tableName));
    			) {
    		// 2
    		assertTrue(resultSet.next(),
    				ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableName));
    		
    		boolean pass = false;
    		boolean first = true;
    		String firstName = "";
    		String firstType = "";
    		// 3
    		do {
    			final int pk = resultSet.getInt("pk");
    			final String name = resultSet.getString("name");
    			final String type = resultSet.getString("type");
    			if (first) {
    				firstName = name;
    				firstType = type;
    				first = false;
    			}
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
    		
    		// TODO: The dirty truth is that we can't definitively identify the primary key of a view so we need to guess
    		if(!(enforcePk || pass)) {
				if ("INTEGER".equalsIgnoreCase(firstType)) {
    				result = firstName;
    				pass = true;
				}
    		}

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
    	
    	final String tname = TableVerifier.validateSQLiteTableColumnStringInput(tableName);
    	final String colname = TableVerifier.validateSQLiteTableColumnStringInput(columnName);
    	// This accounts for the exception in Requirement 65
    	if(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions")) {
    		try (
    				final Statement statement  = this.databaseConnection.createStatement();
    				final ResultSet resultSet = statement.executeQuery(String.format("SELECT COUNT(*) FROM gpkg_extensions WHERE table_name = '%s' AND column_name = '%s' AND extension_name LIKE 'gpkg_geom_%%'",  tname, colname));
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
     * @param enforcePk true: the column must be a primary key, false: the column may be PK-like, an integer with unique values
     * @throws SQLException on any error
     */
    protected void checkPrimaryKey(String tableName, String pkName, boolean enforcePk) throws SQLException {
    	// 0 sanity checks
		if (pkName == null) {
			throw new IllegalArgumentException("pkName must not be null.");
		}
		if (tableName == null) {
			throw new IllegalArgumentException("tableName must not be null.");
		}
		final String tableNameV = TableVerifier.validateSQLiteTableColumnStringInput(tableName);
		final String pkNameV = TableVerifier.validateSQLiteTableColumnStringInput(pkName);
		boolean pass = false;
		if (enforcePk) {
			try (
				final Statement statement = this.databaseConnection.createStatement();
				// 1
				final ResultSet resultSet = statement.executeQuery(String.format("PRAGMA table_info('%s');", tableNameV));
			) {
	
				// 2
				assertTrue(resultSet.next(),
						ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableNameV));
	
				pass = false;
				// 3
				do {
					final int pk = resultSet.getInt("pk");
					final String name = resultSet.getString("name");
					final String type = resultSet.getString("type");
					if (pk > 0) {
						assertTrue(pk == 1, 
								ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, tableNameV, 
										String.format("%s is a primary key of %d", name, pk)));
						assertTrue("INTEGER".equals(type), 
								ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_TYPE, name, tableNameV));
						assertTrue(pkNameV.equals(name),
								ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, tableNameV,
										"pk " + name));
						pass = true;
					}
				} while (resultSet.next());
	
				assertTrue(pass, ErrorMessage.format(ErrorMessageKeys.TABLE_NO_PK, tableNameV));
			}
		}


		try (
				// 4
				final Statement statement2 = this.databaseConnection.createStatement();

				final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT COUNT(distinct %s) - COUNT(*) from '%s'", pkNameV, tableName));
				) {
			// 5
			assertTrue(resultSet2.getInt(1) == 0, String.format(ErrorMessageKeys.TABLE_PK_NOT_UNIQUE, tableNameV));
		}
    }

    public String getTestName() {
		return testName;
	}

	public void setTestName(String testName) {
		this.testName = testName;
	}

    /**
     * Validate a string value to ensure it contains no illegal characters or content
     * 
     * @param inputString The string to validate
     * @return validated string
     * @throws IllegalArgumentException if the input is found to be invalid
     */
    public static String ValidateStringInput( String inputString ) throws IllegalArgumentException {

    	StringBuilder sb = new StringBuilder(50);  // initial size is 50. This is expected to be sufficient for most table and field names. This is NOT a limit.
    	for (int ii = 0; ii < inputString.length(); ++ii) {
    		final char cleanedchar = cleanChar(inputString.charAt(ii));
    		if (cleanedchar == '^') {   // This is an illegal character indicator
    			throw new IllegalArgumentException(String.format("Illegal parameter provided within SQL statement. Error in %s at character %c",inputString,  inputString.charAt(ii)));
    		}
    		else {
    			sb.append(cleanedchar);
    		}
    	}
    	return sb.toString();
    }
    
    /**
     * Validate and clean a character of a string.
     * 
     * @param inputChar  A character of a string, for which we will check validity, replacing any illegal characters with ^
     * @return a validated character
     */
    private static char cleanChar(char inputChar) {
        // 0 - 9
        for (int i = 48; i < 58; ++i) {
            if (inputChar == i) return (char) i;
        }

        // 'A' - 'Z'
        for (int i = 65; i < 91; ++i) {
            if (inputChar == i) return (char) i;
        }

        // 'a' - 'z'
        for (int i = 97; i < 123; ++i) {
            if (inputChar == i) return (char) i;
        }

        // other valid characters
        switch (inputChar) {
            case '.':
                return '.';
            case '-':
                return '-';
            case '_':
                return '_';
            case ' ':
                return ' ';
            case '%':
                return '%';
        }
        return '^';
    }
    
	private String testName;
}
