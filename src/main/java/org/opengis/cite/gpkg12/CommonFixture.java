package org.opengis.cite.gpkg12;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Arrays;

import javax.sql.DataSource;

import org.sqlite.SQLiteConfig;
import org.sqlite.SQLiteDataSource;
import org.testng.ITestContext;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;

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
    
    private void setupVersion() throws SQLException, IOException{
        @SuppressWarnings("CheckForOutOfMemoryOnLargeArrayAllocation")
        final byte[] headerBytes = new byte[GPKG12.DB_HEADER_LENGTH];
        try (FileInputStream fileInputStream = new FileInputStream(this.gpkgFile)) {
            fileInputStream.read(headerBytes);
        }
        final byte[] appID = Arrays.copyOfRange(headerBytes, GPKG12.APP_ID_OFFSET, GPKG12.APP_ID_OFFSET + 4);
    	if (Arrays.equals(appID, GPKG12.APP_GP10)){
    		geopackageVersion = GeoPackageVersion.V102;
    	} else if (Arrays.equals(appID, GPKG12.APP_GP11)){
    		geopackageVersion = GeoPackageVersion.V110;
    	} else if (Arrays.equals(appID, GPKG12.APP_GPKG)){
    		geopackageVersion = GeoPackageVersion.V120;
    	}
    }   
}
