package org.opengis.cite.gpkg12;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.math.BigInteger;
import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.BeforeSuite;

/**
 * Checks that various preconditions are satisfied before the test suite is run.
 * If any of these (BeforeSuite) methods fail, all tests will be skipped.
 */
public class SuitePreconditions {

    private static final Logger LOGR = Logger.getLogger(SuitePreconditions.class.getName());

    /**
     * Verifies that the referenced test subject exists and is a SQLite database
     * file. The first 100 bytes comprise the database file header. The
     * SQLITE_VERSION_NUMBER starts at offset 96; it resolves to an integer with
     * the value (X*1000000 + Y*1000 + Z) where X, Y, and Z are the same numbers
     * used in SQLITE_VERSION. The major version number, X, is always 3 for
     * SQLite3.
     *
     * @param testContext
     *            Information about the (pending) test run.
     * @throws IOException
     *             If an I/O error occurs while trying to read the data file.
     */
    @BeforeSuite
    @SuppressWarnings("rawtypes")
    public void verifySQLiteMajorVersion(ITestContext testContext) throws IOException {
        SuiteAttribute testFileAttr = SuiteAttribute.TEST_SUBJ_FILE;
        Object sutObj = testContext.getSuite().getAttribute(testFileAttr.getName());
        Class expectedType = testFileAttr.getType();
        if (null != sutObj && expectedType.isInstance(sutObj)) {
            File dataFile = File.class.cast(sutObj);
            Assert.assertTrue(dataFile.isFile(),
                    String.format("Data file not found at %s", dataFile.getAbsolutePath()));
            final byte[] headerBytes = new byte[GPKG12.DB_HEADER_LENGTH];
            try (FileInputStream fileInputStream = new FileInputStream(dataFile)) {
                fileInputStream.read(headerBytes);
            }
            byte[] versionNumBytes = Arrays.copyOfRange(headerBytes, 96, headerBytes.length);
            int version = new BigInteger(versionNumBytes).intValue();
            Assert.assertEquals(version / 1000000, 3, "Unexpected SQLite major version in file header.");
        } else {
            String msg = String.format("Value of test suite attribute '%s' is missing or is not an instance of %s",
                    testFileAttr.getName(), expectedType.getName());
            LOGR.log(Level.SEVERE, msg);
            throw new AssertionError(msg);
        }
    }
}
