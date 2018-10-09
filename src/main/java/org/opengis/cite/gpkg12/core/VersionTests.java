package org.opengis.cite.gpkg12.core;

import static org.opengis.cite.gpkg12.SuiteAttribute.GPKG_VERSION;
import static org.opengis.cite.gpkg12.SuiteAttribute.TEST_SUBJ_FILE;
import static org.opengis.cite.gpkg12.util.GeoPackageUtils.getAppId;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;

import org.opengis.cite.gpkg12.GPKG12;
import org.opengis.cite.gpkg12.util.GeoPackageVersion;
import org.testng.ITestContext;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * @author <a href="mailto:goltz@lat-lon.de">Lyn Goltz </a>
 */
public class VersionTests {

    private File gpkgFile;

    private GeoPackageVersion geopackageVersion;

    /**
     * @param testContext
     *            The test context that contains all the information for a test run, including suite attributes.
     */
    @BeforeClass
    public void initGeoPackageFile( final ITestContext testContext ) {
        final Object testFile = testContext.getSuite().getAttribute( TEST_SUBJ_FILE.getName() );
        if ( testFile == null || !File.class.isInstance( testFile ) ) {
            throw new IllegalArgumentException( String.format( "Suite attribute value is not a File: %s",
                                                               TEST_SUBJ_FILE.getName() ) );
        }
        this.gpkgFile = File.class.cast( testFile );
        this.gpkgFile.setWritable( false );
    }

    @AfterClass
    public void storeVersionInTestContext( final ITestContext testContext ) {
        testContext.getSuite().setAttribute( GPKG_VERSION.getName(), geopackageVersion );
    }

    /**
     * A GeoPackage SHALL contain a value of 0x47504B47 ("GPKG" in ASCII) in the "application_id" field of the SQLite
     * database header to indicate that it is a GeoPackage. A GeoPackage SHALL contain an appropriate value in
     * "user_version" field of the SQLite database header to indicate its version. The value SHALL be in integer with a
     * major version, two-digit minor version, and two-digit bug-fix. For GeoPackage Version 1.2 this value is
     * 0x000027D8 (the hexadecimal value for 10200).
     *
     * @throws IOException
     *             If an I/O error occurs while trying to read the data file.
     *
     * @see <a href="http://www.geopackage.org/spec/#_requirement-2" target= "_blank">File Format - Requirement 2</a>
     * @see <a href= "http://www.sqlite.org/src/artifact?ci=trunk&filename=magic.txt" target= "_blank">Assigned
     *      application IDs</a>
     */
    @Test(description = "See OGC 12-128r12: Requirement 2")
    public void geopackageVersion()
                            throws IOException {
        // 1
        final byte[] appID = getAppId( this.gpkgFile );
        // 2
        if ( Arrays.equals( appID, GPKG12.APP_GP10 ) ) {
            geopackageVersion = GeoPackageVersion.V102;
            // 3
        } else if ( Arrays.equals( appID, GPKG12.APP_GP11 ) ) {
            geopackageVersion = GeoPackageVersion.V110;
            // 4
        } else if ( Arrays.equals( appID, GPKG12.APP_GPKG ) ) {
            geopackageVersion = GeoPackageVersion.V120;
        }
    }

}
